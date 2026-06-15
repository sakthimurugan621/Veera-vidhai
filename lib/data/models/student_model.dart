import 'attendance_model.dart';
import 'fee_model.dart';

class Student {
  final String id;
  final String rollNo;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String admissionDate;
  final String className;
  final String address;
  final bool isPresent;
  final String? checkInTime; // e.g. "09:30 AM"
  final int presentCount;
  final int absentCount;
  final int pendingCount;
  final int totalWorkingDays;
  final double totalFees;
  final double paidFees;
  final List<AttendanceRecord> attendanceHistory;
  final List<FeePayment> paymentHistory;

  const Student({
    required this.id,
    required this.rollNo,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.admissionDate,
    required this.className,
    required this.address,
    required this.isPresent,
    this.checkInTime,
    required this.presentCount,
    required this.absentCount,
    required this.pendingCount,
    required this.totalWorkingDays,
    required this.totalFees,
    required this.paidFees,
    required this.attendanceHistory,
    required this.paymentHistory,
  });

  bool get feesPaid => paidFees >= totalFees;
  double get dueFees => totalFees - paidFees;
  double get attendancePercentage =>
      totalWorkingDays == 0 ? 0 : (presentCount / totalWorkingDays) * 100;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }
}
