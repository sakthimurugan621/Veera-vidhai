import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/leave_request.dart';
import '../../data/services/firestore_service.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/gradient_header.dart';

class AllLeavesScreen extends StatefulWidget {
  const AllLeavesScreen({super.key});

  @override
  State<AllLeavesScreen> createState() => _AllLeavesScreenState();
}

class _AllLeavesScreenState extends State<AllLeavesScreen> {
  final _fs = FirestoreService.instance;
  int _filter = 0; // 0 all, 1 pending, 2 approved, 3 declined

  Future<void> _setStatus(LeaveRequest l, String status) async {
    await _fs.setLeaveStatus(l.id, status);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status == 'approved'
            ? '${l.studentName}\'s leave approved'
            : '${l.studentName}\'s leave declined'),
        backgroundColor:
            status == 'approved' ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          GradientHeader(
            tamilTitle: 'விடுப்பு கோரிக்கைகள்',
            subtitle: 'All Leave Requests',
            trailing: HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<LeaveRequest>>(
            stream: _fs.allLeavesStream(),
            builder: (context, snap) {
              final all = snap.data ?? [];
              final pending = all.where((l) => l.isPending).length;
              final approved = all.where((l) => l.isApproved).length;
              final declined = all.where((l) => l.isDeclined).length;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All', 0, all.length),
                      _filterChip('Pending', 1, pending),
                      _filterChip('Approved', 2, approved),
                      _filterChip('Declined', 3, declined),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<LeaveRequest>>(
              stream: _fs.allLeavesStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data ?? [];
                final list = switch (_filter) {
                  1 => all.where((l) => l.isPending).toList(),
                  2 => all.where((l) => l.isApproved).toList(),
                  3 => all.where((l) => l.isDeclined).toList(),
                  _ => all,
                };
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_outlined,
                            size: 64,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No leave requests',
                            style: AppTextStyles.titleMedium
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: list.length,
                  itemBuilder: (context, i) => FadeSlideIn(
                    delayMs: 30 * (i % 14),
                    child: _LeaveCard(
                      leave: list[i],
                      onAccept: () => _setStatus(list[i], 'approved'),
                      onDecline: () => _setStatus(list[i], 'declined'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int index, int count) {
    final selected = _filter == index;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
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
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest leave;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _LeaveCard({
    required this.leave,
    required this.onAccept,
    required this.onDecline,
  });

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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.studentName,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                    Text('Roll ${leave.rollNo} • ${leave.leaveType}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    )),
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
            const SizedBox(height: 8),
            Text(leave.comments,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 8),
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
          // Pending → action buttons
          if (leave.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(0, 40),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(0, 40),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
