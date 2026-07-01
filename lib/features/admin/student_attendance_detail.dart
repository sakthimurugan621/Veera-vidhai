import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_student.dart';
import '../../data/models/attendance_entry.dart';
import '../../data/services/firestore_service.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/gradient_header.dart';

/// Admin view of one student's full attendance schedule.
class StudentAttendanceDetail extends StatelessWidget {
  final AppStudent student;
  const StudentAttendanceDetail({super.key, required this.student});

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
                tamilTitle: student.name,
                subtitle: 'Roll ${student.rollNo} • Attendance',
                trailing: HeaderIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                bottom: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _stat('Present', present,
                            Icons.check_circle_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _stat('Absent', absent, Icons.cancel_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _stat('Total', history.length,
                            Icons.event_note_rounded),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: snap.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : history.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_busy_rounded,
                                    size: 64,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                Text('No attendance records yet',
                                    style: AppTextStyles.titleMedium.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                            itemCount: history.length,
                            itemBuilder: (context, i) => FadeSlideIn(
                              delayMs: 30 * (i % 14),
                              child: _row(context, history[i]),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text('$value',
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, AttendanceEntry e) {
    DateTime? date;
    try {
      date = DateTime.parse(e.date);
    } catch (_) {}
    final dayNum = date != null ? DateFormat('dd').format(date) : '--';
    final month = date != null ? DateFormat('MMM').format(date) : '';
    final weekday = date != null ? DateFormat('EEEE').format(date) : e.date;
    final present = e.isPresent;
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
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
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
                Text(
                    present
                        ? (e.checkInTime.isNotEmpty
                            ? 'Present at ${e.checkInTime}'
                            : 'Present')
                        : 'Absent (${e.markedBy == 'student' ? 'self-reported' : 'by trainer'})',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Text(present ? 'Present' : 'Absent',
                style: AppTextStyles.labelSmall
                    .copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
