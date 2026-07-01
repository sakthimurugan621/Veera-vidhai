import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/app_student.dart';
import '../../../data/models/attendance_entry.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/app_logo_badge.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/live_clock.dart';

class StudentHomeTab extends StatefulWidget {
  final AppStudent student;
  const StudentHomeTab({super.key, required this.student});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  final _fs = FirestoreService.instance;
  String? _todayStatus; // 'present' | 'absent' | null
  bool _loadingStatus = true;
  bool _marking = false;

  @override
  void initState() {
    super.initState();
    _loadTodayStatus();
  }

  Future<void> _loadTodayStatus() async {
    final today = DateHelpers.todayKey();
    final status = await _fs.getAttendanceStatus(widget.student.id, today);
    if (mounted) {
      setState(() {
        _todayStatus = status;
        _loadingStatus = false;
      });
    }
  }

  Future<void> _markAbsent() async {
    setState(() => _marking = true);
    await _fs.markAbsent(
      student: widget.student,
      date: DateHelpers.todayKey(),
      markedBy: 'student',
    );
    if (!mounted) return;
    setState(() {
      _todayStatus = 'absent';
      _marking = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Marked absent for today. Your trainer is notified.'),
        backgroundColor: AppColors.error,
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
                    const AppLogoBadge(size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('வணக்கம், $firstName 👋',
                              style: AppTextStyles.headlineSmall
                                  .copyWith(color: Colors.white)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('Roll ${s.rollNo}',
                                    style: AppTextStyles.labelSmall
                                        .copyWith(color: Colors.white)),
                              ),
                              // Team name chip (gold)
                              StreamBuilder<String?>(
                                stream: _fs.teamNameStream(s.teamId),
                                builder: (context, snap) {
                                  final team = snap.data;
                                  if (team == null || team.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.groups_rounded,
                                            color: Colors.white, size: 12),
                                        const SizedBox(width: 4),
                                        Text(team,
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
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
                      final present =
                          history.where((e) => e.isPresent).length;
                      return _attendanceSummary(context, present);
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

          // Mark Absent (student can only report absence; admin marks present)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: _loadingStatus
                ? const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()))
                : _absentButton(context),
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
    final isPresent = _todayStatus == 'present';
    final isAbsent = _todayStatus == 'absent';
    final color = isPresent
        ? AppColors.success
        : isAbsent
            ? AppColors.error
            : AppColors.warning;
    final bg = isPresent
        ? AppColors.successLight
        : isAbsent
            ? AppColors.errorLight
            : AppColors.warningLight;
    final label = isPresent
        ? 'Present'
        : isAbsent
            ? 'Absent'
            : 'Not Marked';
    final sub = isPresent
        ? 'By trainer'
        : isAbsent
            ? 'You reported'
            : 'Waiting';
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
                  isPresent
                      ? Icons.check_circle_rounded
                      : isAbsent
                          ? Icons.cancel_rounded
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
          Text(label,
              style: AppTextStyles.titleLarge
                  .copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(sub, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _absentButton(BuildContext context) {
    if (_todayStatus == 'present') {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success),
            const SizedBox(width: 8),
            Text('You are marked Present today',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.success)),
          ],
        ),
      );
    }
    if (_todayStatus == 'absent') {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text('You reported Absent today',
                style:
                    AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
          ],
        ),
      );
    }
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _marking ? null : _confirmAbsent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          minimumSize: const Size(double.infinity, 56),
        ),
        icon: _marking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.event_busy_rounded),
        label: const Text("I'm Absent Today"),
      ),
    );
  }

  Future<void> _confirmAbsent() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Mark Absent?', style: AppTextStyles.headlineSmall),
        content: Text(
          'This tells your trainer you will be absent today. Continue?',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Absent'),
          ),
        ],
      ),
    );
    if (ok == true) _markAbsent();
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
