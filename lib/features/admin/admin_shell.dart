import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav.dart';
import 'tabs/admin_home_tab.dart';
import 'tabs/admin_students_tab.dart';
import 'tabs/admin_attendance_tab.dart';
import 'tabs/admin_fees_tab.dart';
import 'tabs/admin_profile_tab.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  late final PageController _controller;

  static const _items = [
    BottomNavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
    BottomNavItem(Icons.groups_outlined, Icons.groups_rounded, 'Students'),
    BottomNavItem(
        Icons.fact_check_outlined, Icons.fact_check_rounded, 'Attendance'),
    BottomNavItem(
        Icons.payments_outlined, Icons.payments_rounded, 'Fees'),
    BottomNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _index = i);
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (i) => setState(() => _index = i),
        children: const [
          AdminHomeTab(),
          AdminStudentsTab(),
          AdminAttendanceTab(),
          AdminFeesTab(),
          AdminProfileTab(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _go,
        items: _items,
      ),
    );
  }
}
