import 'package:cloud_firestore/cloud_firestore.dart';

/// A leave application stored in Firestore `leaves` collection.
class LeaveRequest {
  final String id;
  final String studentId;
  final String studentName;
  final String rollNo;
  final String phone;
  final String leaveType;
  final String comments;
  final String fromDate; // 'dd MMM yyyy'
  final String toDate; // 'dd MMM yyyy'
  final String status; // 'pending' | 'approved' | 'declined'
  final DateTime? createdAt;

  const LeaveRequest({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    this.phone = '',
    required this.leaveType,
    required this.comments,
    this.fromDate = '',
    this.toDate = '',
    this.status = 'pending',
    this.createdAt,
  });

  /// "12 Jun 2026 → 14 Jun 2026", or a single date if both are equal.
  String get dateRange {
    if (fromDate.isEmpty && toDate.isEmpty) return '';
    if (fromDate == toDate) return fromDate;
    return '$fromDate → $toDate';
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDeclined => status == 'declined';

  factory LeaveRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return LeaveRequest(
      id: doc.id,
      studentId: d['studentId'] ?? '',
      studentName: d['studentName'] ?? '',
      rollNo: d['rollNo'] ?? '',
      phone: d['phone'] ?? '',
      leaveType: d['leaveType'] ?? '',
      comments: d['comments'] ?? '',
      fromDate: d['fromDate'] ?? '',
      toDate: d['toDate'] ?? '',
      status: d['status'] ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
