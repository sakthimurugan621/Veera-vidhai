enum AttendanceStatus { present, absent, pending }

class AttendanceRecord {
  final String date;
  final String day;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.date,
    required this.day,
    required this.status,
  });
}
