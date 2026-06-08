# TRD.md
## Ohmitron Battery App — Technical Requirements Document
### Version 1.0 | Approved for Production

---

> This document defines every technical decision for the Ohmitron Battery App.
> It answers one question: exactly how is this app built?
> Every version is pinned. Every architecture decision is explained.
> No developer or AI agent may deviate from this document without updating it first.

---

## Table of Contents

1. Tech Stack — Pinned Versions
2. Flutter Project Configuration
3. Architecture Decisions
4. State Management Rules
5. Data Layer Architecture
6. Navigation Architecture
7. Mock Layer Specification
8. Error Handling Strategy
9. Performance Budgets
10. Security Constraints
11. Testing Requirements
12. Build Configuration
13. Package Governance Rules

---

## 1. Tech Stack — Pinned Versions

Every version below is pinned. No ranges. No `^` or `>=` in the TRD — the `pubspec.yaml` may use caret for patch updates only, but the minimum version is always what is listed here.

### 1.1 Core SDK

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | `3.44.0` | Stable channel only. Never use beta or master. |
| Dart SDK | `3.8.0` | Included with Flutter 3.44.0 |
| Android `minSdkVersion` | `26` | Android 8.0 minimum |
| Android `targetSdkVersion` | `35` | Android 15 |
| Android `compileSdkVersion` | `35` | Must match targetSdkVersion |
| Java | `17` | Required for Gradle 8+ |
| Gradle | `8.10.2` | Pinned in `android/gradle/wrapper/gradle-wrapper.properties` |
| Kotlin | `2.0.21` | Pinned in `android/build.gradle` |
| AGP (Android Gradle Plugin) | `8.7.3` | Pinned in `android/build.gradle` |

### 1.2 Firebase Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | `3.13.1` | Firebase initialisation — required first |
| `firebase_auth` | `5.5.2` | Email/Password authentication |
| `cloud_firestore` | `5.6.6` | Firestore database reads and writes |
| `firebase_messaging` | `15.2.5` | FCM push notification receipt |
| `flutter_local_notifications` | `18.0.1` | Display FCM notifications when app is foreground |

### 1.3 State Management

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | `3.3.1` | State management — sole state solution |
| `riverpod_annotation` | `3.3.1` | Code generation annotations for Riverpod |
| `riverpod_generator` | `3.0.2` | Build runner generator for Riverpod |

### 1.4 Navigation

| Package | Version | Purpose |
|---------|---------|---------|
| `go_router` | `14.8.0` | Declarative routing with guards |

### 1.5 Data Models

| Package | Version | Purpose |
|---------|---------|---------|
| `freezed` | `3.0.0` | Immutable data models with copyWith, equality |
| `freezed_annotation` | `3.0.0` | Annotations used by freezed |
| `json_serializable` | `6.9.5` | JSON serialisation code generation |
| `json_annotation` | `4.9.0` | Annotations used by json_serializable |

### 1.6 BLE (Bluetooth Low Energy)

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_blue_plus` | `1.35.3` | BLE scanning, connection, GATT communication |
| `permission_handler` | `12.0.0+1` | Runtime permission requests (BLE, location) |

### 1.7 UI and Assets

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_svg` | `2.0.17` | Render SVG assets (Ohmitron logo) |
| `google_fonts` | `6.2.1` | Inter font family |
| `barcode_widget` | `2.0.4` | Render Code 128 barcode for serial number |

### 1.8 Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| `screenshot` | `3.0.0` | Capture Dashboard widget as image |
| `share_plus` | `10.1.4` | Open Android system share sheet |
| `intl` | `0.19.0` | Date and time formatting |
| `uuid` | `4.5.1` | Generate unique IDs for mock data |

### 1.9 Build Tools (dev_dependencies)

| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | `2.4.15` | Code generation runner |
| `custom_lint` | `0.7.5` | Riverpod and freezed lint rules |
| `riverpod_lint` | `3.5.2` | Riverpod-specific lint rules |
| `flutter_test` | SDK | Widget and unit testing |
| `integration_test` | SDK | Integration testing |
| `mockito` | `5.4.5` | Mock generation for unit tests |

---

## 2. Flutter Project Configuration

### 2.1 pubspec.yaml Structure
```yaml
name: ohmitron
description: Ohmitron Battery Monitor App
version: 1.0.0+1

environment:
  sdk: '>=3.8.0 <4.0.0'
  flutter: '>=3.44.0'

flutter:
  uses-material-design: true
  assets:
    - assets/images/
  fonts:
    # Inter is loaded via google_fonts package — no local font assets needed
```

