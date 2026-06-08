/// The single source of truth for all spacing in the Ohmitron app.
/// 
/// Defined by FRONTEND_SKILL.md (Section 4).
/// All spacing is based on a 4px base unit.
/// No hardcoded padding or margin values are permitted in UI code.
class AppSpacing {
  const AppSpacing._();

  /// 2px: Micro gaps — icon to label, badge internal padding
  static const double space2 = 2.0;
  
  /// 4px: Tight internal padding — chip padding, small icon margins
  static const double space4 = 4.0;
  
  /// 8px: Standard internal padding — button vertical padding, small gaps
  static const double space8 = 8.0;
  
  /// 12px: Form field internal padding, list item vertical padding
  static const double space12 = 12.0;
  
  /// 16px: Standard horizontal screen padding, card internal padding
  static const double space16 = 16.0;
  
  /// 20px: Section gaps, larger card padding
  static const double space20 = 20.0;
  
  /// 24px: Between sections on screen
  static const double space24 = 24.0;
  
  /// 32px: Major section separation
  static const double space32 = 32.0;
  
  /// 48px: Hero element separation (battery gauge to stats grid)
  static const double space48 = 48.0;
  
  /// 64px: Full-section breathing room
  static const double space64 = 64.0;
}
