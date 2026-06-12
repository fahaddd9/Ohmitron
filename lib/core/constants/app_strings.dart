/// The single source of truth for all user-facing strings in the Ohmitron app.
///
/// Required by UI_UX_BLUEPRINT.md Global Rule 7.
/// No hardcoded strings are permitted in widget files.
class AppStrings {
  const AppStrings._();

  // Common
  static const String appName = 'Ohmipower';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String ok = 'OK';
  static const String continueBtn = 'Continue';
  static const String retry = 'Retry';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String loading = 'Loading...';

  // Navigation / Screen Titles
  static const String serialEntryTitle = 'Device Setup';
  static const String authTitle = 'Login / Sign Up';
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String provisioningTitle = 'Wi-Fi Provisioning';
  static const String connectionTypeTitle = 'Connection Type';
  static const String dashboardTitle = 'Dashboard';
  static const String basicInfoTitle = 'Basic Information';
  static const String errorReportTitle = 'Error Report';
  static const String notificationsTitle = 'Notifications';
  static const String accountTitle = 'Account';

  // State
  static const String noDataAvailable = 'No data available at this time.';
  static const String connectionLost = 'Connection lost. Reconnecting...';
}
