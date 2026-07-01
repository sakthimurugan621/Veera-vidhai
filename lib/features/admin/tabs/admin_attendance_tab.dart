import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/app_student.dart';
import '../../../data/models/attendance_entry.dart';
import '../../../data/services/firestore_service.dart';
import '../../../providers/team_provider.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';
import '../student_attendance_detail.dart';

class AdminAttendanceTab extends StatefulWidget {
  const AdminAttendanceTab({super.key});

  @override
  State<AdminAttendanceTab> createState() => _AdminAttendanceTabState();
}

class _AdminAttendanceTabState extends State<AdminAttendanceTab> {
  final _fs = FirestoreService.instance;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
  }

  bool get _isToday {
    final n = DateTime.now();
    return _selected.year == n.year &&
        _selected.month == n.month &&
        _selected.day == n.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selected = picked);
  }

  Future<void> _setPresent(AppStudent s, String date) async {
    await _fs.markPresent(
      student: s,
      date: date,
      checkInTime: DateHelpers.nowTime(),
      markedBy: 'admin',
    );
  }

  Future<void> _setAbsent(AppStudent s, String date) async {
    await _fs.markAbsent(student: s, date: date, markedBy: 'admin');
  }

  void _openDetail(AppStudent s) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentAttendanceDetail(student: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamId = context.watch<TeamProvider>().activeTeamId;
    final dateKey = DateHelpers.todayKey(_selected);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<AppStudent>>(
        stream: _fs.studentsStream(teamId: teamId),
        builder: (context, studentSnap) {
          final students = studentSnap.data ?? [];
          return StreamBuilder<List<AttendanceEntry>>(
            stream: _fs.attendanceForDateStream(dateKey, teamId: teamId),
            builder: (context, attSnap) {
              final entries = attSnap.data ?? [];
              final entryById = <String, AttendanceEntry>{
                for (final e in entries) e.studentId: e,
              };
              final presentCount =
                  entryById.values.where((e) => e.isPresent).length;
              final absentCount =
                  entryById.values.where((e) => e.isAbsent).length;
              final unmarked = students.length - entryById.length;

              return Column(
                children: [
                  GradientHeader(
                    tamilTitle: 'வருகை',
                    subtitle: _isToday ? 'Today — tap to mark' : 'Mark attendance',
                    trailing: _DatePickerChip(
                      date: DateHelpers.prettyDate(_selected),
                      onTap: _pickDate,
                    ),
                    bottom: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: _miniStat('Present', presentCount,
                                  Icons.check_circle_rounded)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _miniStat('Absent', absentCount,
                                  Icons.cancel_rounded)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _miniStat('Left', unmarked < 0 ? 0 : unmarked,
                                  Icons.pending_rounded)),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: students.isEmpty
                        ? _empty(context)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                            itemCount: students.length,
                            itemBuilder: (context, i) {
                              final s = students[i];
                              final entry = entryById[s.id];
                              return FadeSlideIn(
                                delayMs: 30 * (i % 14),
                                child: _StudentAttendanceRow(
                                  student: s,
                                  status: entry?.status,
                                  // Student self-reported absence is locked.
                                  lockedAbsent: entry != null &&
                                      entry.isAbsent &&
                                      entry.markedBy == 'student',
                                  onPresent: () => _setPresent(s, dateKey),
                                  onAbsent: () => _setAbsent(s, dateKey),
                                  onTapName: () => _openDetail(s),
                                ),
                              );
                            },
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

  Widget _miniStat(String label, int value, IconData icon) {
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

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined,
              size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('No students in this team',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _StudentAttendanceRow extends StatelessWidget {
  final AppStudent student;
  final String? status; // 'present' | 'absent' | null
  final bool lockedAbsent; // student self-reported absent → not editable
  final VoidCallback onPresent;
  final VoidCallback onAbsent;
  final VoidCallback onTapName;

  const _StudentAttendanceRow({
    required this.student,
    required this.status,
    this.lockedAbsent = false,
    required this.onPresent,
    required this.onAbsent,
    required this.onTapName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
          GestureDetector(
            onTap: onTapName,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(student.initials,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTapName,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                  Text('Roll ${student.rollNo} • view schedule',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          // Student self-reported absent → locked badge. Else editable toggle.
          if (lockedAbsent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_rounded,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 5),
                  Text('Absent',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            )
          else ...[
            _toggle(
              icon: Icons.check_rounded,
              selected: status == 'present',
              color: AppColors.success,
              onTap: onPresent,
            ),
            const SizedBox(width: 8),
            _toggle(
              icon: Icons.close_rounded,
              selected: status == 'absent',
              color: AppColors.error,
              onTap: onAbsent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _toggle({
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: selected ? 0 : 1.2),
        ),
        child: Icon(icon, color: selected ? Colors.white : color, size: 22),
      ),
    );
  }
}

class _DatePickerChip extends StatelessWidget {
  final String date;
  final VoidCallback onTap;
  const _DatePickerChip({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(date,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
            const Icon(Icons.arrow_drop_down_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
