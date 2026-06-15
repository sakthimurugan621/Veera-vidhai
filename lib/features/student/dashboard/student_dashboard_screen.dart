import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/student_model.dart';
import '../../../providers/auth_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentStudent;
    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        children: [
          _HomeTab(student: student),
          _AttendanceTab(student: student),
          _FeesTab(student: student),
          _ReportsTab(student: student),
          _ProfileTab(student: student),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_rupee_outlined),
            activeIcon: Icon(Icons.currency_rupee_rounded),
            label: 'Fees',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Live Clock ───────────────────────────────────────────────────────────────
class _LiveClock extends StatefulWidget {
  const _LiveClock();
  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeStr {
    final h = _now.hour > 12
        ? _now.hour - 12
        : (_now.hour == 0 ? 12 : _now.hour);
    final m = _now.minute.toString().padLeft(2, '0');
    return '${h.toString().padLeft(2, '0')}:$m';
  }

  String get _secondStr => _now.second.toString().padLeft(2, '0');
  String get _period => _now.hour >= 12 ? 'PM' : 'AM';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _timeStr,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: ':$_secondStr',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        Text(
          _period,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD97706),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Slide to Check In ────────────────────────────────────────────────────────
class _SlideToCheckIn extends StatefulWidget {
  final bool alreadyCheckedIn;
  final String? checkInTime;
  final void Function(String time) onCheckIn;

  const _SlideToCheckIn({
    required this.alreadyCheckedIn,
    this.checkInTime,
    required this.onCheckIn,
  });

