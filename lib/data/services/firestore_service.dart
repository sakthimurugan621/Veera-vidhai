import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_student.dart';
import '../models/attendance_entry.dart';

/// Central Firestore access layer. No hardcoded data — everything is live.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _students =>
      _db.collection('students');
  CollectionReference<Map<String, dynamic>> get _attendance =>
      _db.collection('attendance');

  // ── Students ───────────────────────────────────────────────────────────────

  /// Live list of all students (newest first), for the admin.
  Stream<List<AppStudent>> studentsStream() {
    return _students.snapshots().map((snap) {
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

  Future<void> updateFee(
      String id, double amount, String status, String paidDate) async {
    await _students.doc(id).update({
      'feeAmount': amount,
      'feeStatus': status,
      'lastPaidDate': status == 'paid' ? paidDate : '',
    });
  }

  // ── Attendance ─────────────────────────────────────────────────────────────

  Future<bool> hasCheckedInToday(String studentId, String date) async {
    final snap = await _attendance
        .where('studentId', isEqualTo: studentId)
        .where('date', isEqualTo: date)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> markAttendance({
    required AppStudent student,
    required String date,
    required String checkInTime,
  }) async {
    final entry = AttendanceEntry(
      id: '',
      studentId: student.id,
      studentName: student.name,
      rollNo: student.rollNo,
      date: date,
      checkInTime: checkInTime,
    );
    await _attendance.add(entry.toMap());
  }

  /// Today's check-ins (admin view), most recent first.
  Stream<List<AttendanceEntry>> attendanceForDateStream(String date) {
    return _attendance.where('date', isEqualTo: date).snapshots().map((snap) {
      final list = snap.docs.map(AttendanceEntry.fromDoc).toList();
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
}
