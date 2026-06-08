import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum LoadingIndicatorVariant { fullScreen, inline }

/// A standard loading indicator for the Ohmitron app.
/// Defined in FRONTEND_SKILL.md Section 5.5.
class LoadingIndicator extends StatelessWidget {
  final LoadingIndicatorVariant variant;
  final String? label;

  const LoadingIndicator({
    super.key,
    this.variant = LoadingIndicatorVariant.inline,
    this.label,
  });

  const LoadingIndicator.fullScreen({
    super.key,
    this.label,
  }) : variant = LoadingIndicatorVariant.fullScreen;

  const LoadingIndicator.inline({
    super.key,
  })  : variant = LoadingIndicatorVariant.inline,
        label = null;

  @override
  Widget build(BuildContext context) {
    if (variant == LoadingIndicatorVariant.inline) {
      return _buildInline();
    }

    // Full screen variant includes a 200ms fade-in to prevent flashing on fast loads.
    // Using TweenAnimationBuilder to strictly adhere to StatelessWidget constraints.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.brandGreen,
                strokeWidth: 3.0,
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: AppSpacing.space16),
              Text(
                label!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInline() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: AppColors.brandGreen,
        strokeWidth: 2.0,
      ),
    );
  }
}
