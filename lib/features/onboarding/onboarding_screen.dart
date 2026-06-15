import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      bgColorStart: Color(0xFF1E3A8A),
      bgColorEnd: Color(0xFF1A56DB),
      icon: Icons.assignment_turned_in_rounded,
      iconColor: Colors.white,
      iconBgColor: Color(0x33FFFFFF),
      title: 'Track Attendance',
      description:
          'Know who\'s present or absent every day with ease. Real-time updates keep you informed at all times.',
      isDark: true,
    ),
    _OnboardingPage(
      bgColorStart: Color(0xFFF5F7FF),
      bgColorEnd: Color(0xFFEBF5FF),
      icon: Icons.currency_rupee_rounded,
      iconColor: Color(0xFF1A56DB),
      iconBgColor: Color(0xFFEBF5FF),
      title: 'Manage Fees',
      description:
          'Track fee payments and get instant payment status updates. Never miss a pending payment again.',
      isDark: false,
    ),
    _OnboardingPage(
      bgColorStart: Color(0xFF1A56DB),
      bgColorEnd: Color(0xFF1E3A8A),
      icon: Icons.emoji_events_rounded,
      iconColor: Colors.white,
      iconBgColor: Color(0x33FFFFFF),
      title: 'Achieve Excellence',
      description:
          'Monitor progress, view detailed reports and motivate your students to reach their full potential.',
      isDark: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _buildPage(_pages[index]),
          ),
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: _pages[_currentPage].isDark
                          ? AppColors.secondary
                          : AppColors.primary,
                      dotColor: _pages[_currentPage].isDark
                          ? Colors.white38
                          : AppColors.border,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _goToNext,
                    backgroundColor: _pages[_currentPage].isDark
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.roleSelection),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _pages[_currentPage].isDark
                            ? Colors.white60
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [page.bgColorStart, page.bgColorEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 60, 32, 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration container
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: page.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 90,
                  color: page.iconColor,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: page.isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                page.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: page.isDark
                      ? Colors.white70
                      : AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final Color bgColorStart;
  final Color bgColorEnd;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final bool isDark;

  const _OnboardingPage({
    required this.bgColorStart,
    required this.bgColorEnd,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.isDark,
  });
}
