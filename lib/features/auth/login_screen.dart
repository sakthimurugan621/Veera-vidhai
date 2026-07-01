import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/responsive_center.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController(); // email (admin) / phone (student)
  final _passwordController = TextEditingController();

  late String _role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = ModalRoute.of(context)?.settings.arguments as String? ?? 'student';
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isAdmin => _role == 'admin';

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    final role = _isAdmin
        ? await auth.loginAdmin(
            _idController.text.trim(), _passwordController.text)
        : await auth.loginStudent(
            _idController.text.trim(), _passwordController.text);

    if (!mounted) return;
    if (role == 'admin') {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.teamSelect, (_) => false);
    } else if (role == 'student') {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.studentDashboard, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          GradientHeader(
            tamilTitle: _isAdmin ? 'நிர்வாக நுழைவு' : 'மாணவர் நுழைவு',
            subtitle: _isAdmin ? 'Admin Login' : 'Student Login',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ResponsiveCenter(
                maxWidth: 460,
                child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    FadeSlideIn(
                      child: Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLight,
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.25),
                                width: 2),
                          ),
                          child: Icon(
                            _isAdmin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.school_rounded,
                            color: AppColors.primary,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delayMs: 80,
                      child: Text('Welcome back!',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                    ),
                    const SizedBox(height: 6),
                    FadeSlideIn(
                      delayMs: 120,
                      child: Text(
                        _isAdmin
                            ? 'Login with your admin email'
                            : 'Login with your phone number',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 32),

                    FadeSlideIn(
                      delayMs: 180,
                      child: CustomTextField(
                        label: _isAdmin ? 'Email Address' : 'Phone Number',
                        hint: _isAdmin
                            ? 'Enter your email'
                            : 'Enter your phone number',
                        controller: _idController,
                        prefixIcon: _isAdmin
                            ? Icons.email_outlined
                            : Icons.phone_outlined,
                        keyboardType: _isAdmin
                            ? TextInputType.emailAddress
                            : TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return _isAdmin
                                ? 'Please enter your email'
                                : 'Please enter your phone number';
                          }
                          if (_isAdmin && !v.contains('@')) {
                            return 'Enter a valid email';
                          }
                          if (!_isAdmin && v.trim().length < 10) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    FadeSlideIn(
                      delayMs: 240,
                      child: CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                    ),

                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(auth.errorMessage!,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.error)),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.read<AuthProvider>().clearError(),
                              child: const Icon(Icons.close_rounded,
                                  color: AppColors.error, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                    FadeSlideIn(
                      delayMs: 300,
                      child: CustomButton(
                        label: 'Login',
                        onPressed: auth.isLoading ? null : _handleLogin,
                        isLoading: auth.isLoading,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        _isAdmin
                            ? 'Contact support if you forgot your password'
                            : 'Contact your admin for login details',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
