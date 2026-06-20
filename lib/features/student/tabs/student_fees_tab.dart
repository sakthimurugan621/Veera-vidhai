import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_student.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';

class StudentFeesTab extends StatelessWidget {
  final AppStudent student;
  const StudentFeesTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final paid = student.feesPaid;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const GradientHeader(
            tamilTitle: 'கட்டணம்',
            subtitle: 'My Fees',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                // Big status card
                FadeSlideIn(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: paid
                            ? [const Color(0xFF15803D), AppColors.success]
                            : [AppColors.primaryDark, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (paid ? AppColors.success : AppColors.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            paid
                                ? Icons.check_circle_rounded
                                : Icons.pending_actions_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(paid ? 'Fees Paid' : 'Fees Pending',
                            style: AppTextStyles.headlineMedium
                                .copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('₹${student.feeAmount.toInt()} / month',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white70)),
                        if (paid && student.lastPaidDate.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Paid on ${student.lastPaidDate}',
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Detail rows
                FadeSlideIn(
                  delayMs: 80,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _row(context, 'Monthly Fee',
                            '₹${student.feeAmount.toInt()}'),
                        const Divider(height: 24),
                        _row(context, 'Status', paid ? 'Paid' : 'Pending',
                            valueColor:
                                paid ? AppColors.success : AppColors.error),
                        const Divider(height: 24),
                        _row(
                            context,
                            'Last Paid',
                            student.lastPaidDate.isEmpty
                                ? '—'
                                : student.lastPaidDate),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (!paid)
                  FadeSlideIn(
                    delayMs: 160,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please pay your fees to the admin. Once confirmed, your status will update here automatically.',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: const Color(0xFF92400E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.titleMedium.copyWith(
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
