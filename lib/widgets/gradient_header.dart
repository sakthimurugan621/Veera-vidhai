import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// A rounded orange gradient header used at the top of most screens.
/// [tamilTitle] is the big cultural title; [subtitle] is English supporting text.
class GradientHeader extends StatelessWidget {
  final String tamilTitle;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> bottom;
  final EdgeInsets padding;

  const GradientHeader({
    super.key,
    required this.tamilTitle,
    this.subtitle,
    this.trailing,
    this.bottom = const [],
    this.padding = const EdgeInsets.fromLTRB(20, 14, 20, 22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33EA580C),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tamilTitle,
                          style: GoogleFonts.notoSansTamil(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              ...bottom,
            ],
          ),
        ),
      ),
    );
  }
}

/// A small circular icon button for headers (e.g. notifications, logout).
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const HeaderIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
