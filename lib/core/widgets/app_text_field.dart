import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A reusable text input field adhering to the Ohmitron design system.
/// Defined in FRONTEND_SKILL.md Section 5.2.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final int? maxLength;
  final bool readOnly;
  final Widget? customSuffixIcon;
  final String? value;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    this.helperText,
    this.maxLength,
    this.readOnly = false,
    this.customSuffixIcon,
    this.value,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  }) : _obscureText = ValueNotifier<bool>(isPassword);

  final ValueNotifier<bool> _obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkGrey),
        ),
        const SizedBox(height: AppSpacing.space4),
        ValueListenableBuilder<bool>(
          valueListenable: _obscureText,
          builder: (context, obscure, child) {
            return SizedBox(
              height: 56, // Fixed height for the field itself
              child: TextField(
                controller: value != null ? TextEditingController(text: value) : controller,
                focusNode: focusNode,
                obscureText: obscure,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                readOnly: readOnly,
                maxLength: maxLength,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black),
                decoration: InputDecoration(
                  hintText: hintText,
                  helperText: helperText,
                  counterText: '', // Hide default counter for maxLength
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.disabled),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space12,
                    vertical: AppSpacing.space16,
                  ),
                  border: _buildBorder(AppColors.divider),
                  enabledBorder: _buildBorder(AppColors.divider),
                  focusedBorder: _buildBorder(AppColors.brandGreen),
                  errorBorder: _buildBorder(AppColors.errorRed),
                  focusedErrorBorder: _buildBorder(AppColors.errorRed),
                  suffixIcon: customSuffixIcon ?? (isPassword
                      ? IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.darkGrey,
                          ),
                          onPressed: () {
                            _obscureText.value = !_obscureText.value;
                          },
                        )
                      : null),
                ),
              ),
            );
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: errorText != null
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.space4),
                    child: Text(
                      errorText!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.errorRed),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
