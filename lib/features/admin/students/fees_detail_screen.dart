import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/student_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/status_badge.dart';

class FeesDetailScreen extends StatelessWidget {
  final Student student;
  const FeesDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        student.initials,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: AppTextStyles.titleLarge.copyWith(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Roll No: ${student.rollNo}',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary),
                        ),
                        Text(
                          'Admission: ${student.admissionDate}',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: student.feesPaid ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: student.feesPaid ? AppColors.success : AppColors.error,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: student.feesPaid ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.currency_rupee_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.feesPaid ? 'Paid' : 'Unpaid',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: student.feesPaid
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.feesPaid
                              ? 'All fees has been paid.'
                              : '₹${student.dueFees.toInt()} amount is pending.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: student.feesPaid
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fee summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fee Summary',
                      style: AppTextStyles.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  _feeRow(context, 'Total Fees',
                      '₹${student.totalFees.toInt()}', AppColors.textPrimary),
                  _feeRow(context, 'Paid Fees',
                      '₹${student.paidFees.toInt()}', AppColors.success),
                  _feeRow(context, 'Due Fees',
                      '₹${student.dueFees.toInt()}',
                      student.dueFees > 0 ? AppColors.error : AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment history
            Text('Payment History',
                style: AppTextStyles.titleLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            ...student.paymentHistory.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: p.isPaid ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          p.isPaid
                              ? Icons.check_circle_outline_rounded
                              : Icons.pending_outlined,
                          color: p.isPaid ? AppColors.success : AppColors.error,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.type,
                                style: AppTextStyles.titleSmall.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface)),
                            Text(p.date,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${p.amount.toInt()}',
                              style: AppTextStyles.titleMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          StatusBadge(
                              type: p.isPaid ? BadgeType.paid : BadgeType.notPaid),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // Action button
            CustomButton(
              label: 'Record Payment',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Payment recorded successfully!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _feeRow(BuildContext context, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.titleMedium.copyWith(
                  color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
