/// The single source of truth for app configuration and feature flags.
///
/// Defined by TRD.md Section 5.3.
class AppConfig {
  const AppConfig._();

  // Set to false ONLY after Phase 8 approval — never change manually
  // Agent must ask for explicit permission before setting to false
  static const bool useMockData = true;

  // Debug flags — mock only, not present in production
  static const bool mockIsLoggedIn = true;
  static const bool mockStaleData = false;
  static const bool mockHighTemp = false;
  static const bool mockLowSOC = false;
}
