import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/attendance_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/status_badge.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _monthIndex = 0;
  final List<String> _months = ['May 2024', 'Apr 2024', 'Mar 2024'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentStudent;
    final history = student?.attendanceHistory ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Monthly'),
            Tab(text: 'Summary'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyTab(history),
          _buildSummaryTab(student?.presentCount ?? 0,
              student?.absentCount ?? 0, student?.pendingCount ?? 0, history),
          _buildCalendarTab(),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab(List<AttendanceRecord> history) {
    return Column(
      children: [
        // Month navigation
        Container(
          color: Theme.of(context).cardTheme.color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: _monthIndex < _months.length - 1
                    ? () => setState(() => _monthIndex++)
                    : null,
                color: AppColors.primary,
              ),
              Text(_months[_monthIndex],
                  style: AppTextStyles.titleLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: _monthIndex > 0
                    ? () => setState(() => _monthIndex--)
                    : null,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
        Expanded(
          child: history.isEmpty
              ? Center(
                  child: Text('No records found.',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _attendanceListTile(context, history[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab(
      int present, int absent, int pending, List<AttendanceRecord> history) {
    return Column(
      children: [
        // Stats row
        Container(
          color: Theme.of(context).cardTheme.color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _statChip(context, '$present', 'Present', AppColors.success,
                  AppColors.successLight),
              const SizedBox(width: 10),
              _statChip(context, '$absent', 'Absent', AppColors.error,
                  AppColors.errorLight),
              const SizedBox(width: 10),
              _statChip(context, '$pending', 'Pending', AppColors.warning,
                  AppColors.warningLight),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _attendanceListTile(context, history[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarTab() {
    // Simplified calendar grid
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid (May 2024 starts on Wednesday = index 3)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final dayOffset = index - 2; // May starts Wed (index 3 = day 1)
              if (dayOffset < 1 || dayOffset > 31) {
                return const SizedBox();
              }
              Color? dotColor;
              if (dayOffset == 11) {
                dotColor = AppColors.warning;
              } else if (dayOffset % 7 == 0) {
                dotColor = AppColors.error;
              } else if (dayOffset <= 20) {
                dotColor = AppColors.success;
              }

              return Container(
                decoration: BoxDecoration(
                  color: dotColor?.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: dayOffset == 20
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$dayOffset',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: dotColor ??
                                  Theme.of(context).colorScheme.onSurface,
                              fontWeight: dayOffset == 20
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      if (dotColor != null)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                              color: dotColor, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calLegend(AppColors.success, 'Present'),
              const SizedBox(width: 16),
              _calLegend(AppColors.error, 'Absent'),
              const SizedBox(width: 16),
              _calLegend(AppColors.warning, 'Pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calLegend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _statChip(BuildContext context, String value, String label,
      Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.titleLarge.copyWith(
                    color: color, fontWeight: FontWeight.bold)),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _attendanceListTile(BuildContext context, AttendanceRecord record) {
    Color dotColor;
    BadgeType badgeType;
    switch (record.status) {
      case AttendanceStatus.present:
        dotColor = AppColors.success;
        badgeType = BadgeType.present;
        break;
      case AttendanceStatus.absent:
        dotColor = AppColors.error;
        badgeType = BadgeType.absent;
        break;
      case AttendanceStatus.pending:
        dotColor = AppColors.warning;
        badgeType = BadgeType.pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.date,
                    style: AppTextStyles.titleSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(record.day,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          StatusBadge(type: badgeType),
        ],
      ),
    );
  }
}
