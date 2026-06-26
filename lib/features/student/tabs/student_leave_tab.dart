import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/app_student.dart';
import '../../../data/models/leave_request.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';

class StudentLeaveTab extends StatefulWidget {
  final AppStudent student;
  const StudentLeaveTab({super.key, required this.student});

  @override
  State<StudentLeaveTab> createState() => _StudentLeaveTabState();
}

class _StudentLeaveTabState extends State<StudentLeaveTab> {
  final _fs = FirestoreService.instance;
  final _comments = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _leaveType;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _loading = false;

  static const _types = [
    'Sick Leave',
    'Personal',
    'Function / Event',
    'Travel',
    'Other',
  ];

  @override
  void dispose() {
    _comments.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = isFrom
        ? (_fromDate ?? now)
        : (_toDate ?? _fromDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        // keep To >= From
        if (_toDate != null && _toDate!.isBefore(picked)) _toDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _apply() async {
    if (!_formKey.currentState!.validate()) return;
    if (_leaveType == null) {
      _snack('Please select a leave type', AppColors.warning);
      return;
    }
    if (_fromDate == null || _toDate == null) {
      _snack('Please select From and To dates', AppColors.warning);
      return;
    }
    if (_toDate!.isBefore(_fromDate!)) {
      _snack('To date cannot be before From date', AppColors.warning);
      return;
    }
    setState(() => _loading = true);
    try {
      await _fs.applyLeave(
        student: widget.student,
        leaveType: _leaveType!,
        comments: _comments.text,
        fromDate: DateHelpers.prettyDate(_fromDate),
        toDate: DateHelpers.prettyDate(_toDate),
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _leaveType = null;
        _fromDate = null;
        _toDate = null;
        _comments.clear();
      });
      _formKey.currentState!.reset();
      _snack('Leave applied! Waiting for admin approval.', AppColors.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('Could not apply. Please try again.', AppColors.error);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const GradientHeader(
            tamilTitle: 'விடுப்பு',
            subtitle: 'Apply for Leave',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                // ── Apply form ──
                FadeSlideIn(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.event_busy_rounded,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Text('New Leave Request',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Name + Roll (read-only)
                          Row(
                            children: [
                              Expanded(
                                child: _readonly('Name', s.name,
                                    Icons.person_outline_rounded),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _readonly(
                                    'Roll No', s.rollNo, Icons.badge_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Leave type dropdown
                          Text('Leave Type',
                              style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _leaveType,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.category_outlined,
                                  size: 20, color: AppColors.textSecondary),
                            ),
                            hint: const Text('Select leave type'),
                            items: _types
                                .map((t) => DropdownMenuItem(
                                    value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => setState(() => _leaveType = v),
                          ),
                          const SizedBox(height: 16),
                          // Date range
                          Row(
                            children: [
                              Expanded(
                                child: _dateField(
                                  label: 'From Date',
                                  value: _fromDate,
                                  onTap: () => _pickDate(isFrom: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _dateField(
                                  label: 'To Date',
                                  value: _toDate,
                                  onTap: () => _pickDate(isFrom: false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Comments
                          Text('Reason / Comments',
                              style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _comments,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Why do you need leave?',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Please add a reason'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Apply for Leave',
                            prefixIcon: Icons.send_rounded,
                            onPressed: _loading ? null : _apply,
                            isLoading: _loading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── My applications ──
                Text('My Applications',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 12),
                StreamBuilder<List<LeaveRequest>>(
                  stream: _fs.studentLeavesStream(s.id),
                  builder: (context, snap) {
                    final leaves = snap.data ?? [];
                    if (leaves.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 40,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            Text('No leave applications yet',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: leaves
                          .asMap()
                          .entries
                          .map((e) => FadeSlideIn(
                                delayMs: 40 * e.key,
                                child: _LeaveCard(leave: e.value),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value != null ? DateHelpers.prettyDate(value) : 'Select',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: value != null
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _readonly(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  const _LeaveCard({required this.leave});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label, icon) = switch (leave.status) {
      'approved' => (
          AppColors.success,
          AppColors.successLight,
          'Approved',
          Icons.check_circle_rounded
        ),
      'declined' => (
          AppColors.error,
          AppColors.errorLight,
          'Declined',
          Icons.cancel_rounded
        ),
      _ => (
          AppColors.warning,
          AppColors.warningLight,
          'Pending',
          Icons.hourglass_top_rounded
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(leave.leaveType,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: color),
                    const SizedBox(width: 4),
                    Text(label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ],
          ),
          if (leave.dateRange.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded,
                      size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(leave.dateRange,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
          ],
          if (leave.comments.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(leave.comments,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                leave.createdAt != null
                    ? 'Applied ${DateHelpers.prettyDate(leave.createdAt)}'
                    : '—',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