### 2.2 Asset Structure
```
assets/
└── images/
    ├── ohmitron_logo.svg       # Main brand logo (colour)
    └── ohmitron_logo_white.svg # White variant for sidebar header
```

### 2.3 Analysis Options (analysis_options.yaml)
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'

linter:
  rules:
    - prefer_const_constructors: true
    - prefer_const_declarations: true
    - avoid_print: true
    - use_super_parameters: true
```

---

## 3. Architecture Decisions

### 3.1 Pattern: Feature-First + MVVM

The project uses a **feature-first folder structure** where each feature is a self-contained module. Within each feature, the **MVVM pattern** separates concerns:

- **Model** — Freezed data classes in `models/`
- **View** — `ConsumerWidget` screens in `presentation/`
- **ViewModel** — Riverpod providers in `presentation/providers/`

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colours.dart        # All colour tokens as constants
│   │   ├── app_spacing.dart        # All spacing tokens as constants
│   │   ├── app_strings.dart        # All user-facing strings
│   │   └── app_text_styles.dart    # All TextStyle definitions
│   ├── routes/
│   │   └── app_router.dart         # GoRouter configuration
│   ├── themes/
│   │   └── app_theme.dart          # ThemeData configuration
│   └── widgets/                    # All 15 reusable widgets
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── app_badge.dart
│       ├── severity_chip.dart
│       ├── loading_indicator.dart
│       ├── empty_state_widget.dart
│       ├── confirmation_dialog.dart
│       ├── stale_data_banner.dart
│       ├── app_error_widget.dart
│       ├── animated_battery_gauge.dart
│       ├── error_list_item.dart
│       ├── notification_list_item.dart
│       ├── section_header.dart
│       ├── info_row.dart
│       └── device_name_header.dart
│
├── features/
│   ├── splash/
│   │   └── presentation/
│   │       └── splash_screen.dart
│   ├── auth/
│   │   └── presentation/
│   │       ├── auth_screen.dart
│   │       ├── forgot_password_screen.dart
│   │       └── providers/
│   │           └── auth_provider.dart
│   ├── device_setup/
│   │   └── presentation/
│   │       ├── serial_entry_screen.dart
│   │       ├── provisioning_screen.dart
│   │       ├── connection_type_screen.dart
│   │       └── providers/
│   │           └── device_setup_provider.dart
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── dashboard_screen.dart
│   │       ├── widgets/
│   │       │   └── stat_card.dart     # Dashboard-only sub-widget
│   │       └── providers/
│   │           └── dashboard_provider.dart
│   ├── basic_info/
│   │   └── presentation/
│   │       ├── basic_info_screen.dart
│   │       └── providers/
│   │           └── basic_info_provider.dart
│   ├── error_report/
│   │   └── presentation/
│   │       ├── error_report_screen.dart
│   │       └── providers/
│   │           └── error_report_provider.dart
│   ├── notifications/
│   │   └── presentation/
│   │       ├── notifications_screen.dart
│   │       └── providers/
│   │           └── notifications_provider.dart
│   └── account/
│       └── presentation/
│           ├── account_screen.dart
│           └── providers/
│               └── account_provider.dart
│
├── models/                           # Shared Freezed data models
│   ├── battery_status.dart
│   ├── device_info.dart
│   ├── error_entry.dart
│   ├── app_notification.dart
│   ├── app_user.dart
│   └── wifi_network.dart
│
├── services/                         # Data layer
│   ├── battery_data_source.dart      # Abstract interface
│   ├── mock_battery_data_source.dart # Mock implementation
│   └── providers/
│       └── data_source_provider.dart # Riverpod provider for data source
│
└── main.dart
```

### 3.2 Why Feature-First
- Each feature can be developed, tested, and debugged in isolation
- New developers can understand a feature by reading one folder
- Firebase integration only touches the `services/` layer — no screen code changes

### 3.3 Why MVVM with Riverpod
- Screens contain zero business logic — only UI code
- Providers are independently testable without a Flutter widget tree
- Riverpod's compile-time safety catches provider dependency errors before runtime

---

## 4. State Management Rules

These rules are absolute. The AI agent must follow them without exception.

### 4.1 Forbidden APIs
The following Riverpod APIs are **explicitly forbidden**. They are from Riverpod 2.x and are deprecated in Riverpod 3.x:

