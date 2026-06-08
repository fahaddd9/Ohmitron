import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, destructive }

/// The primary action button used throughout the Ohmitron app.
/// Supports three variants: primary, secondary, and destructive.
/// See FRONTEND_SKILL.md Section 5.1 for full specification.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isEnabled;

  AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);

  bool get _isDisabled => !isEnabled || isLoading || onPressed == null;

  void _onTapDown(TapDownDetails details) {
    if (!_isDisabled) _isPressed.value = true;
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isDisabled) _isPressed.value = false;
    if (!_isDisabled && !isLoading) {
      onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (!_isDisabled) _isPressed.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPressed,
        builder: (context, isPressed, child) {
          return AnimatedScale(
            scale: isPressed && !_isDisabled ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: variant == AppButtonVariant.secondary ? 48 : 52,
              decoration: _buildDecoration(),
              child: Center(
                child: isLoading ? _buildLoader() : _buildLabel(),
              ),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    if (_isDisabled) {
      return BoxDecoration(
        color: variant == AppButtonVariant.secondary ? Colors.transparent : AppColors.disabled,
        borderRadius: BorderRadius.circular(12),
        border: variant == AppButtonVariant.secondary
            ? Border.all(color: AppColors.disabled, width: 1.5)
            : null,
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          color: AppColors.brandGreen,
          borderRadius: BorderRadius.circular(12),
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandGreen, width: 1.5),
        );
      case AppButtonVariant.destructive:
        return BoxDecoration(
          color: AppColors.errorRed,
          borderRadius: BorderRadius.circular(12),
        );
    }
  }

  Widget _buildLabel() {
    Color textColor;
    if (_isDisabled) {
      textColor = variant == AppButtonVariant.secondary ? AppColors.disabled : AppColors.surface;
    } else {
      textColor = variant == AppButtonVariant.secondary ? AppColors.brandGreen : AppColors.surface;
    }

    return Text(
      label,
      style: AppTextStyles.labelLarge.copyWith(color: textColor),
    );
  }

  Widget _buildLoader() {
    Color loaderColor = variant == AppButtonVariant.secondary
        ? (_isDisabled ? AppColors.disabled : AppColors.brandGreen)
        : AppColors.surface;

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
      ),
    );
  }
}
