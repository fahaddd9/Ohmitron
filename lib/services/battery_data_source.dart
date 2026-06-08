import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/battery_status.dart';
import '../models/device_info.dart';
import '../models/error_entry.dart';

/// The contract between the UI and data layer.
/// 
/// Defined by TRD.md Section 5.1.
/// Both MockBatteryDataSource and FirebaseBatteryDataSource must implement this.
abstract class BatteryDataSource {
  // Telemetry — stream driven by 30s timer internally
  Stream<BatteryStatus> get batteryStatusStream;

  // Device
  Future<DeviceInfo> getDeviceInfo(String serial);
  Future<void> updateDeviceName(String serial, String newName);
  Future<bool> validateSerial(String serial);
  Future<void> createDeviceDocument(String serial, DeviceInfo info);

  // Provisioning
  Future<bool> provisionWiFi(String ssid, String password);
  Future<void> setProvisioned(String serial);
  Future<void> forceReprovision(String serial);

  // Errors
  Future<List<ErrorEntry>> getErrors(String serial);

  // Notifications
  Future<List<AppNotification>> getNotifications(String uid, String serial);
  Future<void> markNotificationRead(String id);
  Future<void> deleteNotification(String id);
  Future<void> clearAllNotifications(String uid, String serial);

  // Auth
  Future<AppUser?> getCurrentUser();
  Future<void> login(String email, String password);
  Future<void> createAccount(
    String name,
    String email,
    String password,
    DateTime dob,
  );
  Future<void> logout();
  Future<void> deleteAccount(String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> changePassword(String currentPassword, String newPassword);

  // Profile
  Future<void> updateProfile(String name, DateTime dob);

  // Device management
  Future<void> unpairDevice(String uid, String serial);
}
