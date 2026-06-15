import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/student_card.dart';
import '../../../core/routes/app_routes.dart';
import '../students/fees_detail_screen.dart';
import '../../../widgets/status_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  int get _presentCount => DummyData.students.where((s) => s.isPresent).length;
  int get _absentCount => DummyData.students.where((s) => !s.isPresent).length;
  int get _feesPaidCount => DummyData.students.where((s) => s.feesPaid).length;
  int get _feesNotPaidCount => DummyData.students.where((s) => !s.feesPaid).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildAttendanceTab(),
          _buildFeesTab(),
          _buildReportsTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Attendance'),
          BottomNavigationBarItem(
              icon: Icon(Icons.currency_rupee_outlined),
              activeIcon: Icon(Icons.currency_rupee_rounded),
              label: 'Fees'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                label: 'Present',
                count: '$_presentCount',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                lightColor: AppColors.successLight,
              ),
              StatCard(
                label: 'Absent',
                count: '$_absentCount',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                lightColor: AppColors.errorLight,
              ),
              StatCard(
                label: 'Fees Paid',
                count: '$_feesPaidCount',
                icon: Icons.currency_rupee_rounded,
                color: AppColors.warning,
                lightColor: AppColors.warningLight,
              ),
              StatCard(
                label: 'Fees Not Paid',
                count: '$_feesNotPaidCount',
                icon: Icons.money_off_rounded,
                color: const Color(0xFF7C3AED),
                lightColor: const Color(0xFFEDE9FE),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Students (${DummyData.students.length})',
                style: AppTextStyles.titleLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...DummyData.students.map((student) => StudentCard(
                student: student,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.studentDetail,
                  arguments: student,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Attendance',
              style: AppTextStyles.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...DummyData.students.map((student) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(student.initials,
                            style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface)),
                          Text('Roll: ${student.rollNo}',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    StatusBadge(
                      type: student.isPresent ? BadgeType.present : BadgeType.absent,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fees Overview',
              style: AppTextStyles.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...DummyData.students.map((student) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeesDetailScreen(student: student),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(student.initials,
                              style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name,
                                style: AppTextStyles.titleMedium.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface)),
                            Text('Roll: ${student.rollNo}  |  Total: ₹${student.totalFees.toInt()}',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      StatusBadge(
                        type: student.feesPaid ? BadgeType.paid : BadgeType.notPaid,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    final totalStudents = DummyData.students.length;
    final avgAttendance = DummyData.students
            .map((s) => s.attendancePercentage)
            .reduce((a, b) => a + b) /
        totalStudents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports',
              style: AppTextStyles.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 20),
          _reportTile('Total Students', '$totalStudents',
              Icons.people_outline_rounded, AppColors.primary),
          const SizedBox(height: 12),
          _reportTile('Present Today', '$_presentCount',
              Icons.check_circle_outline_rounded, AppColors.success),
          const SizedBox(height: 12),
          _reportTile('Absent Today', '$_absentCount',
              Icons.cancel_outlined, AppColors.error),
          const SizedBox(height: 12),
          _reportTile('Fees Collected',
              '₹${(_feesPaidCount * 10000).toInt()}',
              Icons.currency_rupee_rounded, AppColors.warning),
          const SizedBox(height: 12),
          _reportTile('Avg Attendance',
              '${avgAttendance.toStringAsFixed(1)}%',
              Icons.bar_chart_rounded, AppColors.primary),
        ],
      ),
    );
  }

  Widget _reportTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          Text(value,
              style: AppTextStyles.titleLarge.copyWith(
                  color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                size: 46, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('Administrator',
              style: AppTextStyles.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('admin@veeravidhai.com',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          _profileOption(Icons.settings_outlined, 'Settings', () {}),
          _profileOption(Icons.help_outline_rounded, 'Help & Support', () {}),
          _profileOption(Icons.info_outline_rounded, 'About App', () {}),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.roleSelection),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label,
          style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
