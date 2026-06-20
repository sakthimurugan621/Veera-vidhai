import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_student.dart';
import '../../data/services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_header.dart';

/// Add or edit a student. Pass [existing] to edit.
class StudentFormScreen extends StatefulWidget {
  final AppStudent? existing;
  const StudentFormScreen({super.key, this.existing});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _rollNo = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _address = TextEditingController();
  final _feeAmount = TextEditingController();
  String _className = 'Silambam Beginner';
  bool _loading = false;

  static const _classes = [
    'Silambam Beginner',
    'Silambam Intermediate',
    'Silambam Advanced',
  ];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      _rollNo.text = e.rollNo;
      _phone.text = e.phone;
      _password.text = e.password;
      _address.text = e.address;
      _feeAmount.text = e.feeAmount.toInt().toString();
      _className = _classes.contains(e.className) ? e.className : _classes.first;
    } else {
      _feeAmount.text = '500';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _rollNo.dispose();
    _phone.dispose();
    _password.dispose();
    _address.dispose();
    _feeAmount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final fs = FirestoreService.instance;
    final fee = double.tryParse(_feeAmount.text.trim()) ?? 500;

    try {
      if (_isEdit) {
        final updated = widget.existing!.copyWith(
          name: _name.text.trim(),
          rollNo: _rollNo.text.trim(),
          phone: _phone.text.trim(),
          password: _password.text.trim(),
          address: _address.text.trim(),
          className: _className,
          feeAmount: fee,
        );
        await fs.updateStudent(updated);
      } else {
        await fs.addStudent(
          name: _name.text.trim(),
          rollNo: _rollNo.text.trim(),
          phone: _phone.text.trim(),
          password: _password.text.trim(),
          address: _address.text.trim(),
          className: _className,
          feeAmount: fee,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        _snack(_isEdit ? 'Student updated' : 'Student registered',
            AppColors.success),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _loading = false);
      String msg;
      if (err == 'phone-exists') {
        msg = 'This phone number is already registered.';
      } else if (err == 'roll-exists') {
        msg = 'This roll number is already registered.';
      } else if (err is FirebaseException) {
        // Surface the real cause (e.g. permission-denied → fix Firestore rules)
        msg = 'Firestore error: ${err.code}. ${err.message ?? ''}';
      } else {
        msg = 'Could not save: $err';
      }
      ScaffoldMessenger.of(context).showSnackBar(_snack(msg, AppColors.error));
    }
  }

  SnackBar _snack(String msg, Color color) => SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          GradientHeader(
            tamilTitle: _isEdit ? 'மாணவர் திருத்து' : 'புதிய மாணவர்',
            subtitle: _isEdit ? 'Edit Student' : 'Register Student',
            trailing: HeaderIconButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter student name',
                      controller: _name,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Roll Number',
                      hint: 'e.g. 101',
                      controller: _rollNo,
                      prefixIcon: Icons.badge_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Roll number required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      hint: '10-digit mobile number',
                      controller: _phone,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Phone required';
                        }
                        if (v.trim().length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Login Password',
                      hint: 'Set a password for the student',
                      controller: _password,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Password required';
                        }
                        if (v.trim().length < 4) {
                          return 'Minimum 4 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _classDropdown(context),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Monthly Fee (₹)',
                      hint: 'e.g. 500',
                      controller: _feeAmount,
                      prefixIcon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Fee required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Address',
                      hint: 'Enter address',
                      controller: _address,
                      prefixIcon: Icons.home_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      label: _isEdit ? 'Save Changes' : 'Register Student',
                      onPressed: _loading ? null : _save,
                      isLoading: _loading,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _classDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Class',
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _className,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.school_outlined,
                color: AppColors.textSecondary, size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: _classes
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _className = v ?? _classes.first),
        ),
      ],
    );
  }
}
