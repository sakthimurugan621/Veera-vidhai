import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _ringCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textCtrl.forward();
    });

    Future.delayed(const Duration(seconds: 7), _decideNext);
  }

  Future<void> _decideNext() async {
    if (!mounted) return;
    final role = await context.read<AuthProvider>().checkAuthState();
    if (!mounted) return;
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
    } else if (role == 'student') {
      Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C2D12), AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated logo with rotating ring
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating dashed ring
                        RotationTransition(
                          turns: _ringCtrl,
                          child: Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        // Counter-rotating ring
                        RotationTransition(
                          turns: Tween<double>(begin: 1, end: 0)
                              .animate(_ringCtrl),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.sports_martial_arts,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Animated text
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (context, child) => Opacity(
                  opacity: _textFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'வீர விதை',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VEERA VIDHAI',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 180,
                      height: 1.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          AppColors.secondary,
                          Colors.transparent,
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'சிலம்பம் பயிற்சி மையம்',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silambam Training Academy',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Loading
              FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white38,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
