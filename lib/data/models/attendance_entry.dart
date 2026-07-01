import 'package:cloud_firestore/cloud_firestore.dart';

/// A single day's attendance record for a student, stored in Firestore
/// `attendance` collection with a deterministic id `${studentId}_${date}`
/// so there is exactly one record per student per day.
class AttendanceEntry {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNo;
  final String phone;
  final String teamId;
  final String date; // 'yyyy-MM-dd'
  final String status; // 'present' | 'absent'
  final String checkInTime; // 'hh:mm a' (only for present)
  final String markedBy; // 'admin' | 'student'
  final DateTime? timestamp;

  const AttendanceEntry({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    this.phone = '',
    this.teamId = '',
    required this.date,
    this.status = 'present',
    this.checkInTime = '',
    this.markedBy = 'admin',
    this.timestamp,
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';

  factory AttendanceEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AttendanceEntry(
      id: doc.id,
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      rollNo: d['rollNo'] ?? '',
      phone: d['phone'] ?? '',
      teamId: d['teamId'] ?? '',
      date: d['date'] ?? '',
      status: d['status'] ?? 'present',
      checkInTime: d['checkInTime'] ?? '',
      markedBy: d['markedBy'] ?? 'admin',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
