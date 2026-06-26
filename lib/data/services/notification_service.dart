import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/date_helpers.dart';

/// Handles notifications.
///
/// Two layers:
///  1. FCM push (works app-closed) — needs the Cloud Functions (Blaze plan).
///  2. Free fallback (Spark plan): Firestore listeners + local notifications.
///     The admin/student app, while open or in background, watches Firestore
///     and pops a local notification instantly — no server, ₹0.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'attendance_channel',
    'Attendance Alerts',
    description: 'Notifies the admin when a student marks attendance',
    importance: Importance.high,
  );

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    await _fm.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Show a banner even when the app is in the foreground.
    await _fm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showLocal);
  }

  void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Register this admin device so the Cloud Function can target it.
  Future<void> saveAdminToken() async {
    try {
      final token = await _fm.getToken();
      if (token == null) return;
      await _db.collection('admin_tokens').doc(token).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _fm.onTokenRefresh.listen((t) {
        _db.collection('admin_tokens').doc(t).set({
          'token': t,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (_) {
      // Ignore — notifications are best-effort.
    }
  }

  /// Remove this device's token on admin logout.
  Future<void> removeAdminToken() async {
    try {
      final token = await _fm.getToken();
      if (token == null) return;
      await _db.collection('admin_tokens').doc(token).delete();
    } catch (_) {}
  }

  /// Register this student device so the Cloud Function can notify them
  /// directly (leave approved / declined). Stored on the student doc.
  Future<void> saveStudentToken(String studentId) async {
    try {
      final token = await _fm.getToken();
      if (token == null) return;
      await _db.collection('students').doc(studentId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
      _fm.onTokenRefresh.listen((t) {
        _db.collection('students').doc(studentId).update({
          'fcmTokens': FieldValue.arrayUnion([t]),
        });
      });
    } catch (_) {}
  }

  /// Remove this device's token from the student doc on logout.
  Future<void> removeStudentToken(String studentId) async {
    try {
      final token = await _fm.getToken();
      if (token == null) return;
      await _db.collection('students').doc(studentId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    } catch (_) {}
  }

  // ── Free fallback: Firestore listeners → local notifications ────────────────
  // Works on the Spark (free) plan while the app is open or in background.

  final List<StreamSubscription> _subs = [];

  void _showSimple(String title, String body) {
    _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Admin: notify on new attendance check-ins and new leave requests.
  void startAdminListeners() {
    stopListeners();
    final today = DateHelpers.todayKey();

    var firstAtt = true;
    _subs.add(_db
        .collection('attendance')
        .where('date', isEqualTo: today)
        .snapshots()
        .listen((snap) {
      if (firstAtt) {
        firstAtt = false;
        return; // skip existing records on first load
      }
      for (final c in snap.docChanges) {
        if (c.type == DocumentChangeType.added) {
          final d = c.doc.data() ?? {};
          _showSimple(
            'New Attendance ✅',
            '${d['studentName']} (${d['phone'] ?? ''}) checked in at ${d['checkInTime'] ?? ''}',
          );
        }
      }
    }));

    var firstLeave = true;
    _subs.add(_db
        .collection('leaves')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snap) {
      if (firstLeave) {
        firstLeave = false;
        return;
      }
      for (final c in snap.docChanges) {
        if (c.type == DocumentChangeType.added) {
          final d = c.doc.data() ?? {};
          final from = d['fromDate'] ?? '';
          final to = d['toDate'] ?? '';
          final range = from.isEmpty
              ? ''
              : (from == to ? ' ($from)' : ' ($from → $to)');
          _showSimple(
            'New Leave Request 📩',
            '${d['studentName']} (Roll ${d['rollNo'] ?? ''}) — ${d['leaveType'] ?? 'Leave'}$range',
          );
        }
      }
    }));
  }

  /// Student: notify when their own leave is approved / declined.
  void startStudentListeners(String studentId) {
    stopListeners();
    var first = true;
    _subs.add(_db
        .collection('leaves')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .listen((snap) {
      if (first) {
        first = false;
        return;
      }
      for (final c in snap.docChanges) {
        if (c.type == DocumentChangeType.modified) {
          final d = c.doc.data() ?? {};
          final status = d['status'];
          final type = d['leaveType'] ?? 'Leave';
          if (status == 'approved') {
            _showSimple('Leave Approved ✅', 'Your $type request was approved.');
          } else if (status == 'declined') {
            _showSimple('Leave Declined ❌', 'Your $type request was declined.');
          }
        }
      }
    }));
  }

  void stopListeners() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }
}
