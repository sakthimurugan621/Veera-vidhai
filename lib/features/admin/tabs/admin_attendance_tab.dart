import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/app_student.dart';
import '../../../data/models/attendance_entry.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';

class AdminAttendanceTab extends StatelessWidget {
  const AdminAttendanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService.instance;
    final today = DateHelpers.todayKey();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<AppStudent>>(
        stream: fs.studentsStream(),
        builder: (context, studentSnap) {
          final students = studentSnap.data ?? [];
          return StreamBuilder<List<AttendanceEntry>>(
            stream: fs.attendanceForDateStream(today),
            builder: (context, attSnap) {
              final present = attSnap.data ?? [];
              final presentIds = present.map((e) => e.studentId).toSet();
              final absent = students
                  .where((s) => !presentIds.contains(s.id))
                  .toList();

              return Column(
                children: [
                  GradientHeader(
                    tamilTitle: 'வருகை',
                    subtitle: DateHelpers.prettyDate(),
                    bottom: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _miniStat('Present', '${present.length}',
                                Icons.check_circle_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _miniStat('Absent', '${absent.length}',
                                Icons.cancel_rounded),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _miniStat('Total', '${students.length}',
                                Icons.groups_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: students.isEmpty
                        ? _empty(context, 'No students registered yet')
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                            children: [
                              _sectionLabel(context, 'Checked In',
                                  present.length, AppColors.success),
                              const SizedBox(height: 10),
                              if (present.isEmpty)
                                _empty(context, 'No check-ins yet today',
                                    small: true)
                              else
                                ...present.asMap().entries.map(
                                      (e) => FadeSlideIn(
                                        delayMs: 40 * e.key,
                                        child: _PresentRow(entry: e.value),
                                      ),
                                    ),
                              const SizedBox(height: 22),
                              _sectionLabel(context, 'Not Yet Present',
                                  absent.length, AppColors.error),
                              const SizedBox(height: 10),
                              if (absent.isEmpty)
                                _empty(context, 'Everyone is present! 🎉',
                                    small: true)
                              else
                                ...absent.asMap().entries.map(
                                      (e) => FadeSlideIn(
                                        delayMs: 40 * e.key,
                                        child: _AbsentRow(student: e.value),
                                      ),
                                    ),
                            ],
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) {
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
          Text(value,
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _sectionLabel(
      BuildContext context, String text, int count, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: color),
        const SizedBox(width: 8),
        Text(text,
            style: AppTextStyles.titleLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count',
              style: AppTextStyles.labelSmall
                  .copyWith(color: color, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _empty(BuildContext context, String msg, {bool small = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(small ? 18 : 40),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(msg,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _PresentRow extends StatelessWidget {
  final AttendanceEntry entry;
  const _PresentRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.studentName,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                Text('Roll ${entry.rollNo}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.success),
              const SizedBox(width: 4),
              Text(entry.checkInTime,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _AbsentRow extends StatelessWidget {
  final AppStudent student;
  const _AbsentRow({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(student.initials,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.error)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                Text('Roll ${student.rollNo}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Absent',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
