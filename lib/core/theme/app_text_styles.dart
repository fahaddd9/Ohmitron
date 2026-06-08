import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ohmitron/core/theme/app_colors.dart';

/// The single source of truth for typography in the Ohmitron app.
/// 
/// Defined by FRONTEND_SKILL.md (Section 3).
/// Uses Inter from Google Fonts exclusively.
class AppTextStyles {
  const AppTextStyles._();

  static final TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    letterSpacing: -1.5,
    color: AppColors.black,
  );

  static final TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -1.0,
    color: AppColors.black,
  );

  static final TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -0.5,
    color: AppColors.black,
  );

  static final TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.5,
    color: AppColors.black,
  );

  static final TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: 0,
    color: AppColors.black,
  );

  static final TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
    letterSpacing: 0,
    color: AppColors.black,
  );

  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0,
    color: AppColors.black,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0,
    color: AppColors.black,
  );

  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.2,
    color: AppColors.darkGrey,
  );

  static final TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0.1,
    color: AppColors.black,
  );

  static final TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.1,
    color: AppColors.black,
  );

  static final TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.4,
    color: AppColors.black,
  );
}
