import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/team.dart';
import '../data/services/firestore_service.dart';
import '../providers/team_provider.dart';

/// A pill in the admin header showing the active team, with a dropdown to
/// switch. Switching updates [TeamProvider] so every admin screen re-scopes.
class TeamSwitcher extends StatelessWidget {
  const TeamSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.watch<TeamProvider>();
    return StreamBuilder<List<Team>>(
      stream: FirestoreService.instance.teamsStream(),
      builder: (context, snap) {
        final teams = snap.data ?? [];
        // Keep the displayed name fresh if a team was renamed.
        final current = teams.where((t) => t.id == active.activeTeamId);
        final name =
            current.isNotEmpty ? current.first.name : active.activeTeamName;

        return PopupMenuButton<Team>(
          onSelected: (t) =>
              context.read<TeamProvider>().setActive(t.id, t.name),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          itemBuilder: (_) => teams
              .map((t) => PopupMenuItem<Team>(
                    value: t,
                    child: Row(
                      children: [
                        Icon(
                          t.id == active.activeTeamId
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(t.name, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ))
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.groups_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  name.isEmpty ? 'Team' : name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
