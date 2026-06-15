import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

enum BadgeType { present, absent, pending, paid, notPaid }

class StatusBadge extends StatelessWidget {
  final BadgeType type;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.type,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (type) {
      case BadgeType.present:
        return _BadgeConfig('Present', AppColors.successLight, AppColors.success);
      case BadgeType.absent:
        return _BadgeConfig('Absent', AppColors.errorLight, AppColors.error);
      case BadgeType.pending:
        return _BadgeConfig('Pending', AppColors.warningLight, AppColors.warning);
      case BadgeType.paid:
        return _BadgeConfig('Paid', AppColors.successLight, AppColors.success);
      case BadgeType.notPaid:
        return _BadgeConfig('Not Paid', AppColors.errorLight, AppColors.error);
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bgColor;
  final Color textColor;
  const _BadgeConfig(this.label, this.bgColor, this.textColor);
}
