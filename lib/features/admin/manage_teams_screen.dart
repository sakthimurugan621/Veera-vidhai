import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/team.dart';
import '../../data/services/firestore_service.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/gradient_header.dart';

/// Admin-only screen to rename teams.
class ManageTeamsScreen extends StatelessWidget {
  const ManageTeamsScreen({super.key});

  Future<void> _rename(BuildContext context, Team team) async {
    final ctrl = TextEditingController(text: team.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rename Team', style: AppTextStyles.headlineSmall),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Team name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await FirestoreService.instance.updateTeamName(team.id, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService.instance;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          GradientHeader(
            tamilTitle: 'அணிகள்',
            subtitle: 'Manage Teams',
            trailing: HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Team>>(
              stream: fs.teamsStream(),
              builder: (context, snap) {
                final teams = snap.data ?? [];
                if (teams.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  children: [
                    Text('Tap a team to rename it',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    for (int i = 0; i < teams.length; i++)
                      FadeSlideIn(
                        delayMs: 60 * i,
                        child: GestureDetector(
                          onTap: () => _rename(context, teams[i]),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
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
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.groups_rounded,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(teams[i].name,
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                                const Icon(Icons.edit_rounded,
                                    color: AppColors.textSecondary, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
