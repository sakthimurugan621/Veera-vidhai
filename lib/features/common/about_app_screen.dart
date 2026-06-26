import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/gradient_header.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;

  static const _features = [
    (Icons.swipe_right_rounded, 'Slide to Check-In',
        'Mark daily attendance with a simple swipe'),
    (Icons.event_busy_rounded, 'Leave Requests',
        'Apply for leave and track approval status'),
    (Icons.payments_rounded, 'Fees Tracking',
        'See your monthly fee status anytime'),
    (Icons.notifications_active_rounded, 'Instant Alerts',
        'Get notified the moment something changes'),
    (Icons.cloud_done_rounded, 'Live Cloud Sync',
        'Everything stays up to date in real-time'),
  ];

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _logoScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          GradientHeader(
            tamilTitle: 'செயலி பற்றி',
            subtitle: 'About App',
            trailing: HeaderIconButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
              children: [
                // Logo
                Center(
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark
                                ]),
                              ),
                              child: const Icon(
                                  Icons.sports_martial_arts_rounded,
                                  size: 50,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeSlideIn(
                  delayMs: 150,
                  child: Column(
                    children: [
                      Text('வீர விதை',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                      const SizedBox(height: 4),
                      Text('VEERA VIDHAI',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                            letterSpacing: 4,
                          )),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Version 1.0.0',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  delayMs: 220,
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Text(
                      'Veera Vidhai is the official app of our Silambam training '
                      'academy. It makes daily attendance, fees and leave '
                      'management simple, fast and fully online.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delayMs: 280,
                  child: Text('What you can do',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const SizedBox(height: 12),
                ..._features.asMap().entries.map((e) {
                  final (icon, title, sub) = e.value;
                  return FadeSlideIn(
                    delayMs: 340 + e.key * 70,
                    child: _featureRow(context, icon, title, sub),
                  );
                }),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delayMs: 720,
                  child: Column(
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(height: 8),
                      Text('Made for Silambam Academy',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text('© 2026 Veera Vidhai',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(
      BuildContext context, IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    )),
                Text(sub,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
