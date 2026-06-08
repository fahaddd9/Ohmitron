import 'package:flutter/material.dart';

/// The single source of truth for all colours in the Ohmitron app.
/// 
/// Defined by FRONTEND_SKILL.md (Section 2).
/// No other colours or hardcoded hex values are permitted.
class AppColors {
  const AppColors._();

  // Primary palette
  static const Color brandGreen = Color(0xFF3DAE2B);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF333333);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color sidebarBackground = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFE8E8E8);

  // States
  static const Color disabled = Color(0xFFBBBBBB);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Overlays
  static const Color scrim = Color(0x66000000); // Black at 40% opacity
}
