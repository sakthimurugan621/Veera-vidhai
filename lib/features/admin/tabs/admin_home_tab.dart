import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/team_provider.dart';
import '../../../widgets/team_switcher.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/app_student.dart';
import '../../../data/models/attendance_entry.dart';
import '../../../data/models/leave_request.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService.instance;
    final today = DateHelpers.todayKey();
    final teamId = context.watch<TeamProvider>().activeTeamId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<AppStudent>>(
        stream: fs.studentsStream(teamId: teamId),
        builder: (context, studentSnap) {
          final students = studentSnap.data ?? [];
          final totalStudents = students.length;
          final paidCount = students.where((s) => s.feesPaid).length;
          final pendingCount = totalStudents - paidCount;
          final feesCollected = students
              .where((s) => s.feesPaid)
              .fold<double>(0, (sum, s) => sum + s.feeAmount);

          return StreamBuilder<List<AttendanceEntry>>(
            stream: fs.attendanceForDateStream(today, teamId: teamId),
            builder: (context, attSnap) {
              final attendance =
                  (attSnap.data ?? []).where((e) => e.isPresent).toList();
              final presentToday = attendance.length;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: GradientHeader(
                      showLogo: true,
                      tamilTitle: 'வீர விதை',
                      subtitle: 'Admin Dashboard',
                      trailing: const TeamSwitcher(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Stat grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.35,
                          children: [
                            FadeSlideIn(
                              delayMs: 0,
                              child: _StatCard(
                                icon: Icons.groups_rounded,
                                label: 'Total Students',
                                value: '$totalStudents',
                                color: AppColors.primary,
                                bg: AppColors.primaryLight,
                              ),
                            ),
                            FadeSlideIn(
                              delayMs: 80,
                              child: _StatCard(
                                icon: Icons.how_to_reg_rounded,
                                label: 'Present Today',
                                value: '$presentToday',
                                color: AppColors.success,
                                bg: AppColors.successLight,
                              ),
                            ),
                            FadeSlideIn(
                              delayMs: 160,
                              child: _StatCard(
                                icon: Icons.check_circle_rounded,
                                label: 'Fees Paid',
                                value: '$paidCount',
                                color: AppColors.secondary,
                                bg: AppColors.warningLight,
                              ),
                            ),
                            FadeSlideIn(
                              delayMs: 240,
                              child: _StatCard(
                                icon: Icons.pending_actions_rounded,
                                label: 'Fees Pending',
                                value: '$pendingCount',
                                color: AppColors.error,
                                bg: AppColors.errorLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Collected banner
                        FadeSlideIn(
                          delayMs: 300,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.account_balance_wallet_rounded,
                                      color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fees Collected',
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${feesCollected.toInt()}',
                                      style: AppTextStyles.headlineLarge
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Pending leave requests
                        _LeaveRequestsSection(fs: fs, teamId: teamId),

                        // Recent check-ins
                        Text(
                          "Today's Check-ins",
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (attendance.isEmpty)
                          _emptyBox(context, 'No check-ins yet today')
                        else
                          ...attendance.take(5).toList().asMap().entries.map(
                                (e) => FadeSlideIn(
                                  delayMs: 60 * e.key,
                                  child: _CheckInRow(entry: e.value),
                                ),
                              ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyBox(BuildContext context, String msg) {
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(msg,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Pending leave requests with Accept / Decline ──────────────────────────────
class _LeaveRequestsSection extends StatelessWidget {
  final FirestoreService fs;
  final String? teamId;
  const _LeaveRequestsSection({required this.fs, this.teamId});

  Future<void> _setStatus(
      BuildContext context, LeaveRequest l, String status) async {
    await fs.setLeaveStatus(l.id, status);
    if (!context.mounted) return;
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
    return StreamBuilder<List<LeaveRequest>>(
      stream: fs.pendingLeavesStream(teamId: teamId),
      builder: (context, snap) {
        final leaves = snap.data ?? [];
        if (leaves.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Leave Requests',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${leaves.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...leaves.asMap().entries.map(
                  (e) => FadeSlideIn(
                    delayMs: 60 * e.key,
                    child: _LeaveRequestCard(
                      leave: e.value,
                      onAccept: () => _setStatus(context, e.value, 'approved'),
                      onDecline: () => _setStatus(context, e.value, 'declined'),
                    ),
                  ),
                ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _LeaveRequestCard extends StatelessWidget {
  final LeaveRequest leave;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _LeaveRequestCard({
    required this.leave,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
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
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.event_busy_rounded,
                    color: AppColors.warning),
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
            ],
          ),
          if (leave.dateRange.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.date_range_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(leave.dateRange,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ],
          if (leave.comments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(leave.comments,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(0, 42),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 21),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  maxLines: 1,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  )),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckInRow extends StatelessWidget {
  final AttendanceEntry entry;
  const _CheckInRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.studentName,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                Text('Roll ${entry.rollNo}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(entry.checkInTime,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
    );
  }
}