  @override
  State<_SlideToCheckIn> createState() => _SlideToCheckInState();
}

class _SlideToCheckInState extends State<_SlideToCheckIn>
    with SingleTickerProviderStateMixin {
  double _dragPos = 0.0;
  bool _confirmed = false;
  late AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  static const double _thumb = 56.0;

  @override
  void initState() {
    super.initState();
    _confirmed = widget.alreadyCheckedIn;
    _snapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _snapAnim = const AlwaysStoppedAnimation(0.0);
    _snapCtrl.addListener(() {
      if (!_confirmed && mounted) setState(() => _dragPos = _snapAnim.value);
    });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d, double max) {
    if (_confirmed) return;
    setState(() => _dragPos = (_dragPos + d.delta.dx).clamp(0.0, max));
  }

  void _end(DragEndDetails d, double max) {
    if (_confirmed) return;
    if (_dragPos >= max * 0.75) {
      final n = DateTime.now();
      final h = n.hour > 12 ? n.hour - 12 : (n.hour == 0 ? 12 : n.hour);
      final m = n.minute.toString().padLeft(2, '0');
      final t = '${h.toString().padLeft(2, '0')}:$m ${n.hour >= 12 ? 'PM' : 'AM'}';
      setState(() {
        _dragPos = max;
        _confirmed = true;
      });
      widget.onCheckIn(t);
    } else {
      _snapAnim = Tween<double>(begin: _dragPos, end: 0.0).animate(
        CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOut),
      );
      _snapCtrl.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final max = constraints.maxWidth - _thumb - 8;
        final progress = max > 0 ? (_dragPos / max).clamp(0.0, 1.0) : 0.0;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: _confirmed
                  ? [const Color(0xFF15803D), AppColors.success]
                  : [AppColors.primaryDark, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: (_confirmed ? AppColors.success : AppColors.primary)
                    .withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Label
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: _confirmed ? 1.0 : (1.0 - progress * 0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 48),
                        Text(
                          _confirmed
                              ? 'Checked In  ${widget.checkInTime ?? ''} ✓'
                              : 'Swipe to Check In',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_confirmed) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white70, size: 18),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Thumb
              Positioned(
                left: _confirmed ? max : _dragPos + 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _update(d, max),
                  onHorizontalDragEnd: (d) => _end(d, max),
                  child: Container(
                    width: _thumb,
                    height: _thumb,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Icon(
                      _confirmed
                          ? Icons.check_rounded
                          : Icons.chevron_right_rounded,
                      color: _confirmed ? AppColors.success : AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final Student student;
  const _HomeTab({required this.student});
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _checkedIn = false;
  String? _checkInTime;

  @override
  void initState() {
    super.initState();
    _checkedIn = widget.student.isPresent;
    _checkInTime = widget.student.checkInTime;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Header with live clock ──
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
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Name + Roll No
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hi, ${s.name.split(' ').first} 👋',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Roll No. ${s.rollNo}  •  ${s.className}',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Live clock
                    const _LiveClock(),
                    const SizedBox(width: 12),
                    // Bell
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.notifications),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + Fees row
                  Row(
                    children: [
                      Expanded(child: _statusCard(context, s)),
                      const SizedBox(width: 12),
                      Expanded(child: _feesCard(context, s)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.65,
                    children: [
                      _quickAction(
                        context,
                        Icons.assignment_turned_in_outlined,
                        'Mark\nAttendance',
                        AppColors.primary,
                        AppColors.primaryLight,
                        () => Navigator.pushNamed(
                            context, AppRoutes.markAttendance),
                      ),
                      _quickAction(
                        context,
                        Icons.calendar_month_outlined,
                        'My\nAttendance',
                        AppColors.success,
                        AppColors.successLight,
                        () => Navigator.pushNamed(
                            context, AppRoutes.myAttendance),
                      ),
                      _quickAction(
                        context,
                        Icons.currency_rupee_rounded,
                        'Fees\nStatus',
                        AppColors.warning,
                        AppColors.warningLight,
                        () => Navigator.pushNamed(
                            context, AppRoutes.feesStatus),
                      ),
                      _quickAction(
                        context,
                        Icons.person_outline_rounded,
                        'My\nProfile',
                        const Color(0xFF7C3AED),
                        const Color(0xFFEDE9FE),
                        () => Navigator.pushNamed(context, AppRoutes.profile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Attendance Overview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Attendance Overview',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.attendanceSummary),
                        child: Text(
                          'View Details',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _attendanceChart(context, s),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Slide to Check In ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
            child: _SlideToCheckIn(
              alreadyCheckedIn: _checkedIn,
              checkInTime: _checkInTime,
              onCheckIn: (t) {
                setState(() {
                  _checkedIn = true;
                  _checkInTime = t;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Attendance marked at $t'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(BuildContext context, Student s) {
    final color = _checkedIn ? AppColors.success : AppColors.error;
    final bg = _checkedIn ? AppColors.successLight : AppColors.errorLight;
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
                _checkedIn
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text('Today',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _checkedIn ? 'Present' : 'Absent',
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _checkInTime != null ? 'At $_checkInTime' : 'Not marked',
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _feesCard(BuildContext context, Student s) {
    final color = s.feesPaid ? AppColors.success : AppColors.error;
    final bg = s.feesPaid ? AppColors.successLight : AppColors.errorLight;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.feesStatus),
      child: Container(
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
            Text(
              s.feesPaid ? 'Paid' : 'Pending',
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${s.totalFees.toInt()}',
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attendanceChart(BuildContext context, Student s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: [
                      PieChartSectionData(
                          value: s.presentCount.toDouble(),
                          color: AppColors.success,
                          radius: 18,
                          showTitle: false),
                      PieChartSectionData(
                          value: s.absentCount.toDouble(),
                          color: AppColors.error,
                          radius: 18,
                          showTitle: false),
                      PieChartSectionData(
                          value: s.pendingCount.toDouble(),
                          color: AppColors.warning,
                          radius: 18,
                          showTitle: false),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${s.totalWorkingDays}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Days',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legend(context, AppColors.success, 'Present', s.presentCount),
                const SizedBox(height: 10),
                _legend(context, AppColors.error, 'Absent', s.absentCount),
                const SizedBox(height: 10),
                _legend(context, AppColors.warning, 'Pending', s.pendingCount),
                const SizedBox(height: 10),
                Text(
                  '${s.attendancePercentage.toStringAsFixed(0)}% Attendance',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, Color c, String label, int count) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: AppTextStyles.bodySmall
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              decoration:
                  BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attendance Tab ────────────────────────────────────────────────────────────
class _AttendanceTab extends StatelessWidget {
  final Student student;
  const _AttendanceTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_outlined,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Attendance', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.markAttendance),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Mark Attendance'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.myAttendance),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('View My Attendance'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fees Tab ──────────────────────────────────────────────────────────────────
class _FeesTab extends StatelessWidget {
  final Student student;
  const _FeesTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              student.feesPaid
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              size: 72,
              color: student.feesPaid ? AppColors.success : AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              student.feesPaid ? 'All Fees Paid!' : 'Fees Pending',
              style: AppTextStyles.headlineMedium.copyWith(
                color: student.feesPaid ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              student.feesPaid
                  ? 'Annual fees ₹${student.totalFees.toInt()} is fully paid.'
                  : '₹${student.dueFees.toInt()} is pending. Please pay soon.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.feesStatus),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Full Details'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reports Tab ───────────────────────────────────────────────────────────────
class _ReportsTab extends StatelessWidget {
  final Student student;
  const _ReportsTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart_rounded,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Reports', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.attendanceSummary),
                icon: const Icon(Icons.pie_chart_outline_rounded),
                label: const Text('Attendance Summary'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final Student student;
  const _ProfileTab({required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.primaryLight),
              child: Center(
                child: Text(
                  student.initials,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(student.name,
                style: AppTextStyles.headlineMedium
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Roll No. ${student.rollNo}',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
            ),
            const SizedBox(height: 4),
            Text(student.className,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.profile),
              icon: const Icon(Icons.person_outline),
              label: const Text('View Full Profile'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.settings),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Settings'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
