import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A list tile used on the Settings screen.
/// Defined in FRONTEND_SKILL.md Section 5.13.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.background,
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: AppSpacing.space16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.space16),
              trailing ?? const Icon(
                Icons.chevron_right,
                color: AppColors.disabled,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
