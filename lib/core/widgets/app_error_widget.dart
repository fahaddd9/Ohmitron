import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// A full-screen error state for when a screen fails to load entirely.
/// Defined in FRONTEND_SKILL.md Section 5.9.
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorRed,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton(
              label: 'Try Again',
              variant: AppButtonVariant.primary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
