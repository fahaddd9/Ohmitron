import 'dart:async';
import 'dart:math';

import '../core/constants/app_config.dart';
import '../models/app_notification.dart';
import '../models/app_user.dart';
import '../models/battery_status.dart';
import '../models/device_info.dart';
import '../models/error_entry.dart';
import 'battery_data_source.dart';

/// Mock implementation of the BatteryDataSource for testing and UI development.
class MockBatteryDataSource implements BatteryDataSource {
  AppUser? _currentUser;

  MockBatteryDataSource() {
    if (AppConfig.mockIsLoggedIn) {
      _currentUser = AppUser(
        uid: 'mock-uid-1234',
        name: 'John Doe',
        email: 'john.doe@example.com',
        dob: DateTime(1990, 1, 1),
        deviceSerial: 'OHM00123456',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
    }

    // Every 5 minutes during a mock session, add a new random error (TRD 7.2)
    Timer.periodic(const Duration(minutes: 5), (_) {
      if (_errors.length >= 20) _errors.removeLast();
      final random = Random();
      final mockCodes = ['temp_warning', 'cell_imbalance', 'low_voltage', 'high_current'];
      _errors.insert(0, ErrorEntry(
        id: 'err-${DateTime.now().millisecondsSinceEpoch}',
        errorCode: mockCodes[random.nextInt(mockCodes.length)],
        message: 'Mock error generated automatically',
        severity: ['low', 'medium', 'high'][random.nextInt(3)],
        timestamp: DateTime.now(),
      ));
    });
  }

  // ---------------------------------------------------------------------------
  // Auth Methods (Step 1.5.2)
  // ---------------------------------------------------------------------------

  @override
  Future<AppUser?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'fail@test.com') {
      throw Exception('Invalid email or password');
    }
    _currentUser = AppUser(
      uid: 'mock-uid-5678',
      name: 'Test User',
      email: email,
      dob: DateTime(1995, 5, 5),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
  }

