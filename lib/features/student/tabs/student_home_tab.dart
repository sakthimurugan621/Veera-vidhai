import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/app_student.dart';
import '../../../data/models/attendance_entry.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/live_clock.dart';
import '../../../widgets/slide_to_action.dart';

class StudentHomeTab extends StatefulWidget {
  final AppStudent student;
  const StudentHomeTab({super.key, required this.student});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  final _fs = FirestoreService.instance;
  bool _checkedToday = false;
  String? _checkInTime;
  bool _loadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadTodayStatus();
  }

  Future<void> _loadTodayStatus() async {
    final today = DateHelpers.todayKey();
    final done = await _fs.hasCheckedInToday(widget.student.id, today);
    if (mounted) {
      setState(() {
        _checkedToday = done;
        _loadingStatus = false;
      });
    }
  }

  Future<void> _checkIn() async {
    final time = DateHelpers.nowTime();
    await _fs.markAttendance(
      student: widget.student,
      date: DateHelpers.todayKey(),
      checkInTime: time,
    );
    if (!mounted) return;
    setState(() {
      _checkedToday = true;
      _checkInTime = time;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance marked at $time'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final firstName = s.name.split(' ').first;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('வணக்கம், $firstName 👋',
                              style: AppTextStyles.headlineSmall
                                  .copyWith(color: Colors.white)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Roll ${s.rollNo} • ${s.className}',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const LiveClock(),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              children: [
                // Fees reminder
                if (!s.feesPaid)
                  FadeSlideIn(child: _feesReminder(context, s)),
                if (!s.feesPaid) const SizedBox(height: 16),

                // Today status + fees row
                Row(
                  children: [
                    Expanded(
                      child: FadeSlideIn(
                        delayMs: 60,
                        child: _statusCard(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FadeSlideIn(
                        delayMs: 120,
                        child: _feeCard(context, s),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Attendance summary from Firestore
                FadeSlideIn(
                  delayMs: 180,
                  child: StreamBuilder<List<AttendanceEntry>>(
                    stream: _fs.studentAttendanceStream(s.id),
                    builder: (context, snap) {
                      final history = snap.data ?? [];
                      return _attendanceSummary(context, history.length);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                FadeSlideIn(
                  delayMs: 240,
                  child: _classInfo(context, s),
                ),
              ],
            ),
          ),

          // Slide to check in
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: _loadingStatus
                ? const SizedBox(
                    height: 64,
                    child: Center(child: CircularProgressIndicator()))
                : SlideToAction(
                    confirmed: _checkedToday,
                    idleLabel: 'Slide to Check In',
                    doneLabel: _checkInTime != null
                        ? 'Checked In  $_checkInTime ✓'
                        : 'Already Checked In ✓',
                    onConfirm: _checkIn,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _feesReminder(BuildContext context, AppStudent s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fee Reminder',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: const Color(0xFF92400E))),
                const SizedBox(height: 2),
                Text(
                  'Your monthly fee of ₹${s.feeAmount.toInt()} is pending. Please pay soon.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: const Color(0xFF92400E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context) {
    final color = _checkedToday ? AppColors.success : AppColors.error;
    final bg = _checkedToday ? AppColors.successLight : AppColors.errorLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  _checkedToday
                      ? Icons.check_circle_rounded
                      : Icons.access_time_rounded,
                  color: color,
                  size: 16),
              const SizedBox(width: 4),
              Text('Today',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(_checkedToday ? 'Present' : 'Not Marked',
              style: AppTextStyles.titleLarge
                  .copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(_checkInTime != null ? 'At $_checkInTime' : 'Slide below',
              style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _feeCard(BuildContext context, AppStudent s) {
    final color = s.feesPaid ? AppColors.success : AppColors.error;
    final bg = s.feesPaid ? AppColors.successLight : AppColors.errorLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.currency_rupee_rounded, color: color, size: 16),
              const SizedBox(width: 4),
              Text('Fees',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.feesPaid ? 'Paid' : 'Pending',
              style: AppTextStyles.titleLarge
                  .copyWith(color: color, fontWeight: FontWeight.bold)),
          Text('₹${s.feeAmount.toInt()}',
              style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _attendanceSummary(BuildContext context, int totalPresent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Days Present',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              const SizedBox(height: 2),
              Text('$totalPresent Days',
                  style: AppTextStyles.headlineLarge
                      .copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _classInfo(BuildContext context, AppStudent s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_martial_arts_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.className,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                Text('Silambam Training Academy',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
