import 'package:cloud_firestore/cloud_firestore.dart';

/// A single attendance check-in stored in Firestore `attendance` collection.
/// One document is created when a student swipes to check in.
class AttendanceEntry {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNo;
  final String date; // 'yyyy-MM-dd' for easy day filtering
  final String checkInTime; // 'hh:mm a'
  final DateTime? timestamp;

  const AttendanceEntry({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.date,
    required this.checkInTime,
    this.timestamp,
  });

  factory AttendanceEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AttendanceEntry(
      id: doc.id,
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      rollNo: d['rollNo'] ?? '',
      date: d['date'] ?? '',
      checkInTime: d['checkInTime'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'rollNo': rollNo,
      'date': date,
      'checkInTime': checkInTime,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
