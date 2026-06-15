import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/attendance_model.dart';
import '../../../widgets/status_badge.dart';
import 'fees_detail_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.name,
                    style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Roll No: ${student.rollNo}',
                      style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admission Date: ${student.admissionDate}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _miniStatCard(context, '${student.presentCount}', 'Present',
                      AppColors.success, AppColors.successLight),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStatCard(context, '${student.absentCount}', 'Absent',
                      AppColors.error, AppColors.errorLight),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStatCard(context,
                      '${student.attendancePercentage.toStringAsFixed(0)}%',
                      'Attendance', AppColors.primary, AppColors.primaryLight),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Details card
            _sectionCard(
              context,
              'Student Information',
              [
                _detailRow(context, Icons.badge_outlined, 'Roll No', student.rollNo),
                _detailRow(context, Icons.person_outline, 'Name', student.name),
                _detailRow(context, Icons.class_outlined, 'Class', student.className),
                _detailRow(context, Icons.phone_outlined, 'Phone', student.phone),
                _detailRow(context, Icons.email_outlined, 'Email', student.email),
                _detailRow(context, Icons.cake_outlined, 'Date of Birth', student.dateOfBirth),
                _detailRow(context, Icons.wc_outlined, 'Gender', student.gender),
                _detailRow(context, Icons.location_on_outlined, 'Address', student.address),
                _statusRow(context, 'Attendance Status',
                    student.isPresent ? BadgeType.present : BadgeType.absent),
                if (student.isPresent && student.checkInTime != null)
                  _detailRow(context, Icons.access_time_rounded,
                      'Check-in Time', student.checkInTime!),
                _statusRow(context, 'Fees Status',
                    student.feesPaid ? BadgeType.paid : BadgeType.notPaid),
              ],
            ),
            const SizedBox(height: 16),

            // Fees quick action
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FeesDetailScreen(student: student)),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: student.feesPaid
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: student.feesPaid
                        ? AppColors.success
                        : AppColors.error,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.currency_rupee_rounded,
                      color: student.feesPaid ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.feesPaid ? 'Fees Paid' : 'Fees Pending',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: student.feesPaid
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          Text(
                            student.feesPaid
                                ? 'All fees have been paid.'
                                : '₹${student.dueFees.toInt()} is pending.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: student.feesPaid
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: student.feesPaid ? AppColors.success : AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attendance History
            _buildAttendanceHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistory(BuildContext context) {
    final history = student.attendanceHistory.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance History',
              style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          ...history.map((record) => _attendanceRow(context, record)),
          const Divider(height: 20),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('View All',
                    style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceRow(BuildContext context, AttendanceRecord record) {
    Color dotColor;
    switch (record.status) {
      case AttendanceStatus.present:
        dotColor = AppColors.success;
        break;
      case AttendanceStatus.absent:
        dotColor = AppColors.error;
        break;
      case AttendanceStatus.pending:
        dotColor = AppColors.warning;
        break;
    }

    String statusLabel;
    switch (record.status) {
      case AttendanceStatus.present:
        statusLabel = 'Present';
        break;
      case AttendanceStatus.absent:
        statusLabel = 'Absent';
        break;
      case AttendanceStatus.pending:
        statusLabel = 'Pending';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${record.date}  •  ${record.day}',
              style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          Text(
            statusLabel,
            style: AppTextStyles.labelSmall.copyWith(
                color: dotColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard(BuildContext context, String value, String label,
      Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headlineMedium.copyWith(
                  color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.labelSmall.copyWith(color: color),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(BuildContext context, String label, BadgeType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          const Icon(Icons.circle_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary)),
          ),
          StatusBadge(type: type),
        ],
      ),
    );
  }
}
