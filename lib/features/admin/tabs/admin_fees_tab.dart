import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/app_student.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';

class AdminFeesTab extends StatefulWidget {
  const AdminFeesTab({super.key});

  @override
  State<AdminFeesTab> createState() => _AdminFeesTabState();
}

class _AdminFeesTabState extends State<AdminFeesTab> {
  final _fs = FirestoreService.instance;
  int _filter = 0; // 0 = all, 1 = paid, 2 = unpaid

  Future<void> _togglePaid(AppStudent s) async {
    if (s.feesPaid) {
      await _fs.setFeeUnpaid(s.id);
    } else {
      await _fs.setFeePaid(s.id, DateHelpers.prettyDate());
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.feesPaid
            ? '${s.name} marked as Unpaid'
            : '${s.name} marked as Paid'),
        backgroundColor: s.feesPaid ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editFee(AppStudent s) {
    final amountCtrl = TextEditingController(text: s.feeAmount.toInt().toString());
    String status = s.feeStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Edit Fee — ${s.name}',
                  style: AppTextStyles.headlineSmall),
              const SizedBox(height: 4),
              Text('Roll ${s.rollNo}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Text('Monthly Fee (₹)',
                  style: AppTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 18),
              Text('Status',
                  style: AppTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _statusChip('Paid', status == 'paid',
                        AppColors.success, () => setSheet(() => status = 'paid')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statusChip('Unpaid', status == 'unpaid',
                        AppColors.error, () => setSheet(() => status = 'unpaid')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amt =
                        double.tryParse(amountCtrl.text.trim()) ?? s.feeAmount;
                    await _fs.updateFee(
                        s.id, amt, status, DateHelpers.prettyDate());
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(
      String label, bool selected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(label,
            style: AppTextStyles.labelLarge.copyWith(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<AppStudent>>(
        stream: _fs.studentsStream(),
        builder: (context, snap) {
          final all = snap.data ?? [];
          final paid = all.where((s) => s.feesPaid).toList();
          final unpaid = all.where((s) => !s.feesPaid).toList();
          final collected =
              paid.fold<double>(0, (sum, s) => sum + s.feeAmount);
          final pending =
              unpaid.fold<double>(0, (sum, s) => sum + s.feeAmount);

          final list = _filter == 1
              ? paid
              : _filter == 2
                  ? unpaid
                  : all;

          return Column(
            children: [
              GradientHeader(
                tamilTitle: 'கட்டணம்',
                subtitle: 'Fees Management',
                bottom: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _moneyStat('Collected', '₹${collected.toInt()}',
                            Icons.check_circle_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _moneyStat('Pending', '₹${pending.toInt()}',
                            Icons.pending_actions_rounded),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Filter tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterTab('All', 0, all.length),
                    _filterTab('Paid', 1, paid.length),
                    _filterTab('Unpaid', 2, unpaid.length),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text('No students',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: list.length,
                        itemBuilder: (context, i) => FadeSlideIn(
                          delayMs: 40 * (i % 12),
                          child: _FeeCard(
                            student: list[i],
                            onToggle: () => _togglePaid(list[i]),
                            onEdit: () => _editFee(list[i]),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _moneyStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style:
                      AppTextStyles.titleLarge.copyWith(color: Colors.white)),
              Text(label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterTab(String label, int index, int count) {
    final selected = _filter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Text('$label ($count)',
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final AppStudent student;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _FeeCard({
    required this.student,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final paid = student.feesPaid;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                child: Text(student.initials,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    Text('₹${student.feeAmount.toInt()} / month',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                    if (paid && student.lastPaidDate.isNotEmpty)
                      Text('Paid on ${student.lastPaidDate}',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.success)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: paid ? AppColors.errorLight : AppColors.success,
                foregroundColor: paid ? AppColors.error : Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 44),
              ),
              icon: Icon(
                  paid ? Icons.undo_rounded : Icons.check_circle_rounded,
                  size: 18),
              label: Text(paid ? 'Mark as Unpaid' : 'Mark as Paid'),
            ),
          ),
        ],
      ),
    );
  }
}