  @override
  Future<void> createAccount(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'taken@test.com') {
      throw Exception('Email is already in use');
    }
    _currentUser = AppUser(
      uid: 'mock-uid-9012',
      name: name,
      email: email,
      dob: dob,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<void> deleteAccount(String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Success silently
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    // Success silently
  }

  @override
  Future<void> updateProfile(String name, DateTime dob) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name, dob: dob);
    }
  }

  // ---------------------------------------------------------------------------
  // Telemetry (Step 1.5.4)
  // ---------------------------------------------------------------------------

  double _currentSoc = 78.0;

  @override
  Stream<BatteryStatus> get batteryStatusStream {
    if (AppConfig.mockStaleData) {
      // Emit one value then stop — stale banner appears after 45s
      return Stream.value(_generateStatus());
    }
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => _generateStatus(),
    ).asBroadcastStream();
  }

  BatteryStatus _generateStatus() {
    _currentSoc = (_currentSoc - 0.5).clamp(0, 100);

    final soc = AppConfig.mockLowSOC ? 15.0 : _currentSoc;
    final random = Random();
    final temp = AppConfig.mockHighTemp ? 65.0 : 25.0 + random.nextDouble() * 15;

    // Check notification triggers (stubbed for now, full impl in 1.5.5)
    _checkNotificationTriggers(soc, temp);

    return BatteryStatus(
      timestamp: DateTime.now(),
      stateOfCharge: soc,
      remainingTimeHours: soc / 20,
      voltage: 48.0 + random.nextDouble() * 4,
      current: 12.0 + random.nextDouble() * 5,
      dischargingWatts: 45.0 + random.nextDouble() * 20,
      isCharging: false,
      isDischarging: true,
      balanceState: _cycleBalanceState(),
      protectionState: _cycleProtectionState(),
      temperatureCelsius: temp,
    );
  }

  void _checkNotificationTriggers(double soc, double temp) {
    if (soc <= 20.0 && !_notifications.any((n) => n.title == 'Low Battery Warning' && !n.read)) {
      _notifications.insert(0, AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}-soc',
        targetUserUid: 'mock-uid-1234',
        deviceSerial: 'OHM00123456',
        title: 'Low Battery Warning',
        body: 'Battery level has dropped to ${soc.toStringAsFixed(1)}%.',
        timestamp: DateTime.now(),
        read: false,
      ));
    }
    
    if (temp >= 60.0 && !_notifications.any((n) => n.title == 'High Temperature Warning' && !n.read)) {
      _notifications.insert(0, AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}-temp',
        targetUserUid: 'mock-uid-1234',
        deviceSerial: 'OHM00123456',
        title: 'High Temperature Warning',
        body: 'Battery temperature reached ${temp.toStringAsFixed(1)}°C.',
        timestamp: DateTime.now(),
        read: false,
      ));
    }
  }

  String _cycleBalanceState() {
    // Simple mock toggling between idle and balancing
    return DateTime.now().minute % 2 == 0 ? 'idle' : 'balancing';
  }

  String _cycleProtectionState() {
    // Simple mock returning clear or over_current
    return AppConfig.mockHighTemp ? 'over_temp' : 'clear';
  }

  // ---------------------------------------------------------------------------
  // Device Methods (Step 1.5.3)
  // ---------------------------------------------------------------------------

  @override
  Future<DeviceInfo> getDeviceInfo(String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    return DeviceInfo(
      ownerUid: _currentUser?.uid,
      provisioned: true,
      friendlyName: 'Ohmipower Alpha',
      deviceModel: 'OHM-ESP32-V1',
      firmwareVersion: '1.2.4',
      bmsModel: 'JBD-SP04S034',
      bmsId: 'BMS-9988',
      connectedSsid: 'HomeNetwork_5G',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<void> updateDeviceName(String serial, String newName) async {
    await Future.delayed(const Duration(seconds: 1));
    // Success silently
  }

  @override
  Future<bool> validateSerial(String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    return serial != '00000000';
  }

  @override
  Future<void> createDeviceDocument(String serial, DeviceInfo info) async {
    await Future.delayed(const Duration(seconds: 1));
    // Success silently
  }

  @override
  Future<void> unpairDevice(String uid, String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    // Success silently
  }

  // ---------------------------------------------------------------------------
  // Provisioning (Step 1.5.3)
  // ---------------------------------------------------------------------------

  @override
  Future<bool> provisionWiFi(String ssid, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate successful provisioning connection to ESP32
    return true;
  }

  @override
  Future<void> setProvisioned(String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    // Success silently
  }

  @override
  Future<void> forceReprovision(String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    // Success silently
  }

  // ---------------------------------------------------------------------------
  // Errors (Step 1.5.5)
  // ---------------------------------------------------------------------------

  final List<ErrorEntry> _errors = [
    ErrorEntry(
      id: 'err-1',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      errorCode: 'temp_warning',
      message: 'Temperature approaching upper limit',
      severity: 'medium',
    ),
    ErrorEntry(
      id: 'err-2',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      errorCode: 'cell_imbalance',
      message: 'Cell voltage delta exceeds 200mV',
      severity: 'high',
    ),
  ];

  @override
  Future<List<ErrorEntry>> getErrors(String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_errors);
  }

  // ---------------------------------------------------------------------------
  // Notifications (Step 1.5.5)
  // ---------------------------------------------------------------------------

  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif-1',
      targetUserUid: 'mock-uid-1234',
      deviceSerial: 'OHM00123456',
      title: 'Welcome',
      body: 'Your Ohmipower device is successfully paired.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      read: false,
    ),
  ];

  @override
  Future<List<AppNotification>> getNotifications(String uid, String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_notifications.where((n) => n.targetUserUid == uid && n.deviceSerial == serial).toList().reversed);
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> clearAllNotifications(String uid, String serial) async {
    await Future.delayed(const Duration(seconds: 1));
    _notifications.removeWhere((n) => n.targetUserUid == uid && n.deviceSerial == serial);
  }
}
