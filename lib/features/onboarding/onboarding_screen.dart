import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      image: 'assets/images/images - 2026-06-17T211018.812.jpg',
      tamilTitle: 'வரவேற்கிறோம்',
      title: 'Veera Vidhai',
      description:
          'Welcome to our Silambam training academy. Manage attendance, '
          'fees and everything in one beautiful place.',
    ),
    _PageData(
      image: 'assets/images/images - 2026-06-17T210836.794.jpg',
      tamilTitle: 'வருகை பதிவு',
      title: 'Track Attendance',
      description:
          'Slide to check in every day. Your trainer instantly sees who '
          'is present and at what time.',
    ),
    _PageData(
      image: 'assets/images/Silambam_martial-art_gounesco.jpg',
      tamilTitle: 'சிறப்பை அடையுங்கள்',
      title: 'Achieve Excellence',
      description:
          'Track fees, follow your progress and rise in Silambam. '
          'Veera Vidhai is with you every step.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut);
    } else {
      _goToRole();
    }
  }

  void _goToRole() =>
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.8),
                            width: 1.5),
                        color: Colors.black26,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(
                              Icons.sports_martial_arts,
                              color: Colors.white,
                              size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'வீர விதை',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _goToRole,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text('Skip',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) =>
                      _PageView(data: _pages[index]),
                ),
              ),

              // Dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                child: Row(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: AppColors.secondary,
                        dotColor: Colors.white30,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3.5,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final _PageData data;
  const _PageView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Framed image — proper aspect ratio, no stretch
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  data.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: AppColors.primaryDark,
                    child: const Center(
                      child: Icon(Icons.sports_martial_arts,
                          size: 90, color: Colors.white30),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Text content
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    data.tamilTitle,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 14,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final String image;
  final String tamilTitle;
  final String title;
  final String description;

  const _PageData({
    required this.image,
    required this.tamilTitle,
    required this.title,
    required this.description,
  });
}
