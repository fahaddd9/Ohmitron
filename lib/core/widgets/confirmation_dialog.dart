import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// A reusable dialog for destructive or irreversible actions.
/// Defined in FRONTEND_SKILL.md Section 5.7.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final bool isDestructive;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    this.isDestructive = false,
    required this.onCancel,
    required this.onConfirm,
  });

  /// Shows the confirmation dialog with the required animations.
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String body,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.40), // colorScrim
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ConfirmationDialog(
          title: title,
          body: body,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          isDestructive: isDestructive,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        // Scale from 0.92 to 1.0
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(curve);
        // Fade from 0.0 to 1.0
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              body,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            ),
            const SizedBox(height: AppSpacing.space24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.secondary,
                    onPressed: onCancel,
                  ),
                ),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    variant: isDestructive
                        ? AppButtonVariant.destructive
                        : AppButtonVariant.primary,
                    onPressed: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