```dart
// NEVER USE THESE:
StateProvider          // Use Notifier instead
StateNotifier          // Use Notifier instead
StateNotifierProvider  // Use NotifierProvider instead
ChangeNotifier         // Use Notifier instead
ChangeNotifierProvider // Use NotifierProvider instead
```

### 4.2 Required APIs
Use only these Riverpod 3.x APIs:

```dart
// Synchronous state:
@riverpod
class MyNotifier extends Notifier<MyState> { }

// Async state (Future):
@riverpod
class MyAsyncNotifier extends AsyncNotifier<MyState> { }

// Stream state:
@riverpod
class MyStreamNotifier extends StreamNotifier<MyState> { }

// Simple computed values (read-only):
@riverpod
MyState myValue(MyValueRef ref) => /* computed value */;

// Simple async read-only:
@riverpod
Future<MyState> myFuture(MyFutureRef ref) async => /* fetch */;

// Stream read-only:
@riverpod
Stream<MyState> myStream(MyStreamRef ref) => /* stream */;
```

### 4.3 Widget Rules

```dart
// Every screen and stateful UI component:
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref.watch() for reactive state
    // Use ref.read() for one-time actions (button taps)
    // NEVER use ref.watch() inside a callback
  }
}

// NEVER use StatefulWidget
// NEVER use setState()
```

### 4.4 Provider Scope
- All providers are defined at the global scope using code generation (`@riverpod` annotation)
- `ProviderScope` wraps the entire app in `main.dart`
- Override providers in tests using `ProviderScope(overrides: [...])` 

### 4.5 Local UI State
Local UI state (text field focus, form values, stepper step index) that does not need to be shared across widgets uses `Notifier` with a simple state class. Never use `StatefulWidget` even for purely local state.

---

## 5. Data Layer Architecture

### 5.1 Abstract Interface
The `BatteryDataSource` abstract class defines the contract between UI and data. Both the mock and Firebase implementations must conform to this interface exactly.

```dart
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
  Future<void> createAccount(String name, String email,
                              String password, DateTime dob);
  Future<void> logout();
  Future<void> deleteAccount(String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> changePassword(String currentPassword, String newPassword);

  // Profile
  Future<void> updateProfile(String name, DateTime dob);

  // Device management
  Future<void> unpairDevice(String uid, String serial);
}
```

### 5.2 Mock Implementation Behaviour
See `MOCK_DATA_SPEC` section in the Agent file and Blueprint for complete mock behaviour. Key rules:

- `batteryStatusStream`: `Stream.periodic(const Duration(seconds: 30), (_) => _generateStatus())`
- All network delays simulated with `await Future.delayed(const Duration(seconds: 1))`
- `validateSerial`: returns `false` only for serial `"00000000"` — all others return `true`
- `login`: fails only for email `"fail@test.com"` — all others succeed
- `createAccount`: fails only for email `"taken@test.com"` — all others succeed

### 5.3 Feature Flag
```dart
// lib/core/constants/app_config.dart
class AppConfig {
  // Set to false ONLY after Phase 8 approval — never change manually
  // Agent must ask for explicit permission before setting to false
  static const bool useMockData = true;

  // Debug flags — mock only, not present in production
  static const bool mockIsLoggedIn = false;
  static const bool mockStaleData = false;
  static const bool mockHighTemp = false;
  static const bool mockLowSOC = false;
}
```

### 5.4 Data Source Provider
```dart
// lib/services/providers/data_source_provider.dart
@riverpod
BatteryDataSource batteryDataSource(BatteryDataSourceRef ref) {
  if (AppConfig.useMockData) {
    return MockBatteryDataSource();
  }
  return FirebaseBatteryDataSource(); // implemented in Phase 6
}
```

### 5.5 Firebase Implementation Rules (Phase 6)
When implementing `FirebaseBatteryDataSource`:

- **Never use `.snapshots()` (real-time listener) for telemetry.** Use `.get()` inside a `Timer.periodic(Duration(seconds: 30))` wrapped in a `StreamController`.
- **Always use `.get(GetOptions(source: Source.server))`** to bypass Firestore cache for telemetry reads — stale cached data would break the 45-second offline detection.
- **Always use `FieldValue.serverTimestamp()`** for all timestamp writes from the app side.
- **Always handle `FirebaseException`** and map to user-friendly error messages. Never expose Firebase error codes to the UI.

---

## 6. Navigation Architecture

### 6.1 GoRouter Configuration Rules
- `initialLocation`: `/splash`
- All routes defined in `lib/core/routes/app_router.dart`
- Router is provided via a Riverpod provider so guards can watch auth state reactively

