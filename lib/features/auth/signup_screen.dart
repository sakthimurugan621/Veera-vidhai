import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreeTerms = false;

  // Common controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Teacher-specific
  final _teacherIdController = TextEditingController();
  final _departmentController = TextEditingController();
  String? _selectedSubject;

  // Student-specific
  final _rollNoController = TextEditingController();
  String? _selectedClass;
  String? _selectedDob;
  String? _selectedGender;

  late String _role;

  final List<String> _subjects = ['Silambam', 'Kalaripayattu', 'Physical Education', 'Other'];
  final List<String> _classes = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = ModalRoute.of(context)?.settings.arguments as String? ?? 'student';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _teacherIdController.dispose();
    _departmentController.dispose();
    _rollNoController.dispose();
    super.dispose();
  }

  bool get _isTeacher => _role == 'admin';

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isTeacher && !_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms & Conditions.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account created! Please login.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.login, arguments: _role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isTeacher ? 'Teacher Registration' : 'Student Registration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isTeacher) ..._buildTeacherForm()
                else ..._buildStudentForm(),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Create Account',
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                  backgroundColor: _isTeacher ? AppColors.primary : AppColors.success,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.login, arguments: _role),
                        child: Text(
                          'Login',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTeacherForm() {
    return [
      _sectionTitle('Personal Information'),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Full Name', hint: 'Enter your full name',
          controller: _nameController, prefixIcon: Icons.person_outline,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Email Address', hint: 'Enter your email',
          controller: _emailController, prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Phone Number', hint: 'Enter phone number',
          controller: _phoneController, prefixIcon: Icons.phone_outlined,
          prefixText: '+91 ', keyboardType: TextInputType.phone,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 28),
      _sectionTitle('Professional Information'),
      const SizedBox(height: 16),
      _buildDropdown('Subject', _subjects, _selectedSubject,
          (v) => setState(() => _selectedSubject = v)),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Department (Optional)', hint: 'Enter department',
          controller: _departmentController, prefixIcon: Icons.business_outlined),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Teacher ID', hint: 'Enter your teacher ID',
          controller: _teacherIdController, prefixIcon: Icons.badge_outlined,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 28),
      _sectionTitle('Account Security'),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Password', hint: 'Create a password',
          controller: _passwordController, prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          }),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Confirm Password', hint: 'Confirm your password',
          controller: _confirmPasswordController, prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          }),
    ];
  }

  List<Widget> _buildStudentForm() {
    return [
      _sectionTitle('Personal Information'),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Full Name', hint: 'Enter your full name',
          controller: _nameController, prefixIcon: Icons.person_outline,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Roll Number', hint: 'Enter your roll number',
          controller: _rollNoController, prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      _buildDropdown('Class / Year', _classes, _selectedClass,
          (v) => setState(() => _selectedClass = v)),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Email Address', hint: 'Enter your email',
          controller: _emailController, prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Phone Number', hint: 'Enter phone number',
          controller: _phoneController, prefixIcon: Icons.phone_outlined,
          prefixText: '+91 ', keyboardType: TextInputType.phone,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      _buildDropdown(
          'Date of Birth',
          ['2003', '2004', '2005', '2006', '2007', '2008'],
          _selectedDob,
          (v) => setState(() => _selectedDob = v)),
      const SizedBox(height: 16),
      _buildDropdown('Gender', _genders, _selectedGender,
          (v) => setState(() => _selectedGender = v)),
      const SizedBox(height: 28),
      _sectionTitle('Account Security'),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Password', hint: 'Create a password',
          controller: _passwordController, prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          }),
      const SizedBox(height: 16),
      CustomTextField(
          label: 'Confirm Password', hint: 'Confirm your password',
          controller: _confirmPasswordController, prefixIcon: Icons.lock_outline,
          isPassword: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          }),
      const SizedBox(height: 8),
      Text(
        'Password must be at least 6 characters',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _agreeTerms = !_agreeTerms),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    text: 'I agree to ',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text('Select $label',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
