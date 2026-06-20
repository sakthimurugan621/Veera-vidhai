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
          return Column(
            children: [
              GradientHeader(
                tamilTitle: 'என் வருகை',
                subtitle: 'My Attendance',
                bottom: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: Colors.white, size: 30),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${history.length}',
                                style: AppTextStyles.headlineLarge
                                    .copyWith(color: Colors.white)),
                            Text('Total Days Present',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
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
          Text('Slide to check in from the Home tab',
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
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayNum,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.primary)),
                Text(month,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.primary)),
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
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('Checked in at ${entry.checkInTime}',
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
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Present',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
