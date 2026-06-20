import 'package:intl/intl.dart';

/// Shared date/time formatting so every screen reads the same.
class DateHelpers {
  /// 'yyyy-MM-dd' — used as the Firestore attendance day key.
  static String todayKey([DateTime? d]) =>
      DateFormat('yyyy-MM-dd').format(d ?? DateTime.now());

  /// 'hh:mm a' e.g. 09:30 AM
  static String nowTime([DateTime? d]) =>
      DateFormat('hh:mm a').format(d ?? DateTime.now());

  /// 'dd MMM yyyy' e.g. 20 Jun 2026
  static String prettyDate([DateTime? d]) =>
      DateFormat('dd MMM yyyy').format(d ?? DateTime.now());

  /// 'EEEE' e.g. Saturday
  static String weekday([DateTime? d]) =>
      DateFormat('EEEE').format(d ?? DateTime.now());

  /// True if today is on/after the monthly fee due day (1st).
  static bool isFeeDue([DateTime? d]) => (d ?? DateTime.now()).day >= 1;
}