### 6.2 Route Guards
```dart
redirect: (context, state) {
  final isAuthenticated = ref.read(authStateProvider).isAuthenticated;
  final hasPairedDevice = ref.read(currentSerialProvider) != null;
  final connectionTypeSeen = ref.read(connectionTypeSeenProvider);

  final protectedRoutes = ['/dashboard', '/basic-info', '/error-report',
                            '/notifications', '/account'];

  if (protectedRoutes.contains(state.matchedLocation)) {
    if (!isAuthenticated) return '/serial-entry';
    if (!hasPairedDevice) return '/serial-entry';
  }

  if (state.matchedLocation == '/connection-type') {
    if (connectionTypeSeen) return '/dashboard';
  }

  return null; // no redirect
}
```

### 6.3 Custom Page Transitions
Each route declares its transition type explicitly. No default Material transition is used.

```dart
// Forward slide (standard push):
CustomTransitionPage(
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
    SlideTransition(
      position: Tween(begin: Offset(1.0, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation,
                                  curve: Curves.easeOutCubic)),
      child: child,
    ),
  transitionDuration: const Duration(milliseconds: 300),
)

// Slide up (sidebar screens):
CustomTransitionPage(
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
    SlideTransition(
      position: Tween(begin: Offset(0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation,
                                  curve: Curves.easeOutCubic)),
      child: child,
    ),
  transitionDuration: const Duration(milliseconds: 350),
)

// Fade (Connection Type → Dashboard):
CustomTransitionPage(
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
    FadeTransition(opacity: animation, child: child),
  transitionDuration: const Duration(milliseconds: 400),
)
```

### 6.4 Back Stack Rules
- `/serial-entry`, `/connection-type` — always replace the stack (`go()` not `push()`)
- After logout, remove device, or delete account — use `context.go('/serial-entry')` (full replacement)
- Sidebar screens (`/basic-info`, `/error-report`) — pushed onto Dashboard stack (can go back)
- `/notifications`, `/account` — pushed onto Dashboard stack (can go back)

---

## 7. Mock Layer Specification

### 7.1 MockBatteryDataSource Implementation Details

```dart
class MockBatteryDataSource implements BatteryDataSource {
  // In-memory state (singleton behaviour)
  String _deviceName = 'Ohmitron Battery';
  bool _isProvisioned = false;
  bool _connectionTypeSeen = false;
  final List<ErrorEntry> _errors = [...mockErrors]; // pre-populated
  final List<AppNotification> _notifications = [];
  double _currentSoc = 78.0; // starts at 78%

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
    // Slowly decrease SOC
    _currentSoc = (_currentSoc - 0.5).clamp(0, 100);

    final soc = AppConfig.mockLowSOC ? 15.0 : _currentSoc;
    final temp = AppConfig.mockHighTemp ? 65.0 :
                 25.0 + Random().nextDouble() * 15;

    // Check notification triggers
    _checkNotificationTriggers(soc, temp);

    return BatteryStatus(
      stateOfCharge: soc,
      remainingTimeHours: soc / 20, // simple approximation
      voltage: 48.0 + Random().nextDouble() * 4,
      current: 12.0 + Random().nextDouble() * 5,
      dischargingWatts: 45.0 + Random().nextDouble() * 20,
      isCharging: false,
      isDischarging: true,
      balanceState: _cycleBalanceState(),
      protectionState: _cycleProtectionState(),
      temperatureCelsius: temp,
      timestamp: DateTime.now(),
    );
  }
}
```

### 7.2 Mock Error Accumulation
```dart
// Every 5 minutes during a mock session, add a new random error
Timer.periodic(const Duration(minutes: 5), (_) {
  if (_errors.length >= 20) _errors.removeLast();
  _errors.insert(0, ErrorEntry(
    code: mockErrorCodes[Random().nextInt(mockErrorCodes.length)],
    message: /* corresponding message */,
    severity: /* corresponding severity */,
    timestamp: DateTime.now(),
  ));
});
```

### 7.3 PROJECT_STATE.md Template
The agent creates this file at project root at the start of Phase 1 Step 1.

```markdown
# PROJECT_STATE.md

## Current Status
Phase: 1 — Project Foundation
Step: 1.1.1 — Create Flutter project
Status: In Progress

## Completed Steps
(none yet)

## Current Step Detail
[Description of exactly what is being built]

## Pending Steps
[Full list from Implementation Plan]

## Decisions Made During Build
(none yet — deviations from plan recorded here)

## Known Issues / Blockers
(none yet)

## Next Step
1.1.2 — Configure pubspec.yaml with all pinned packages
```

