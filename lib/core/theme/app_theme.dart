import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// The global app theme tying together AppColors, AppSpacing, and AppTextStyles.
/// 
/// Defined by IMPLEMENTATION_PLAN.md Step 1.3.1 and FRONTEND_SKILL.md.
class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandGreen,
        onPrimary: AppColors.surface,
        secondary: AppColors.brandGreen,
        onSecondary: AppColors.surface,
        error: AppColors.errorRed,
        onError: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.black,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.sidebarBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.surface,
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          disabledForegroundColor: AppColors.disabled,
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.brandGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandGreen,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppSpacing.space12),
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.disabled),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.darkGrey),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.errorRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
      ),
    );
  }
}
