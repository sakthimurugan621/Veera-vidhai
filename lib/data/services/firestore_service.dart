import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_student.dart';
import '../models/attendance_entry.dart';
import '../models/leave_request.dart';
import '../models/team.dart';

/// Central Firestore access layer. No hardcoded data — everything is live.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _students =>
      _db.collection('students');
  CollectionReference<Map<String, dynamic>> get _attendance =>
      _db.collection('attendance');
  CollectionReference<Map<String, dynamic>> get _leaves =>
      _db.collection('leaves');
  CollectionReference<Map<String, dynamic>> get _teams =>
      _db.collection('teams');

  // ── Teams ─────────────────────────────────────────────────────────────────

  /// Creates the default teams (A/B/C) once, if none exist yet.
  Future<void> ensureTeams() async {
    final snap = await _teams.limit(1).get();
    if (snap.docs.isNotEmpty) return;
    final batch = _db.batch();
    batch.set(_teams.doc('team_a'), {'name': 'Team A', 'order': 0});
    batch.set(_teams.doc('team_b'), {'name': 'Team B', 'order': 1});
    batch.set(_teams.doc('team_c'), {'name': 'Team C', 'order': 2});
    await batch.commit();
  }

  Stream<List<Team>> teamsStream() {
    return _teams.snapshots().map((snap) {
      final list = snap.docs.map(Team.fromDoc).toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  Future<List<Team>> getTeams() async {
    final snap = await _teams.get();
    final list = snap.docs.map(Team.fromDoc).toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<void> updateTeamName(String id, String name) async {
    await _teams.doc(id).update({'name': name.trim()});
  }

  /// Live team name for a given id (for the student header).
  Stream<String?> teamNameStream(String teamId) {
    if (teamId.isEmpty) return Stream.value(null);
    return _teams.doc(teamId).snapshots().map(
        (doc) => doc.exists ? (doc.data()?['name'] as String?) : null);
  }

  // ── Students ───────────────────────────────────────────────────────────────

  /// Live list of students, optionally filtered to one team.
  Stream<List<AppStudent>> studentsStream({String? teamId}) {
    Query<Map<String, dynamic>> q = _students;
    if (teamId != null && teamId.isNotEmpty) {
      q = q.where('teamId', isEqualTo: teamId);
    }
    return q.snapshots().map((snap) {
      final list = snap.docs.map(AppStudent.fromDoc).toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  /// Live single student doc, for the student's own dashboard.
  Stream<AppStudent?> studentStream(String id) {
    return _students.doc(id).snapshots().map(
          (doc) => doc.exists ? AppStudent.fromDoc(doc) : null,
        );
  }

  Future<AppStudent?> getStudent(String id) async {
    final doc = await _students.doc(id).get();
    return doc.exists ? AppStudent.fromDoc(doc) : null;
  }

  /// Returns the student matching this phone, or null.
  Future<AppStudent?> findStudentByPhone(String phone) async {
    final snap =
        await _students.where('phone', isEqualTo: phone.trim()).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return AppStudent.fromDoc(snap.docs.first);
  }

  /// Login check: phone + password. Returns the student on success.
  Future<AppStudent?> loginStudent(String phone, String password) async {
    final student = await findStudentByPhone(phone);
    if (student == null) return null;
    if (student.password != password) return null;
    return student;
  }

  /// Adds a new student. Returns the new doc id.
  /// Throws 'phone-exists' / 'roll-exists' if duplicates are found.
  Future<String> addStudent({
    required String name,
    required String rollNo,
    required String phone,
    required String password,
    String className = 'Silambam Beginner',
    String address = '',
    String teamId = '',
    double feeAmount = 500,
  }) async {
    final phoneDup =
        await _students.where('phone', isEqualTo: phone.trim()).limit(1).get();
    if (phoneDup.docs.isNotEmpty) throw 'phone-exists';

    final rollDup = await _students
        .where('rollNo', isEqualTo: rollNo.trim())
        .limit(1)
        .get();
    if (rollDup.docs.isNotEmpty) throw 'roll-exists';

    final ref = await _students.add({
      'name': name.trim(),
      'rollNo': rollNo.trim(),
      'phone': phone.trim(),
      'password': password,
      'className': className,
      'address': address.trim(),
      'teamId': teamId,
      'feeAmount': feeAmount,
      'feeStatus': 'unpaid',
      'lastPaidDate': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateStudent(AppStudent student) async {
    await _students.doc(student.id).update(student.toMap());
  }

  Future<void> updateStudentFields(
      String id, Map<String, dynamic> fields) async {
    await _students.doc(id).update(fields);
  }

  /// Deletes a student and all their attendance records.
  Future<void> deleteStudent(String id) async {
    final att = await _attendance.where('studentId', isEqualTo: id).get();
    final batch = _db.batch();
    for (final d in att.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_students.doc(id));
    await batch.commit();
  }

  // ── Fees ─────────────────────────────────────────────────────────────────

  Future<void> setFeePaid(String id, String paidDate) async {
    await _students.doc(id).update({
      'feeStatus': 'paid',
      'lastPaidDate': paidDate,
    });
  }

  Future<void> setFeeUnpaid(String id) async {
    await _students.doc(id).update({'feeStatus': 'unpaid'});
  }

  /// Bulk mark several students paid (each keeps their own amount).
  Future<void> setFeePaidBatch(Iterable<String> ids, String paidDate) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_students.doc(id),
          {'feeStatus': 'paid', 'lastPaidDate': paidDate});
    }
    await batch.commit();
  }

  /// Bulk mark several students unpaid.
  Future<void> setFeeUnpaidBatch(Iterable<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_students.doc(id), {'feeStatus': 'unpaid'});
    }
    await batch.commit();
  }

  Future<void> updateFee(
      String id, double amount, String status, String paidDate) async {
    await _students.doc(id).update({
      'feeAmount': amount,
      'feeStatus': status,
      'lastPaidDate': status == 'paid' ? paidDate : '',
    });
  }

  // ── Attendance ─────────────────────────────────────────────────────────────
  // One record per student per day: id = '<studentId>_<date>'.

  String _attId(String studentId, String date) => '${studentId}_$date';

  Map<String, dynamic> _attData(
      AppStudent s, String date, String status, String time, String by) {
    return {
      'studentId': s.id,
      'studentName': s.name,
      'rollNo': s.rollNo,
      'phone': s.phone,
      'teamId': s.teamId,
      'date': date,
      'status': status,
      'checkInTime': time,
      'markedBy': by,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  Future<void> markPresent({
    required AppStudent student,
    required String date,
    required String checkInTime,
    String markedBy = 'admin',
  }) async {
    await _attendance
        .doc(_attId(student.id, date))
        .set(_attData(student, date, 'present', checkInTime, markedBy));
  }

  Future<void> markAbsent({
    required AppStudent student,
    required String date,
    String markedBy = 'admin',
  }) async {
    await _attendance
        .doc(_attId(student.id, date))
        .set(_attData(student, date, 'absent', '', markedBy));
  }

  /// Removes a day's mark (back to "not marked").
  Future<void> clearAttendance(String studentId, String date) async {
    await _attendance.doc(_attId(studentId, date)).delete();
  }

  /// Today's status for a student: 'present' | 'absent' | null.
  Future<String?> getAttendanceStatus(String studentId, String date) async {
    final doc = await _attendance.doc(_attId(studentId, date)).get();
    if (!doc.exists) return null;
    return doc.data()?['status'] as String?;
  }

  /// Attendance for a date (admin view), optionally filtered to one team.
  Stream<List<AttendanceEntry>> attendanceForDateStream(String date,
      {String? teamId}) {
    return _attendance.where('date', isEqualTo: date).snapshots().map((snap) {
      var list = snap.docs.map(AttendanceEntry.fromDoc).toList();
      if (teamId != null && teamId.isNotEmpty) {
        list = list.where((e) => e.teamId == teamId).toList();
      }
      list.sort((a, b) {
        final at = a.timestamp ?? DateTime(2000);
        final bt = b.timestamp ?? DateTime(2000);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  /// A single student's attendance history, most recent first.
  Stream<List<AttendanceEntry>> studentAttendanceStream(String studentId) {
    return _attendance
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(AttendanceEntry.fromDoc).toList();
      list.sort((a, b) {
        final at = a.timestamp ?? DateTime(2000);
        final bt = b.timestamp ?? DateTime(2000);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  // ── Leave requests ──────────────────────────────────────────────────────────

  Future<void> applyLeave({
    required AppStudent student,
    required String leaveType,
    required String comments,
    required String fromDate,
    required String toDate,
  }) async {
    await _leaves.add({
      'studentId': student.id,
      'studentName': student.name,
      'rollNo': student.rollNo,
      'phone': student.phone,
      'teamId': student.teamId,
      'leaveType': leaveType,
      'comments': comments.trim(),
      'fromDate': fromDate,
      'toDate': toDate,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// A single student's leave applications, most recent first.
  Stream<List<LeaveRequest>> studentLeavesStream(String studentId) {
    return _leaves
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(LeaveRequest.fromDoc).toList();
      list.sort((a, b) {
        final at = a.createdAt ?? DateTime(2000);
        final bt = b.createdAt ?? DateTime(2000);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  /// Every leave request ever made (admin), optionally filtered to one team.
  Stream<List<LeaveRequest>> allLeavesStream({String? teamId}) {
    return _leaves.snapshots().map((snap) {
      var list = snap.docs.map(LeaveRequest.fromDoc).toList();
      if (teamId != null && teamId.isNotEmpty) {
        list = list.where((l) => l.teamId == teamId).toList();
      }
      list.sort((a, b) {
        final at = a.createdAt ?? DateTime(2000);
        final bt = b.createdAt ?? DateTime(2000);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  /// All pending leave requests (admin), optionally filtered to one team.
  Stream<List<LeaveRequest>> pendingLeavesStream({String? teamId}) {
    return _leaves
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
      var list = snap.docs.map(LeaveRequest.fromDoc).toList();
      if (teamId != null && teamId.isNotEmpty) {
        list = list.where((l) => l.teamId == teamId).toList();
      }
      list.sort((a, b) {
        final at = a.createdAt ?? DateTime(2000);
        final bt = b.createdAt ?? DateTime(2000);
        return bt.compareTo(at);
      });
      return list;
    });
  }

  Future<void> setLeaveStatus(String id, String status) async {
    await _leaves.doc(id).update({'status': status});
  }
}
