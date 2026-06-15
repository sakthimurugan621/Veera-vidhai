import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/models/student_model.dart';
import 'features/admin/dashboard/admin_dashboard_screen.dart';
import 'features/admin/students/fees_detail_screen.dart';
import 'features/admin/students/student_detail_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/student/attendance/attendance_summary_screen.dart';
import 'features/student/attendance/mark_attendance_screen.dart';
import 'features/student/attendance/my_attendance_screen.dart';
import 'features/student/dashboard/student_dashboard_screen.dart';
import 'features/student/fees/fees_status_screen.dart';
import 'features/student/notifications/notifications_screen.dart';
import 'features/student/profile/profile_screen.dart';
import 'features/student/settings/settings_screen.dart';
import 'providers/theme_provider.dart';

class VeeraVidhaiApp extends StatelessWidget {
  const VeeraVidhaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Veera Vidhai',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.splash:
                return MaterialPageRoute(
                    builder: (_) => const SplashScreen());

              case AppRoutes.onboarding:
                return MaterialPageRoute(
                    builder: (_) => const OnboardingScreen());

              case AppRoutes.roleSelection:
                return MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen());

              case AppRoutes.login:
                return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                    settings: settings);

              case AppRoutes.signup:
                return MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                    settings: settings);

              case AppRoutes.adminDashboard:
                return MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen());

              case AppRoutes.studentDetail:
                final student = settings.arguments as Student;
                return MaterialPageRoute(
                    builder: (_) =>
                        StudentDetailScreen(student: student));

              case AppRoutes.feesDetail:
                final student = settings.arguments as Student;
                return MaterialPageRoute(
                    builder: (_) => FeesDetailScreen(student: student));

              case AppRoutes.studentDashboard:
                return MaterialPageRoute(
                    builder: (_) => const StudentDashboardScreen());

              case AppRoutes.markAttendance:
                return MaterialPageRoute(
                    builder: (_) => const MarkAttendanceScreen());

              case AppRoutes.myAttendance:
                return MaterialPageRoute(
                    builder: (_) => const MyAttendanceScreen());

              case AppRoutes.attendanceSummary:
                return MaterialPageRoute(
                    builder: (_) => const AttendanceSummaryScreen());

              case AppRoutes.feesStatus:
                return MaterialPageRoute(
                    builder: (_) => const FeesStatusScreen());

              case AppRoutes.profile:
                return MaterialPageRoute(
                    builder: (_) => const ProfileScreen());

              case AppRoutes.notifications:
                return MaterialPageRoute(
                    builder: (_) => const NotificationsScreen());

              case AppRoutes.settings:
                return MaterialPageRoute(
                    builder: (_) => const SettingsScreen());

              default:
                return MaterialPageRoute(
                    builder: (_) => const SplashScreen());
            }
          },
        );
      },
    );
  }
}
