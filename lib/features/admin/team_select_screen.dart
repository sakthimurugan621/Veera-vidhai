import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/team.dart';
import '../../data/services/firestore_service.dart';
import '../../providers/team_provider.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/responsive_center.dart';

/// Shown after admin login — styled like the role-selection screen.
class TeamSelectScreen extends StatefulWidget {
  const TeamSelectScreen({super.key});

  @override
  State<TeamSelectScreen> createState() => _TeamSelectScreenState();
}

class _TeamSelectScreenState extends State<TeamSelectScreen>
    with SingleTickerProviderStateMixin {
  final _fs = FirestoreService.instance;
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;

  static const _gradients = [
    [AppColors.primary, AppColors.primaryDark],
    [Color(0xFF2563EB), Color(0xFF1E40AF)],
    [Color(0xFF16A34A), Color(0xFF15803D)],
    [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  ];

  @override
  void initState() {
    super.initState();
    _fs.ensureTeams();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _logoScale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  void _open(Team team) {
    context.read<TeamProvider>().setActive(team.id, team.name);
    Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
  }

  Future<void> _rename(Team team) async {
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
      await _fs.updateTeamName(team.id, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: ResponsiveCenter(
                    maxWidth: 460,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 44),

                        // Framed logo (gold ring, elastic)
                        Center(
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _logo(),
                          ),
                        ),
                        const SizedBox(height: 18),

                        FadeSlideIn(
                          delayMs: 150,
                          child: Text('வீர விதை',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSansTamil(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                        ),
                        const SizedBox(height: 6),
                        FadeSlideIn(
                          delayMs: 220,
                          child: Text(
                            'Select a team to continue',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Team cards
                        StreamBuilder<List<Team>>(
                          stream: _fs.teamsStream(),
                          builder: (context, snap) {
                            final teams = snap.data ?? [];
                            if (teams.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            return Column(
                              children: [
                                for (int i = 0; i < teams.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: FadeSlideIn(
                                      delayMs: 320 + 100 * i,
                                      child: _TeamCard(
                                        team: teams[i],
                                        gradient: _gradients[
                                            i % _gradients.length],
                                        onTap: () => _open(teams[i]),
                                        onRename: () => _rename(teams[i]),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          delayMs: 520,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shield_outlined,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text('Your data is secure with us',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.secondary, Color(0xFFFBBF24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.4),
            blurRadius: 26,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.jpg',
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark]),
              ),
              child: const Icon(Icons.sports_martial_arts_rounded,
                  size: 48, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamCard extends StatefulWidget {
  final Team team;
  final List<Color> gradient;
  final VoidCallback onTap;
  final VoidCallback onRename;

  const _TeamCard({
    required this.team,
    required this.gradient,
    required this.onTap,
    required this.onRename,
  });

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.groups_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('அணி',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.gradient.first,
                        )),
                    Text(widget.team.name,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 2),
                    Text('Tap to open',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onRename,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.gradient.first.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit_rounded,
                      color: widget.gradient.first, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
