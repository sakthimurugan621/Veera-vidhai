import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/admin_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/student/student_shell.dart';
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
                return _page(const SplashScreen());
              case AppRoutes.onboarding:
                return _page(const OnboardingScreen());
              case AppRoutes.roleSelection:
                return _page(const RoleSelectionScreen());
              case AppRoutes.login:
                return _page(const LoginScreen(), settings);
              case AppRoutes.adminDashboard:
                return _page(const AdminShell());
              case AppRoutes.studentDashboard:
                return _page(const StudentShell());
              default:
                return _page(const SplashScreen());
            }
          },
        );
      },
    );
  }

  MaterialPageRoute _page(Widget child, [RouteSettings? settings]) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
