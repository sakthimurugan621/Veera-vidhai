import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/status_badge.dart';

class FeesStatusScreen extends StatelessWidget {
  const FeesStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().currentStudent;
    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Status'),
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
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: student.feesPaid ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: student.feesPaid ? AppColors.success : AppColors.error,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    student.feesPaid
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    size: 52,
                    color: student.feesPaid ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student.feesPaid
                        ? 'All clear! \u{1F389}'
                        : 'Payment Pending',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: student.feesPaid ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    student.feesPaid
                        ? 'You have no pending fees.'
                        : '₹${student.dueFees.toInt()} is pending.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: student.feesPaid ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fee Details
            Text('Fee Details',
                style: AppTextStyles.titleLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  _feeDetailRow(context, 'Total Fees',
                      '₹${student.totalFees.toInt()}',
                      Theme.of(context).colorScheme.onSurface),
                  const Divider(height: 20),
                  _feeDetailRow(context, 'Paid Fees',
                      '₹${student.paidFees.toInt()}', AppColors.success),
                  const Divider(height: 20),
                  _feeDetailRow(context, 'Due Fees',
                      '₹${student.dueFees.toInt()}',
                      student.dueFees > 0 ? AppColors.error : AppColors.success),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Annual Fees',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface)),
                      Row(
                        children: [
                          Text('₹10,000',
                              style: AppTextStyles.titleMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          StatusBadge(
                            type: student.feesPaid
                                ? BadgeType.paid
                                : BadgeType.notPaid,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment History
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
                          color: p.isPaid
                              ? AppColors.successLight
                              : AppColors.errorLight,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
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
                              type: p.isPaid
                                  ? BadgeType.paid
                                  : BadgeType.notPaid),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // Action button
            student.feesPaid
                ? CustomButton(
                    label: 'View Receipt',
                    isOutlined: true,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Receipt download coming soon.')),
                      );
                    },
                  )
                : CustomButton(
                    label: 'Pay Now',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Payment gateway coming soon.')),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _feeDetailRow(
      BuildContext context, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.titleMedium.copyWith(
                color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
