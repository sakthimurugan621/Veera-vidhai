import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Small circular app logo used in dashboard headers.
class AppLogoBadge extends StatelessWidget {
  final double size;
  const AppLogoBadge({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: Icon(Icons.sports_martial_arts_rounded,
                color: AppColors.primary, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}
