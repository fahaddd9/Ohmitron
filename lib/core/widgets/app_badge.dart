import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppBadgeVariant { green, red, amber, blue, grey }

/// A coloured pill badge for status display.
/// Defined in FRONTEND_SKILL.md Section 5.3.
class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.label,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space8,
        vertical: AppSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        widthFactor: 1.0,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.surface),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case AppBadgeVariant.green:
        return AppColors.brandGreen;
      case AppBadgeVariant.red:
        return AppColors.errorRed;
      case AppBadgeVariant.amber:
        return AppColors.warningAmber;
      case AppBadgeVariant.blue:
        return AppColors.infoBlue;
      case AppBadgeVariant.grey:
        return AppColors.darkGrey;
    }
  }
}
