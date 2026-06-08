import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A banner indicating that telemetry data is stale.
/// Defined in FRONTEND_SKILL.md Section 5.8.
class StaleDataBanner extends StatelessWidget {
  final bool isVisible;
  final String lastUpdated;

  const StaleDataBanner({
    super.key,
    required this.isVisible,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter, // Slide down from top
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: isVisible
          ? Container(
              key: const ValueKey('stale_data_banner_visible'),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.15),
                border: const Border(
                  left: BorderSide(
                    color: AppColors.warningAmber,
                    width: 4.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: AppSpacing.space12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warningAmber,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Stale — Device may be offline',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.black),
                        ),
                        const SizedBox(height: AppSpacing.space4),
                        Text(
                          'Last updated: $lastUpdated',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('stale_data_banner_hidden')),
    );
  }
}
