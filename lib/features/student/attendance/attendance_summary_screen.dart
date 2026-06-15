import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';

class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  String _selectedMonth = 'May 2024';
  final List<String> _months = ['May 2024', 'Apr 2024', 'Mar 2024', 'Feb 2024'];

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentStudent;
    final present = student?.presentCount ?? 0;
    final absent = student?.absentCount ?? 0;
    final pending = student?.pendingCount ?? 0;
    final total = student?.totalWorkingDays ?? 0;
    final pct = student?.attendancePercentage ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  isExpanded: true,
                  style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                  items: _months
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedMonth = v!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pie chart card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Text('$_selectedMonth Overview',
                      style: AppTextStyles.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 55,
                                sections: [
                                  PieChartSectionData(
                                    value: present.toDouble(),
                                    color: AppColors.success,
                                    radius: 30,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: absent.toDouble(),
                                    color: AppColors.error,
                                    radius: 30,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    value: pending.toDouble(),
                                    color: AppColors.warning,
                                    radius: 30,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$total',
                                    style: AppTextStyles.headlineLarge.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.bold)),
                                Text('Total Days',
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _legendItem(context, AppColors.success, 'Present',
                                present, total),
                            const SizedBox(height: 12),
                            _legendItem(context, AppColors.error, 'Absent',
                                absent, total),
                            const SizedBox(height: 12),
                            _legendItem(context, AppColors.warning, 'Pending',
                                pending, total),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details',
                      style: AppTextStyles.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 16),
                  _detailRow(context, 'Total Working Days', '$total',
                      Theme.of(context).colorScheme.onSurface, null),
                  _detailRow(context, 'Present Days', '$present',
                      AppColors.success, AppColors.success),
                  _detailRow(context, 'Absent Days', '$absent',
                      AppColors.error, AppColors.error),
                  _detailRow(context, 'Pending Days', '$pending',
                      AppColors.warning, AppColors.warning),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Attendance Percentage',
                          style: AppTextStyles.titleMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface)),
                      Text('${pct.toStringAsFixed(1)}%',
                          style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(
      BuildContext context, Color color, String label, int count, int total) {
    final pct = total == 0 ? 0.0 : (count / total) * 100;
    return Row(
      children: [
        Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary)),
              Text('$count  (${pct.toStringAsFixed(0)}%)',
                  style: AppTextStyles.labelMedium.copyWith(
                      color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, String value,
      Color valueColor, Color? dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (dotColor != null) ...[
            Container(
                width: 10, height: 10,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 10),
          ] else
            const SizedBox(width: 20),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7))),
          ),
          Text(value,
              style: AppTextStyles.titleSmall.copyWith(
                  color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