---

## 8. Error Handling Strategy

### 8.1 Error Classification

| Error Type | Source | UI Response |
|-----------|--------|-------------|
| Network unavailable | No internet | StaleDataBanner on Dashboard, SnackBar on others |
| Firestore read failure | Firebase SDK | AppErrorWidget with retry |
| Firestore write failure | Firebase SDK | SnackBar with error message |
| Auth failure (wrong password) | Firebase Auth | Inline field error or SnackBar |
| Auth failure (email exists) | Firebase Auth | SnackBar with suggestion |
| BLE permission denied | Android | Provisioning State 2 (permission denied UI) |
| BLE device not found | flutter_blue_plus | Provisioning State 4 (scan failed UI) |
| FCM token invalid | Firebase Messaging | Silently refresh token |
| Serial not found | Firestore + BLE | Serial Entry error message |
| Serial owned by other | Firestore | Serial Entry error message |

### 8.2 Error Message Rules
- Never show raw Firebase error codes (e.g., `auth/wrong-password`)
- Never show stack traces
- Never show `Exception` or `Error` type names
- All error messages are defined in `app_strings.dart`
- Messages are written in plain English, second person ("Your password is incorrect" not "Password incorrect")

### 8.3 Error Mapping (Firebase Auth)
```dart
String mapFirebaseAuthError(String code) {
  return switch (code) {
    'auth/wrong-password'        => AppStrings.errorWrongPassword,
    'auth/user-not-found'        => AppStrings.errorUserNotFound,
    'auth/email-already-in-use'  => AppStrings.errorEmailInUse,
    'auth/invalid-email'         => AppStrings.errorInvalidEmail,
    'auth/too-many-requests'     => AppStrings.errorTooManyRequests,
    'auth/network-request-failed'=> AppStrings.errorNoInternet,
    _                            => AppStrings.errorGeneric,
  };
}
```

### 8.4 Global Error Boundary
Wrap the `MaterialApp` in an `ErrorBoundary` widget that catches unhandled Flutter errors and displays a recovery screen instead of a red error screen. In production, log to Firebase Crashlytics.

---

## 9. Performance Budgets

| Metric | Target | Measurement |
|--------|--------|-------------|
| App cold start to Serial Entry | < 3 seconds | Measured on Snapdragon 665 device |
| Dashboard data refresh | < 2 seconds | From poll trigger to UI update |
| Animation frame budget | 16ms (60fps) | Profile mode, no jank |
| APK release size | < 25MB | `flutter build apk --release` |
| Firestore reads per session | < 200 | Firebase usage dashboard |
| Memory usage (steady state) | < 150MB | Android Profiler |

### 9.1 Performance Rules
- Never perform Firestore reads inside `build()` methods
- Never create `AnimationController` without disposing it
- Always use `const` constructors where possible
- Use `ListView.builder` for all lists — never `Column` with mapped children for dynamic lists
- Avoid `ClipRRect` on animated elements — use `borderRadius` on `Container` directly

---

## 10. Security Constraints

### 10.1 Storage Rules
```
✅ Allowed to store in memory (provider state):
   - Auth tokens (managed by Firebase SDK automatically)
   - Current serial number
   - Battery telemetry (latest only)
   - User profile data

✅ Allowed to store persistently (SharedPreferences):
   - connectionTypeSeen flag (boolean)
   - mockIsLoggedIn flag (debug builds only)

❌ Never store in any form (memory, disk, or logs):
   - Wi-Fi passwords (cleared immediately after BLE transmission)
   - User passwords
   - Firebase service account credentials
   - Raw Firebase Auth tokens in app code
```

### 10.2 BLE Security Rules
- BLE scan only starts after all required permissions are granted
- Serial number match verified before any credentials transmitted
- Wi-Fi password held in a local variable only — no provider, no storage
- Variable set to null immediately after `provisionWiFi()` completes

### 10.3 Input Sanitisation
- All form inputs trimmed of leading/trailing whitespace before processing
- Serial number input filtered to alphanumeric only via `TextInputFormatter`
- No user input is ever interpolated directly into Firestore queries — always use parameterised queries

---

## 11. Testing Requirements

### 11.1 Unit Tests
Location: `test/unit/`

