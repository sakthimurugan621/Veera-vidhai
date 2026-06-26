import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_student.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import 'tabs/student_home_tab.dart';
import 'tabs/student_attendance_tab.dart';
import 'tabs/student_leave_tab.dart';
import 'tabs/student_fees_tab.dart';
import 'tabs/student_profile_tab.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;
  late final PageController _controller;

  static const _items = [
    BottomNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    BottomNavItem(
        Icons.fact_check_outlined, Icons.fact_check_rounded, 'Attendance'),
    BottomNavItem(
        Icons.event_busy_outlined, Icons.event_busy_rounded, 'Leave'),
    BottomNavItem(Icons.payments_outlined, Icons.payments_rounded, 'Fees'),
    BottomNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    final id = context.read<AuthProvider>().studentId;
    if (id != null) {
      NotificationService.instance.startStudentListeners(id);
    }
  }

  @override
  void dispose() {
    NotificationService.instance.stopListeners();
    _controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _index = i);
    _controller.animateToPage(i,
        duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final studentId = context.read<AuthProvider>().studentId;
    if (studentId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: StreamBuilder<AppStudent?>(
        stream: FirestoreService.instance.studentStream(studentId),
        builder: (context, snap) {
          final student = snap.data;
          if (student == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            children: [
              StudentHomeTab(student: student),
              StudentAttendanceTab(student: student),
              StudentLeaveTab(student: student),
              StudentFeesTab(student: student),
              StudentProfileTab(student: student),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: _go,
        items: _items,
      ),
    );
  }
}
