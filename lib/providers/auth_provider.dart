import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/app_student.dart';
import '../data/services/firestore_service.dart';
import '../data/services/notification_service.dart';

/// Auth model:
///  - Admin  → Firebase Auth (email + password). Session persists via Firebase.
///  - Student → Firestore `students` (phone + password). Session persists
///    via SharedPreferences (stored studentId).
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _fs = FirestoreService.instance;

  static const _kStudentIdKey = 'logged_in_student_id';

  String? _role; // 'admin' | 'student'
  String? _studentId;
  String? _adminEmail;
  AppStudent? _student; // snapshot at login time
  bool _isLoading = false;
  String? _errorMessage;

  String? get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isStudent => _role == 'student';
  bool get isLoggedIn => _role != null;
  String? get studentId => _studentId;
  String? get adminEmail => _adminEmail;
  AppStudent? get student => _student;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Session restore (called on splash) ─────────────────────────────────────
  Future<String?> checkAuthState() async {
    // Admin via Firebase Auth
    final user = _auth.currentUser;
    if (user != null) {
      _role = 'admin';
      _adminEmail = user.email;
      NotificationService.instance.saveAdminToken();
      notifyListeners();
      return 'admin';
    }

    // Student via SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final sid = prefs.getString(_kStudentIdKey);
    if (sid != null) {
      final s = await _fs.getStudent(sid);
      if (s != null) {
        _role = 'student';
        _studentId = sid;
        _student = s;
        NotificationService.instance.saveStudentToken(sid);
        notifyListeners();
        return 'student';
      } else {
        await prefs.remove(_kStudentIdKey); // stale
      }
    }
    return null;
  }

  // ── Admin login ─────────────────────────────────────────────────────────────
  Future<String?> loginAdmin(String email, String password) async {
    _setLoading(true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _role = 'admin';
      _adminEmail = cred.user?.email;
      _studentId = null;
      _student = null;
      NotificationService.instance.saveAdminToken();
      _setLoading(false);
      return 'admin';
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      return null;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return null;
    }
  }

  // ── Student login (Firestore phone + password) ──────────────────────────────
  Future<String?> loginStudent(String phone, String password) async {
    _setLoading(true);
    try {
      final s = await _fs.loginStudent(phone.trim(), password);
      if (s == null) {
        _setError('Invalid phone number or password.');
        return null;
      }
      _role = 'student';
      _studentId = s.id;
      _student = s;

      NotificationService.instance.saveStudentToken(s.id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStudentIdKey, s.id);

      _setLoading(false);
      return 'student';
    } catch (_) {
      _setError('Login failed. Check your internet connection.');
      return null;
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    if (_role == 'admin') {
      await NotificationService.instance.removeAdminToken();
      await _auth.signOut();
    } else if (_role == 'student') {
      if (_studentId != null) {
        await NotificationService.instance.removeStudentToken(_studentId!);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStudentIdKey);
    }
    _role = null;
    _studentId = null;
    _student = null;
    _adminEmail = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    if (v) _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _isLoading = false;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No admin account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'No internet connection. Please check and retry.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'user-disabled':
        return 'This account is disabled. Contact support.';
      default:
        return 'Login failed ($code). Please try again.';
    }
  }
}
