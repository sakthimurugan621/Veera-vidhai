import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../providers/team_provider.dart';
import '../../../data/models/app_student.dart';
import '../../../data/services/firestore_service.dart';
import '../../../widgets/fade_slide_in.dart';
import '../../../widgets/gradient_header.dart';
import '../student_form_screen.dart';

class AdminStudentsTab extends StatefulWidget {
  const AdminStudentsTab({super.key});

  @override
  State<AdminStudentsTab> createState() => _AdminStudentsTabState();
}

class _AdminStudentsTabState extends State<AdminStudentsTab> {
  final _fs = FirestoreService.instance;
  String _query = '';

  void _openForm([AppStudent? student]) {
    final teamId = context.read<TeamProvider>().activeTeamId;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormScreen(
          existing: student,
          defaultTeamId: teamId,
        ),
      ),
    );
  }

  Future<void> _markPaid(AppStudent s) async {
    await _fs.setFeePaid(s.id, DateHelpers.prettyDate());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${s.name} marked as Paid ✓'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => _fs.setFeeUnpaid(s.id),
        ),
      ),
    );
  }

  void _showActions(AppStudent s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _StudentActionsSheet(
        student: s,
        onEdit: () {
          Navigator.pop(context);
          _openForm(s);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(s);
        },
      ),
    );
  }

  Future<void> _confirmDelete(AppStudent s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Student?', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to delete ${s.name}? This also removes their attendance records.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(100, 44),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _fs.deleteStudent(s.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${s.name} deleted'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = context.watch<TeamProvider>().activeTeamId;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: Text('Add',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
      body: Column(
        children: [
          GradientHeader(
            tamilTitle: 'மாணவர்கள்',
            subtitle: 'Manage Students',
            bottom: [
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name or roll no',
                    hintStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<AppStudent>>(
              stream: _fs.studentsStream(teamId: teamId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data ?? [];
                final list = _query.isEmpty
                    ? all
                    : all
                        .where((s) =>
                            s.name.toLowerCase().contains(_query) ||
                            s.rollNo.toLowerCase().contains(_query))
                        .toList();

                if (list.isEmpty) {
                  return _EmptyState(hasStudents: all.isNotEmpty);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: list.length,
                  itemBuilder: (context, i) => FadeSlideIn(
                    delayMs: 40 * (i % 12),
                    child: _StudentCard(
                      student: list[i],
                      onTap: () => _showActions(list[i]),
                      onPay: () => _markPaid(list[i]),
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
}

class _StudentCard extends StatelessWidget {
  final AppStudent student;
  final VoidCallback onTap;
  final VoidCallback onPay;
  const _StudentCard({
    required this.student,
    required this.onTap,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(student.initials,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ),
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
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _miniTag('Roll ${student.rollNo}', AppColors.primaryLight,
                          AppColors.primary),
                      const SizedBox(width: 6),
                      Icon(Icons.phone_rounded,
                          size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(student.phone,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            // Pay button (unpaid) or Paid badge
            if (student.feesPaid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 13, color: AppColors.success),
                    const SizedBox(width: 3),
                    Text('Paid',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: onPay,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.currency_rupee_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 2),
                      Text('Pay',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 2),
            const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: AppTextStyles.labelSmall
              .copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _StudentActionsSheet extends StatelessWidget {
  final AppStudent student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudentActionsSheet({
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(student.initials,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: AppTextStyles.headlineSmall),
                      Text('Roll ${student.rollNo} • ${student.className}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.phone_rounded, 'Phone', student.phone),
            _infoRow(Icons.lock_outline_rounded, 'Password', student.password),
            _infoRow(Icons.currency_rupee_rounded, 'Monthly Fee',
                '₹${student.feeAmount.toInt()}'),
            if (student.address.isNotEmpty)
              _infoRow(Icons.home_outlined, 'Address', student.address),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('$label:',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasStudents;
  const _EmptyState({required this.hasStudents});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasStudents ? Icons.search_off_rounded : Icons.groups_outlined,
            size: 72,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            hasStudents ? 'No students found' : 'No students yet',
            style: AppTextStyles.titleLarge
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            hasStudents
                ? 'Try a different search'
                : 'Tap "Add" to register your first student',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