| Test | File | What to Test |
|------|------|-------------|
| Mock data source | `mock_data_source_test.dart` | All methods, all error cases |
| Input validators | `validators_test.dart` | Serial format, email, password, age |
| Value formatters | `formatters_test.dart` | Remaining time, temperature, SOC |
| Error message mapper | `error_mapper_test.dart` | All Firebase auth error codes |

### 11.2 Widget Tests
Location: `test/widgets/`

Every reusable widget has its own test file. Tests cover:
- Default (data) state renders correctly
- Loading state renders correctly
- Error state renders correctly
- Empty state renders correctly (for lists)
- All interactions trigger correct callbacks

### 11.3 Screen Tests
Location: `test/screens/`

Each screen tested with `ProviderScope(overrides: [batteryDataSourceProvider.overrideWithValue(mockSource)])`.

Dashboard stale banner test (mandatory):
```dart
testWidgets('shows stale data banner after 45 seconds', (tester) async {
  final mock = MockBatteryDataSource();
  when(mock.batteryStatusStream)
    .thenAnswer((_) => Stream.value(fakeStatus));

  await tester.pumpWidget(ProviderScope(
    overrides: [batteryDataSourceProvider.overrideWithValue(mock)],
    child: const MaterialApp(home: DashboardScreen()),
  ));

  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 46));

  expect(find.text('Data Stale — Device may be offline'), findsOneWidget);
});
```

### 11.4 Integration Tests
Location: `integration_test/`

Full user journey test:
```
Splash → Serial Entry → Auth → Provisioning (mock) →
Connection Type → Dashboard → Basic Info → Error Report →
Notifications → Account → Logout → Serial Entry
```

### 11.5 Coverage Requirements
| Level | Minimum Coverage |
|-------|----------------|
| Data models | 100% |
| Validators and formatters | 100% |
| Mock data source | 90% |
| Screen widget tests | 80% |
| Integration test | Full happy path |

---

## 12. Build Configuration

### 12.1 android/app/build.gradle
```groovy
android {
  compileSdk 35
  defaultConfig {
    applicationId "com.ohmitron.battery_app"
    minSdk 26
    targetSdk 35
    versionCode 1
    versionName "1.0.0"
    multiDexEnabled true
  }
  buildTypes {
    release {
      minifyEnabled true
      shrinkResources true
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'),
                    'proguard-rules.pro'
      signingConfig signingConfigs.release
    }
    debug {
      applicationIdSuffix ".debug"
      versionNameSuffix "-debug"
      debuggable true
    }
  }
}
```

### 12.2 ProGuard Rules (proguard-rules.pro)
```
# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter Blue Plus
-keep class com.boskokg.flutter_blue_plus.** { *; }

# Dart/Flutter reflection
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
```

### 12.3 AndroidManifest.xml Permissions
```xml
<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- BLE — API 31+ -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
  android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>

<!-- BLE — API 23-30 (location required for BLE scanning) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- BLE feature declaration -->
<uses-feature android:name="android.hardware.bluetooth_le"
  android:required="true"/>

<!-- Foreground notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Screenshot / file sharing -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
  android:maxSdkVersion="28"/>
```

---

## 13. Package Governance Rules

### 13.1 Adding New Packages
A new package may only be added if:
1. It is not available in any existing package already in the TRD
2. It has a pub.dev score of ≥ 130 points
3. It has been updated within the last 6 months
4. It supports the minimum Android SDK (API 26)
5. This TRD document is updated before the package is added to `pubspec.yaml`

### 13.2 Updating Existing Packages
- Patch version updates (e.g., `3.3.1` → `3.3.2`): allowed without TRD update
- Minor version updates (e.g., `3.3.1` → `3.4.0`): requires TRD update and testing
- Major version updates (e.g., `3.3.1` → `4.0.0`): requires TRD update, full regression test, and explicit approval

### 13.3 Forbidden Packages
The following are explicitly forbidden due to deprecation, security, or architecture conflicts:
- `provider` — use Riverpod instead
- `get` / GetX — conflicts with Riverpod architecture
- `mobx` — conflicts with Riverpod architecture
- `shared_preferences` — use only for specific approved flags (connectionTypeSeen, debug flags)
- `hive` / `isar` / `sqflite` — no local database in V1
- `dio` — no custom HTTP client needed; Firebase SDK handles all network calls
- Any package with `dart:mirrors` — breaks tree shaking

---

*TRD.md — Version 1.0*
*Every version is pinned. Every decision is final until this document is updated.*
*The AI agent must read this document before writing any code.*
*No package, API, or architectural pattern not defined here is permitted without updating this document first.*
