import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_student.dart';
import '../../../data/models/attendance_entry.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';

class StudentAttendanceTab extends StatelessWidget {
  final AppStudent student;
  const StudentAttendanceTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<AttendanceEntry>>(
        stream: FirestoreService.instance.studentAttendanceStream(student.id),
        builder: (context, snap) {
          final history = snap.data ?? [];
          final present = history.where((e) => e.isPresent).length;
          final absent = history.where((e) => e.isAbsent).length;
          return Column(
            children: [
              GradientHeader(
                tamilTitle: 'என் வருகை',
                subtitle: 'My Attendance',
                bottom: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _headerStat(
                            'Present', present, Icons.check_circle_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _headerStat(
                            'Absent', absent, Icons.cancel_rounded),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: snap.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : history.isEmpty
                        ? _empty(context)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                            itemCount: history.length,
                            itemBuilder: (context, i) => FadeSlideIn(
                              delayMs: 40 * (i % 12),
                              child: _HistoryRow(entry: history[i]),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerStat(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: Colors.white)),
              Text(label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 72, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('No attendance yet',
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Your trainer will mark your attendance',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final AttendanceEntry entry;
  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    DateTime? date;
    try {
      date = DateTime.parse(entry.date);
    } catch (_) {}
    final dayNum = date != null ? DateFormat('dd').format(date) : '--';
    final month = date != null ? DateFormat('MMM').format(date) : '';
    final weekday = date != null ? DateFormat('EEEE').format(date) : entry.date;

    final present = entry.isPresent;
    final color = present ? AppColors.success : AppColors.error;
    final bg = present ? AppColors.successLight : AppColors.errorLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayNum,
                    style: AppTextStyles.titleMedium.copyWith(color: color)),
                Text(month,
                    style: AppTextStyles.labelSmall.copyWith(color: color)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weekday,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                Row(
                  children: [
                    Icon(
                        present
                            ? Icons.access_time_rounded
                            : Icons.info_outline_rounded,
                        size: 12,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                        present
                            ? (entry.checkInTime.isNotEmpty
                                ? 'Present at ${entry.checkInTime}'
                                : 'Marked present')
                            : 'Marked absent',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(present ? 'Present' : 'Absent',
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
