# IMPLEMENTATION_PLAN.md
## Ohmitron Battery App — Complete Implementation Plan
### Version 1.0 | Approved for Production

---

> This document defines the exact order in which the Ohmitron app is built.
> Every phase, every step, every sub-step is listed explicitly.
> The AI agent builds one step at a time, stops, waits for verification,
> then proceeds. No step is skipped. No step is combined with another.
> The agent reads this document at the start of every session.

---

## Phase Overview

| Phase | Name | Description | Depends On |
|-------|------|-------------|-----------|
| 1 | Project Foundation | Scaffold, config, theme, constants, routing | Nothing |
| 2 | Core Reusable Widgets | All 15 shared widgets | Phase 1 |
| 3 | Frontend Screens | All 11 screens | Phase 2 |
| 4 | Navigation and Flow | Full routing, guards, transitions | Phase 3 |
| 5 | Mock Layer and Testing | Complete mock, all test scenarios | Phase 4 |
| 6 | Backend | Firebase, Cloud Functions, Security Rules | Phase 1 |
| 7 | Integration | Replace mock with Firebase | Phases 5 + 6 |
| 8 | Real Device Testing and QA | Testing on real hardware | Phase 7 |

**Phases 1–5 are frontend-first (no Firebase, no ESP32 needed).**
**Phase 6 can be built in parallel with Phases 3–5 by a separate backend developer.**
**Phase 7 requires both Phase 5 and Phase 6 to be complete.**

---

## How to Read This Document

Each step follows this format:

```
### Step X.X.X — [Step Name]
**What:** [Exactly what is built]
**Files:** [Files created or modified]
**Test:** [Exactly what to verify]
**Done when:** [The specific condition that marks this step complete]
```

---

# PHASE 1 — Project Foundation

**Goal:** A runnable Flutter project with the correct structure, theme, constants, and routing. No screens yet. No widgets yet. Just the skeleton everything else builds on.

---

## Step 1.1 — Flutter Project Creation

### Step 1.1.1 — Create Flutter Project
**What:** Create a new Flutter project named `ohmitron` using Flutter 3.44.0 stable.
```bash
flutter create --org com.ohmitron --platforms android ohmitron
cd ohmitron
```
**Files:** Entire Flutter project scaffold generated
**Test:** Run `flutter run` — default counter app launches without error
**Done when:** App runs on Android emulator, no errors in terminal

### Step 1.1.2 — Create PROJECT_STATE.md
**What:** Create `PROJECT_STATE.md` at project root using the template from TRD.md Section 7.3. Set status to Phase 1, Step 1.1.3.
**Files:** `PROJECT_STATE.md` (created at root)
**Test:** File exists at root, contains all required sections
**Done when:** File is readable and correctly formatted

### Step 1.1.3 — Configure pubspec.yaml
**What:** Replace the default `pubspec.yaml` with the complete package list from TRD.md Section 1. Add all dependencies with exact pinned versions. Add assets configuration for `assets/images/`.
**Files:** `pubspec.yaml`
**Test:** Run `flutter pub get` — zero errors. Run `flutter pub outdated` — confirm versions match TRD.
**Done when:** `flutter pub get` succeeds, all packages resolve

### Step 1.1.4 — Create Asset Folders and Add Logo
**What:** Create `assets/images/` folder. Copy `ohmitron_logo.svg` and `ohmitron_logo_white.svg` to `assets/images/`.
**Files:** `assets/images/ohmitron_logo.svg`, `assets/images/ohmitron_logo_white.svg`
**Test:** Run `flutter pub get` — assets registered. Verify SVG files are in correct path.
**Done when:** No pubspec asset errors, files exist at correct paths

### Step 1.1.5 — Configure Android Build Files
**What:** Update `android/app/build.gradle` with `minSdk 26`, `targetSdk 35`, `compileSdk 35`, `applicationId "com.ohmitron.battery_app"`. Update `android/build.gradle` with Kotlin `2.0.21`. Update `android/gradle/wrapper/gradle-wrapper.properties` with Gradle `8.10.2`. Add all required permissions to `AndroidManifest.xml` from TRD.md Section 12.3.
**Files:** `android/app/build.gradle`, `android/build.gradle`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/app/src/main/AndroidManifest.xml`
**Test:** Run `flutter build apk --debug` — builds successfully. Check manifest has all BLE and internet permissions.
**Done when:** APK builds without error, manifest permissions verified

### Step 1.1.6 — Configure analysis_options.yaml
**What:** Replace default `analysis_options.yaml` with the configuration from TRD.md Section 2.3. Exclude generated files from analysis.
**Files:** `analysis_options.yaml`
**Test:** Run `flutter analyze` — zero errors or warnings on the empty project
**Done when:** `flutter analyze` reports clean

---

## Step 1.2 — Core Constants

### Step 1.2.1 — App Colours
**What:** Create `lib/core/constants/app_colours.dart`. Define all 12 colour tokens from FRONTEND_SKILL.md Section 2.1 as `const Color` values. Use `Color(0xFFxxxxxx)` format.
```dart
// Example format:
const Color colorBrandGreen = Color(0xFF3DAE2B);
const Color colorBackground = Color(0xFFF7F8FA);
// ... all 12 colours
```
**Files:** `lib/core/constants/app_colours.dart`
**Test:** Open file, verify all 12 colours match FRONTEND_SKILL.md exactly. Import in a test widget and confirm no compilation errors.
**Done when:** All 12 colours defined, file compiles cleanly

### Step 1.2.2 — App Spacing
**What:** Create `lib/core/constants/app_spacing.dart`. Define all spacing tokens from FRONTEND_SKILL.md Section 4.1 as `const double` values.
```dart
const double space2 = 2.0;
const double space4 = 4.0;
// ... all spacing tokens
```
**Files:** `lib/core/constants/app_spacing.dart`
**Test:** Verify all values are multiples of 4. File compiles cleanly.
**Done when:** All spacing tokens defined, every value is a multiple of 4

### Step 1.2.3 — App Text Styles
**What:** Create `lib/core/constants/app_text_styles.dart`. Define all 12 text styles from FRONTEND_SKILL.md Section 3.2 using Google Fonts Inter. Import `google_fonts` package.
```dart
import 'package:google_fonts/google_fonts.dart';

final TextStyle displayLarge = GoogleFonts.inter(
  fontSize: 48, fontWeight: FontWeight.w700, height: 56/48, letterSpacing: -1.5,
);
// ... all 12 text styles
```
**Files:** `lib/core/constants/app_text_styles.dart`
**Test:** Verify all 12 styles match FRONTEND_SKILL.md type scale. File compiles cleanly. Inter font loads at runtime.
**Done when:** All 12 styles defined, Inter font resolves at runtime

### Step 1.2.4 — App Strings
**What:** Create `lib/core/constants/app_strings.dart`. Define all user-facing strings as `const String` values. Include all error messages, labels, button text, empty state messages, and dialog content defined throughout the Blueprint.
**Files:** `lib/core/constants/app_strings.dart`
**Test:** File compiles cleanly. Verify all error messages from Blueprint Section error cases are present.
**Done when:** All strings from Blueprint are defined as constants

### Step 1.2.5 — App Config
**What:** Create `lib/core/constants/app_config.dart` with the feature flag configuration from TRD.md Section 5.3.
```dart
class AppConfig {
  static const bool useMockData = true;
  static const bool mockIsLoggedIn = false;
  static const bool mockStaleData = false;
  static const bool mockHighTemp = false;
  static const bool mockLowSOC = false;
}
```
**Files:** `lib/core/constants/app_config.dart`
**Test:** File compiles cleanly. `useMockData` is `true`.
**Done when:** Config file exists with all flags set to correct defaults

---

## Step 1.3 — App Theme

### Step 1.3.1 — Build AppTheme
**What:** Create `lib/core/themes/app_theme.dart`. Build `ThemeData` using colour tokens and text styles. Configure `ColorScheme`, `AppBarTheme` (transparent background, zero elevation), `ScaffoldBackgroundColor` (`colorBackground`), `InputDecorationTheme`, `ElevatedButtonTheme`, `TextButtonTheme`, `DrawerTheme`. Apply Inter via `GoogleFonts.interTextTheme()`.
**Files:** `lib/core/themes/app_theme.dart`
**Test:** Apply theme in `main.dart`, run app. Verify scaffold background is `#F7F8FA` (off-white), not pure white. Verify app bar is transparent.
**Done when:** App renders with correct background colour and transparent app bar

---

## Step 1.4 — Data Models

### Step 1.4.1 — BatteryStatus Model
**What:** Create `lib/models/battery_status.dart`. Freezed model with all fields from DB_SCHEMA.md Section 4.2. Run `build_runner`.
```dart
@freezed
class BatteryStatus with _$BatteryStatus {
  const factory BatteryStatus({
    double? stateOfCharge,
    double? remainingTimeHours,
    required double voltage,
    required double current,
    // ... all fields
    required DateTime timestamp,
  }) = _BatteryStatus;
  factory BatteryStatus.fromJson(Map<String, dynamic> json) =>
    _$BatteryStatusFromJson(json);
}
```
**Files:** `lib/models/battery_status.dart`, `lib/models/battery_status.freezed.dart` (generated), `lib/models/battery_status.g.dart` (generated)
**Test:** Run `dart run build_runner build`. Zero errors. Model instantiates correctly. `copyWith` works.
**Done when:** Model generates cleanly, `build_runner` exits with zero errors

### Step 1.4.2 — DeviceInfo Model
**What:** Create `lib/models/device_info.dart`. Freezed model with all fields from DB_SCHEMA.md Section 3.1.
**Files:** `lib/models/device_info.dart` + generated files
**Test:** `build_runner` succeeds. Model instantiates correctly.
**Done when:** Model generates cleanly

### Step 1.4.3 — ErrorEntry Model
**What:** Create `lib/models/error_entry.dart`. Freezed model with fields from DB_SCHEMA.md Section 5.1.
**Files:** `lib/models/error_entry.dart` + generated files
**Test:** `build_runner` succeeds.
**Done when:** Model generates cleanly

### Step 1.4.4 — AppNotification Model
**What:** Create `lib/models/app_notification.dart`. Freezed model with fields from DB_SCHEMA.md Section 6.1.
**Files:** `lib/models/app_notification.dart` + generated files
**Test:** `build_runner` succeeds.
**Done when:** Model generates cleanly

### Step 1.4.5 — AppUser Model
**What:** Create `lib/models/app_user.dart`. Freezed model with fields from DB_SCHEMA.md Section 2.1.
**Files:** `lib/models/app_user.dart` + generated files
**Test:** `build_runner` succeeds.
**Done when:** Model generates cleanly

### Step 1.4.6 — WifiNetwork Model
**What:** Create `lib/models/wifi_network.dart`. Simple Freezed model: `ssid (String)`, `signalStrength (int)`.
**Files:** `lib/models/wifi_network.dart` + generated files
**Test:** `build_runner` succeeds.
**Done when:** Model generates cleanly

---

## Step 1.5 — Data Source Interface and Mock

### Step 1.5.1 — Abstract BatteryDataSource Interface
**What:** Create `lib/services/battery_data_source.dart`. Define the abstract class with all methods from TRD.md Section 5.1. No implementation — interface only.
**Files:** `lib/services/battery_data_source.dart`
**Test:** File compiles cleanly. No implementation details.
**Done when:** Interface defined, compiles cleanly

### Step 1.5.2 — MockBatteryDataSource — Auth Methods
**What:** Create `lib/services/mock_battery_data_source.dart`. Implement `login`, `createAccount`, `logout`, `getCurrentUser`, `sendPasswordResetEmail`, `changePassword`. Use behaviours from TRD.md Section 5.2 and Blueprint mock data bindings.
**Files:** `lib/services/mock_battery_data_source.dart`
**Test:** Instantiate mock, call `login('test@test.com', 'password')` — returns success. Call `login('fail@test.com', 'password')` — throws error. Call `getCurrentUser()` — returns mock user.
**Done when:** All auth methods work as specified

### Step 1.5.3 — MockBatteryDataSource — Device Methods
**What:** Implement `validateSerial`, `getDeviceInfo`, `updateDeviceName`, `createDeviceDocument`, `provisionWiFi`, `setProvisioned`, `forceReprovision` in MockBatteryDataSource.
**Files:** `lib/services/mock_battery_data_source.dart` (modified)
**Test:** `validateSerial('OHM00123456')` returns true. `validateSerial('00000000')` returns false. `getDeviceInfo(serial)` returns mock DeviceInfo.
**Done when:** All device methods work as specified

### Step 1.5.4 — MockBatteryDataSource — Telemetry Stream
**What:** Implement `batteryStatusStream` in MockBatteryDataSource using `Stream.periodic(Duration(seconds: 30))`. Implement `_generateStatus()` with all mock behaviours from TRD.md Section 7.1. Respect `AppConfig.mockStaleData`, `mockHighTemp`, `mockLowSOC` flags.
**Files:** `lib/services/mock_battery_data_source.dart` (modified)
**Test:** Subscribe to stream, verify it emits within 30 seconds. Set `mockStaleData = true`, verify stream emits only one value. Set `mockHighTemp = true`, verify temperature > 60.
**Done when:** Stream emits correctly, all debug flags work

### Step 1.5.5 — MockBatteryDataSource — Error and Notification Methods
**What:** Implement `getErrors`, `getNotifications`, `markNotificationRead`, `deleteNotification`, `clearAllNotifications`, `unpairDevice`, `deleteAccount`, `updateProfile`. Pre-populate mock errors from DB_SCHEMA.md Section 5.2 error registry.
**Files:** `lib/services/mock_battery_data_source.dart` (modified)
**Test:** `getErrors(serial)` returns 7 pre-populated errors. `deleteNotification(id)` removes from in-memory list. `unpairDevice(uid, serial)` clears device state.
**Done when:** All methods work, mock error list pre-populated

### Step 1.5.6 — Data Source Provider
**What:** Create `lib/services/providers/data_source_provider.dart`. Define Riverpod provider that returns `MockBatteryDataSource` when `AppConfig.useMockData = true`.
**Files:** `lib/services/providers/data_source_provider.dart`
**Test:** `ProviderContainer().read(batteryDataSourceProvider)` returns `MockBatteryDataSource` instance. File compiles cleanly.
**Done when:** Provider resolves to correct implementation

---

## Step 1.6 — GoRouter Setup

### Step 1.6.1 — Define All Routes (Placeholder Screens)
**What:** Create `lib/core/routes/app_router.dart`. Define all 11 routes with placeholder `Scaffold` widgets (just a `Text` with the route name). Configure `initialLocation: '/splash'`. No guards yet — add in Phase 4.
**Files:** `lib/core/routes/app_router.dart`
**Test:** Run app. Navigating to each route manually shows the placeholder text. No errors.
**Done when:** All 11 routes defined, app navigates without crash

### Step 1.6.2 — Wire Router to App
**What:** Update `lib/main.dart`. Wrap app in `ProviderScope`. Replace `MaterialApp` with `MaterialApp.router` using `GoRouter`. Apply `AppTheme`.
**Files:** `lib/main.dart`
**Test:** Run app. Splash placeholder appears. No errors. Theme applied (background off-white).
**Done when:** App starts with router, shows splash placeholder, theme applied

---

**Phase 1 Complete. Push to GitHub before starting Phase 2.**

---

# PHASE 2 — Core Reusable Widgets

**Goal:** Build all 15 reusable widgets from FRONTEND_SKILL.md Section 5. Every widget is fully implemented, styled, and tested in isolation before any screen is built. Screens in Phase 3 import these widgets — they never rebuild them.

---

## Step 2.1 — AppButton

### Step 2.1.1 — AppButton Widget
**What:** Build `lib/core/widgets/app_button.dart`. Three variants (primary, secondary, destructive). Scale animation on press (0.97, 100ms). Loading state with `CircularProgressIndicator`. Disabled state. Full specification in FRONTEND_SKILL.md Section 5.1.
**Files:** `lib/core/widgets/app_button.dart`
**Test:** Add all three variants to a test screen. Verify: green primary button, outlined secondary, red destructive. Tap each — scale animation plays. Tap with `isLoading: true` — spinner shows. Tap with `isEnabled: false` — button is grey, unresponsive.
**Done when:** All three variants render correctly, animations work, loading/disabled states work

---

## Step 2.2 — AppTextField

### Step 2.2.1 — AppTextField Widget
**What:** Build `lib/core/widgets/app_text_field.dart`. Label above field. Green border on focus (200ms animation). Red border on error. Show/hide toggle for password fields. Error message fade-in (150ms). Full specification in FRONTEND_SKILL.md Section 5.2.
**Files:** `lib/core/widgets/app_text_field.dart`
**Test:** Add to test screen. Verify: label visible above field. Tap field — border turns green (animated). Set error — border turns red, error message fades in below. Password field — eye icon toggles visibility.
**Done when:** All states render, focus animation works, error state works, password toggle works

---

## Step 2.3 — AppBadge

### Step 2.3.1 — AppBadge Widget
**What:** Build `lib/core/widgets/app_badge.dart`. Five colour variants. Pill shape (100px border radius). Full specification in FRONTEND_SKILL.md Section 5.3.
**Files:** `lib/core/widgets/app_badge.dart`
**Test:** Render all 5 variants on a test screen. Verify pill shape, correct colours, correct text style.
**Done when:** All 5 variants render correctly

---

## Step 2.4 — SeverityChip

### Step 2.4.1 — SeverityChip Widget
**What:** Build `lib/core/widgets/severity_chip.dart`. Three fixed variants: info (blue), warning (amber), critical (red). Specification in FRONTEND_SKILL.md Section 5.4.
**Files:** `lib/core/widgets/severity_chip.dart`
**Test:** Render all 3 variants. Verify colours match `colorInfoBlue`, `colorWarningAmber`, `colorErrorRed`.
**Done when:** All 3 variants render correctly

---

## Step 2.5 — LoadingIndicator

### Step 2.5.1 — LoadingIndicator Widget
**What:** Build `lib/core/widgets/loading_indicator.dart`. Two variants: full-screen (centred with optional label) and inline (small spinner). Brand green colour. Fade-in animation 200ms. Specification in FRONTEND_SKILL.md Section 5.5.
**Files:** `lib/core/widgets/loading_indicator.dart`
**Test:** Render both variants. Full-screen centred, inline 20px size. Both green.
**Done when:** Both variants render correctly

---

## Step 2.6 — EmptyStateWidget

### Step 2.6.1 — EmptyStateWidget Widget
**What:** Build `lib/core/widgets/empty_state_widget.dart`. Centred icon (64px, disabled colour), title (headlineSmall), subtitle (bodyMedium). Fade-in 300ms. Specification in FRONTEND_SKILL.md Section 5.6.
**Files:** `lib/core/widgets/empty_state_widget.dart`
**Test:** Render with test data. Verify centred layout, correct text styles, fade-in animation on mount.
**Done when:** Widget renders correctly, animation plays

---

## Step 2.7 — ConfirmationDialog

### Step 2.7.1 — ConfirmationDialog Widget
**What:** Build `lib/core/widgets/confirmation_dialog.dart`. Max width 320px, 20px border radius. Scale + fade entrance animation (250ms). Two button variants (Primary or Destructive for confirm). Specification in FRONTEND_SKILL.md Section 5.7.
**Files:** `lib/core/widgets/confirmation_dialog.dart`
**Test:** Show dialog from a test button. Verify scale animation on open, scrim behind dialog. Tap outside — closes. Tap Cancel — closes. Tap Confirm — triggers callback.
**Done when:** Dialog opens with animation, both buttons work, scrim shows

---

## Step 2.8 — StaleDataBanner

### Step 2.8.1 — StaleDataBanner Widget
**What:** Build `lib/core/widgets/stale_data_banner.dart`. Full-width amber banner. Left accent border 4px. Slide down + fade in (300ms) on show, slide up + fade out (250ms) on hide. Never manually dismissible. Specification in FRONTEND_SKILL.md Section 5.8.
**Files:** `lib/core/widgets/stale_data_banner.dart`
**Test:** Toggle banner visible/invisible from a test button. Verify slide-down animation on show, slide-up on hide. Verify amber background at 15% opacity, 4px left border.
**Done when:** Banner animates correctly, styling matches spec

---

## Step 2.9 — AppErrorWidget

### Step 2.9.1 — AppErrorWidget Widget
**What:** Build `lib/core/widgets/app_error_widget.dart`. Centred layout. Red error icon (56px). Title and subtitle. Primary retry button. Fade-in 300ms. Specification in FRONTEND_SKILL.md Section 5.9.
**Files:** `lib/core/widgets/app_error_widget.dart`
**Test:** Render with test data and retry callback. Verify centred layout, red icon, retry button triggers callback.
**Done when:** Widget renders correctly, retry callback works

---

## Step 2.10 — AnimatedBatteryGauge

### Step 2.10.1 — AnimatedBatteryGauge Widget
**What:** Build `lib/core/widgets/animated_battery_gauge.dart`. This is the most complex widget in the project. Rectangular shape with terminal. Animated fill (left to right). Colour transition green→amber→red based on SOC thresholds. Entrance animation (1200ms easeOutCubic). Update animation (800ms easeInOut). Colour transition animation (600ms easeInOut). Charging pulse (repeating opacity animation). Lightning bolt icon when charging. SOC percentage text centred inside. Full specification in FRONTEND_SKILL.md Section 5.10.
**Files:** `lib/core/widgets/animated_battery_gauge.dart`
**Test:**
- Render at SOC 80% — green fill, 80% displayed, 80% width filled
- Render at SOC 30% — amber fill
- Render at SOC 15% — red fill
- Toggle `isCharging: true` — pulse animation starts, bolt icon appears
- Change SOC from 80 to 20 — fill animates to new width AND colour changes
- On first render — fill animates from 0 to target SOC (1200ms entrance)
**Done when:** All animations work, colour thresholds correct, charging state correct

---

## Step 2.11 — ErrorListItem

### Step 2.11.1 — ErrorListItem Widget
**What:** Build `lib/core/widgets/error_list_item.dart`. SeverityChip + error code + timestamp in top row. Error message below. Divider at bottom. Specification in FRONTEND_SKILL.md Section 5.11.
**Files:** `lib/core/widgets/error_list_item.dart`
**Test:** Render with all three severity variants. Verify layout, timestamp format, divider.
**Done when:** All severity variants render correctly

---

## Step 2.12 — NotificationListItem

### Step 2.12.1 — NotificationListItem Widget
**What:** Build `lib/core/widgets/notification_list_item.dart`. Unread green dot. Title, body, timestamp. Swipe-to-delete (red background with trash icon). Unread dot fades out on tap. Specification in FRONTEND_SKILL.md Section 5.12.
**Files:** `lib/core/widgets/notification_list_item.dart`
**Test:** Render read and unread variants. Swipe left — red delete background reveals. Tap unread item — green dot fades out. Delete callback triggers on swipe dismiss.
**Done when:** Swipe-to-delete works, read/unread states work, animations correct

---

## Step 2.13 — SectionHeader

### Step 2.13.1 — SectionHeader Widget
**What:** Build `lib/core/widgets/section_header.dart`. headlineSmall text, correct padding. Specification in FRONTEND_SKILL.md Section 5.13.
**Files:** `lib/core/widgets/section_header.dart`
**Test:** Render with test label. Verify typography and padding.
**Done when:** Renders correctly

---

## Step 2.14 — InfoRow

### Step 2.14.1 — InfoRow Widget
**What:** Build `lib/core/widgets/info_row.dart`. Label (bodySmall, grey) above value (bodyLarge, black). Divider at bottom. Height 56px. Specification in FRONTEND_SKILL.md Section 5.14.
**Files:** `lib/core/widgets/info_row.dart`
**Test:** Render with test data. Verify label/value hierarchy, divider, height.
**Done when:** Renders correctly

---

## Step 2.15 — DeviceNameHeader

### Step 2.15.1 — DeviceNameHeader Widget
**What:** Build `lib/core/widgets/device_name_header.dart`. headlineLarge Bold text. Truncates at 20 characters with ellipsis. Specification in FRONTEND_SKILL.md Section 5.15.
**Files:** `lib/core/widgets/device_name_header.dart`
**Test:** Render with short name — displays fully. Render with name > 20 chars — truncates with ellipsis.
**Done when:** Truncation works correctly

---

**Phase 2 Complete. Push to GitHub before starting Phase 3.**

---

# PHASE 3 — Frontend Screens

**Goal:** Build all 11 screens. Each screen is fully implemented with all states (loading, error, empty, data) and connected to the mock data layer via Riverpod providers. Screens use only widgets from Phase 2 and constants from Phase 1.

**Build order:** Dashboard first (proves mock works), then auth screens, then setup screens, then secondary screens.

---

## Step 3.1 — Dashboard Screen

### Step 3.1.1 — Dashboard Provider
**What:** Create `lib/features/dashboard/presentation/providers/dashboard_provider.dart`. `StreamProvider<BatteryStatus>` consuming `batteryDataSourceProvider.batteryStatusStream`. Add stale detection logic.
**Files:** `lib/features/dashboard/presentation/providers/dashboard_provider.dart`
**Test:** In a test widget, watch `dashboardProvider`. Verify it emits BatteryStatus every 30 seconds from mock. Set `mockStaleData = true`, verify stream stops after first emission.
**Done when:** Provider emits data from mock, stale flag respected

### Step 3.1.2 — Dashboard StatCard Sub-Widget
**What:** Create `lib/features/dashboard/presentation/widgets/stat_card.dart`. Dashboard-specific card for key metrics. Label + icon row, value below. Specification in Blueprint Section 7.
**Files:** `lib/features/dashboard/presentation/widgets/stat_card.dart`
**Test:** Render with test data. Verify layout and typography.
**Done when:** Renders correctly

### Step 3.1.3 — Dashboard App Bar
**What:** Build `DashboardAppBar` widget within dashboard feature. Hamburger left, `DeviceNameHeader` centre, three action icons right (share, notifications, account). Notifications icon shows red badge when unread count > 0.
**Files:** `lib/features/dashboard/presentation/dashboard_screen.dart` (partial)
**Test:** Run app, navigate to dashboard placeholder. Verify app bar layout. Tap hamburger — drawer opens (placeholder). Verify badge shows when `unreadCountProvider > 0`.
**Done when:** App bar renders correctly, badge logic works

### Step 3.1.4 — Dashboard Sidebar (Drawer)
**What:** Build `AppDrawer` widget. Green header with logo and device name. Three navigation items (Home, Basic Info, Error Report). Active state for Home. Slide-in animation from left (300ms). Specification in Blueprint Section 7 and FRONTEND_SKILL.md Section 9.
**Files:** `lib/features/dashboard/presentation/dashboard_screen.dart` (partial)
**Test:** Open drawer, verify green header, three items. Tap Home — drawer closes. Verify slide animation.
**Done when:** Drawer renders, animates, and closes on tap

### Step 3.1.5 — Dashboard Body — Loading State
**What:** Add loading state to Dashboard body. Shows `LoadingIndicator` full-screen variant when `batteryStatusProvider` is loading AND no cached data.
**Files:** `lib/features/dashboard/presentation/dashboard_screen.dart` (partial)
**Test:** Set stream to delay 3 seconds. Verify loading indicator shows during delay.
**Done when:** Loading state displays correctly

### Step 3.1.6 — Dashboard Body — Battery Gauge and Stats Grid
**What:** Add `AnimatedBatteryGauge` at top of dashboard body (SOC from provider). Add 2-column `StatCard` grid below (Remaining Time, Discharging Watts). Wire all values from `batteryStatusProvider`.
**Files:** `lib/features/dashboard/presentation/dashboard_screen.dart` (partial)
**Test:** Run app. Verify battery gauge shows and fills correctly. Verify stat cards show values from mock stream. Values update every 30 seconds.
**Done when:** Gauge and stats grid render with live mock data

### Step 3.1.7 — Dashboard Body — Status Section
**What:** Add flat status section (Charging, Discharging, Balance, Protection, Temperature). Each as a `StatusRow` in a card container. Wire all values from `batteryStatusProvider`. Temperature colour changes based on value.
**Files:** `lib/features/dashboard/presentation/dashboard_screen.dart` (partial)
**Test:** Verify all 5 status rows render. Set mock temperature to 55 — amber colour. Set to 65 — red colour. Verify balance and protection badges match mock values.
**Done when:** Status section renders with correct colours and values

### Step 3.1.8 — Dashboard Body — Error Summary Row and Stale Banner
**What:** Add tappable error summary row at bottom. Add `StaleDataBanner` at top (visible based on stale detection). Wire `StaleDataBanner` to stale state. Pull-to-refresh triggers immediate re-query.
**Files:** `lib/features/dashboard/presentation/dashboard_screen.dart` (complete)
**Test:** Set `mockStaleData = true`. Wait 46 seconds. Verify stale banner slides down. Pull to refresh — banner dismisses if data updates. Tap error row — navigates to placeholder error report.
**Done when:** Stale banner works, pull-to-refresh works, error row tappable

### Step 3.1.9 — Dashboard Share Functionality
**What:** Implement share button logic. Capture dashboard body screenshot using `screenshot` package. Open share sheet via `share_plus`. Brief visual feedback animation on camera icon tap.
**Files:** `lib/features/dashboard/presentation/dashboard_screen.dart` (complete)
**Test:** Tap share icon — share sheet opens with screenshot image. Verify image captures dashboard body only (not app bar).
**Done when:** Screenshot captured, share sheet opens with image

---

## Step 3.2 — Auth Screen (Login / Sign Up)

### Step 3.2.1 — Auth Provider
**What:** Create auth provider with login, signup, and logout methods. Manages loading states and error messages.
**Files:** `lib/features/auth/presentation/providers/auth_provider.dart`
**Test:** Call login with mock credentials — provider state changes to loading then success. Call with `fail@test.com` — error state set.
**Done when:** Provider manages auth state correctly

### Step 3.2.2 — Login Tab
**What:** Build Login tab UI. Email field, password field with toggle, Forgot Password link, Log In button. Wire to auth provider. All error states. Specification in Blueprint Section 3.
**Files:** `lib/features/auth/presentation/auth_screen.dart` (partial)
**Test:** Fill valid credentials — login succeeds (navigates to next step). Fill `fail@test.com` — SnackBar error shows. Leave field empty — inline validation on submit.
**Done when:** Login flow works, all error states handled

### Step 3.2.3 — Sign Up Tab
**What:** Build Sign Up tab UI. All 5 fields, date picker, terms checkbox, Create Account button. Full validation. Wire to auth provider. Specification in Blueprint Section 3.
**Files:** `lib/features/auth/presentation/auth_screen.dart` (complete)
**Test:** Submit empty form — first field error shows. Submit with `taken@test.com` — SnackBar error. Valid form — account created, proceeds to serial validation.
**Done when:** Sign up flow works, all validation and error states work

---

## Step 3.3 — Forgot Password Screen

### Step 3.3.1 — Forgot Password Screen
**What:** Build complete Forgot Password screen with 2-state animated stepper. State 1 (email entry), State 2 (confirmation). Slide transition between states. Wire to mock auth service. Specification in Blueprint Section 4.
**Files:** `lib/features/auth/presentation/forgot_password_screen.dart`
**Test:** Navigate from Login tab. Enter email, tap Send. State 1 slides out, State 2 slides in. Tap Back to Login — returns to auth screen Login tab.
**Done when:** Both states render, transition animation works, back navigation works

---

## Step 3.4 — Serial Number Entry Screen

### Step 3.4.1 — Serial Entry Provider
**What:** Create provider managing serial input, validation, Firestore check, and BLE scan simulation. Manages `pendingSerialProvider`.
**Files:** `lib/features/device_setup/presentation/providers/device_setup_provider.dart`
**Test:** Call validateSerial('OHM00123456') — returns success. Call validateSerial('00000000') — returns error. Verify `pendingSerialProvider` stores serial before login redirect.
**Done when:** Provider validates serials correctly, pending serial stored

### Step 3.4.2 — Serial Entry Screen
**What:** Build complete Serial Entry screen. Logo, heading, text field with alphanumeric formatter, error display, Continue button. All 6 exit conditions from Blueprint Section 2. Specification in Blueprint Section 2.
**Files:** `lib/features/device_setup/presentation/serial_entry_screen.dart`
**Test:** Enter invalid characters — filtered out. Enter < 8 chars — button disabled. Enter '00000000' — device not found error. Enter 'OHM00123456' when not logged in — navigates to auth (serial retained). Enter valid serial when logged in — proceeds to provisioning check.
**Done when:** All 6 exit conditions work, validation works, serial retained through auth

---

## Step 3.5 — Wi-Fi Provisioning Screen

### Step 3.5.1 — Provisioning Screen — All 7 States
**What:** Build complete Provisioning screen with all 7 states from Blueprint Section 5. Permission check, permission denied, BLE scanning (with animated scan rings), scan failed, Wi-Fi selection, sending credentials, provisioning complete. All state transitions with cross-fade animation (200ms out, 300ms in).
**Files:** `lib/features/device_setup/presentation/provisioning_screen.dart`
**Test:**
- On load — permission check state appears briefly
- If permission granted — BLE scan state shows with animated rings
- After 30 seconds — scan failed state
- Mock device found — Wi-Fi list appears with 4 mock networks
- Select network, enter password, tap Connect — sending state (2 seconds) — success state
- Success auto-navigates to Connection Type after 2 seconds
- Permission denied — shows Open Settings button
**Done when:** All 7 states render, all transitions work, mock provisioning flow completes

---

## Step 3.6 — Connection Type Screen

### Step 3.6.1 — Connection Type Screen
**What:** Build complete Connection Type screen. Active Wi-Fi card (green border), disabled Bluetooth card (grey, 50% opacity). Staggered entrance animation for cards. Sets `connectionTypeSeenProvider = true` on Continue. Specification in Blueprint Section 6.
**Files:** `lib/features/device_setup/presentation/connection_type_screen.dart`
**Test:** Screen renders. Cards animate in with stagger. Tap Continue — `connectionTypeSeenProvider` becomes true. Navigate away and return — router guard redirects to dashboard (screen not shown again).
**Done when:** Both cards render correctly, stagger animation works, seen flag set correctly

---

## Step 3.7 — Basic Information Screen

### Step 3.7.1 — Basic Info Provider
**What:** Create provider fetching `DeviceInfo` from mock data source. Manages device name update state.
**Files:** `lib/features/basic_info/presentation/providers/basic_info_provider.dart`
**Test:** Provider loads mock device info. `updateDeviceName` call updates in-memory state.
**Done when:** Provider works correctly

### Step 3.7.2 — Basic Information Screen
**What:** Build complete Basic Info screen. Four sections: Device Name (editable with SET button), Device Details (read-only InfoRows), Barcode (Code 128 generated from serial), Connection section. Specification in Blueprint Section 8.
**Files:** `lib/features/basic_info/presentation/basic_info_screen.dart`
**Test:**
- Screen loads with mock data (serial OHM00123456, model OHM-BMS-100, etc.)
- Barcode renders for serial number
- Edit name, tap SET — success toast shows
- Verify slides up from bottom on enter, slides down on back
**Done when:** All 4 sections render, SET button saves name, barcode displays

---

## Step 3.8 — Error Report Screen

### Step 3.8.1 — Error Report Provider
**What:** Create provider fetching latest 20 errors from mock data source.
**Files:** `lib/features/error_report/presentation/providers/error_report_provider.dart`
**Test:** Provider returns 7 pre-populated mock errors ordered by timestamp descending.
**Done when:** Provider returns correct data

### Step 3.8.2 — Error Report Screen
**What:** Build complete Error Report screen. Loading, empty, and data states. `ErrorListItem` for each error. Pull-to-refresh. Specification in Blueprint Section 9.
**Files:** `lib/features/error_report/presentation/error_report_screen.dart`
**Test:**
- Screen loads showing 7 mock errors
- Most recent first
- All three severity badges visible (info, warning, critical)
- Pull to refresh reloads list
- Empty state shows when errors list is cleared
**Done when:** All 3 states work, errors ordered correctly, pull-to-refresh works

---

## Step 3.9 — Notifications Screen

### Step 3.9.1 — Notifications Provider
**What:** Create provider managing in-memory notifications list. Mark read, delete, clear all methods.
**Files:** `lib/features/notifications/presentation/providers/notifications_provider.dart`
**Test:** Provider starts empty. After mock high-temp trigger — notification added. Mark read — `read` becomes true. Delete — removed from list.
**Done when:** Provider manages notifications correctly

### Step 3.9.2 — Notifications Screen
**What:** Build complete Notifications screen. Empty state, data state with `NotificationListItem`. Swipe-to-delete. Clear All with confirmation dialog. Mark read on tap. Unread badge count syncs with `unreadCountProvider`. Specification in Blueprint Section 10.
**Files:** `lib/features/notifications/presentation/notifications_screen.dart`
**Test:**
- Empty state shows "No Notifications" when list is empty
- After mock triggers notification — item appears with green dot
- Tap item — green dot fades out
- Swipe item — deletes with animation
- Tap Clear All — confirmation dialog, then all items animate out
**Done when:** All interactions work, empty state works, animations correct

---

## Step 3.10 — Account Screen

### Step 3.10.1 — Account Provider
**What:** Create provider managing profile updates, password change, remove device, logout, and delete account.
**Files:** `lib/features/account/presentation/providers/account_provider.dart`
**Test:** `updateProfile` updates in-memory user. `logout` clears all state. `unpairDevice` clears serial.
**Done when:** All provider methods work

### Step 3.10.2 — Account Screen — Profile and Security Sections
**What:** Build Account screen Profile section (editable name, DOB, read-only email, Save button) and Security section (Change Password ListTile → opens bottom sheet).
**Files:** `lib/features/account/presentation/account_screen.dart` (partial)
**Test:** Edit name, tap Save — success toast. Tap Change Password — bottom sheet slides up. Enter wrong current password — field error shows. Valid change — success toast.
**Done when:** Profile saves, password change bottom sheet works

### Step 3.10.3 — Account Screen — Device and Account Sections
**What:** Build Device section (paired device info, Remove Device button) and Account section (Logout, Delete Account). All confirmation dialogs. All cascade operations. Specification in Blueprint Section 11.
**Files:** `lib/features/account/presentation/account_screen.dart` (complete)
**Test:**
- Remove Device — confirmation dialog, cascade clears state, navigates to Serial Entry
- Logout — confirmation dialog, clears state, navigates to Serial Entry
- Delete Account — two-step confirmation (dialog then password), cascade, navigates to Serial Entry
- HapticFeedback fires on destructive confirmations
**Done when:** All destructive actions work, dialogs show, navigation correct after each

---

## Step 3.11 — Splash Screen

### Step 3.11.1 — Splash Screen
**What:** Build complete Splash screen. Logo + wordmark + tagline with fade-in animation (600ms). Auto-navigates after 2 seconds. Silent auth check during 2-second window. Specification in Blueprint Section 1.
**Files:** `lib/features/splash/presentation/splash_screen.dart`
**Test:** App launches — splash shows logo with fade-in. After 2 seconds — auto-navigates to Serial Entry. Verify `mockIsLoggedIn = true` causes correct auth state to be pre-loaded.
**Done when:** Fade animation works, auto-navigation fires at 2 seconds

---

**Phase 3 Complete. Push to GitHub before starting Phase 4.**

---

# PHASE 4 — Navigation and Flow

**Goal:** Wire all screens into a complete, guarded navigation flow. Every route transition uses the correct animation. Every guard redirects correctly.

---

## Step 4.1 — Route Transition Animations

### Step 4.1.1 — Implement All Custom Page Transitions
**What:** Update `app_router.dart`. Replace all placeholder routes with `CustomTransitionPage`. Implement three transition types: forward slide (standard), slide up (sidebar screens), fade (Connection Type → Dashboard). Exact specifications in TRD.md Section 6.3.
**Files:** `lib/core/routes/app_router.dart`
**Test:** Navigate through every route pair. Verify: Serial→Auth slides right. Auth→Dashboard fades. Basic Info slides up. All back navigations reverse correctly.
**Done when:** Every route uses correct transition type

---

## Step 4.2 — Route Guards

### Step 4.2.1 — Implement Auth and Device Guards
**What:** Add redirect logic to GoRouter. Protected routes redirect to Serial Entry if not authenticated or no paired device. Connection Type route redirects to Dashboard if `connectionTypeSeen = true`. Serial retention through login redirect.
**Files:** `lib/core/routes/app_router.dart`
**Test:**
- Navigate to /dashboard without auth — redirected to /serial-entry
- Navigate to /connection-type after `connectionTypeSeen = true` — redirected to /dashboard
- Enter serial, navigate to auth, log in — returns to provisioning check (not Serial Entry)
**Done when:** All guards redirect correctly, serial retained through auth

---

## Step 4.3 — Full Flow Verification

### Step 4.3.1 — Complete New User Flow
**What:** No code changes. Manual end-to-end verification of the complete new user flow from cold start to Dashboard.
**Test:** Complete this flow without errors:
- Cold start → Splash (2s) → Serial Entry
- Enter valid serial → redirected to Auth (serial retained)
- Sign up new account → returns to serial validation
- Serial validated → Provisioning screen
- Complete mock provisioning → Connection Type screen
- Tap Continue → Dashboard (connection type seen flag set)
- Re-launch app → Splash → Serial Entry → Dashboard directly (no Connection Type)
**Done when:** Complete new user flow works without errors

### Step 4.3.2 — Complete Returning User Flow
**What:** No code changes. Manual verification of returning user flow.
**Test:** Complete this flow:
- Set `mockIsLoggedIn = true`
- Cold start → Serial Entry → auto-validate → Dashboard
- Navigate to each secondary screen and back
- Logout → Serial Entry
- Remove Device → Serial Entry (all state cleared)
**Done when:** Complete returning user flow works without errors

---

**Phase 4 Complete. Push to GitHub before starting Phase 5.**

---

# PHASE 5 — Mock Layer and Testing

**Goal:** Verify every screen state, every edge case, and every user scenario using the mock data layer. Write unit and widget tests.

---

## Step 5.1 — Mock Scenario Verification

### Step 5.1.1 — Stale Data Scenario
**What:** Enable `mockStaleData = true`. Verify stale banner appears on Dashboard after 45 seconds. Values remain visible but dimmed. Pull-to-refresh updates banner state.
**Test:** Time-based test — set flag, wait 46 seconds, verify banner.
**Done when:** Stale banner appears and dismisses correctly

### Step 5.1.2 — High Temperature Scenario
**What:** Enable `mockHighTemp = true`. Verify temperature shows red on Dashboard. Verify push notification triggered (in-app notification added to list).
**Test:** Set flag, wait for next stream emission, verify red temperature, verify notification in Notifications screen.
**Done when:** High temp correctly colours UI and triggers notification

### Step 5.1.3 — Low SOC Scenario
**What:** Enable `mockLowSOC = true`. Verify battery gauge is red, SOC shows 15%. Verify low battery notification triggered.
**Test:** Set flag, verify gauge colour, verify notification.
**Done when:** Low SOC scenario works correctly

### Step 5.1.4 — Protection State Scenario
**What:** Configure mock to cycle protectionState to `over_current` for 2 cycles. Verify protection badge shows red on Dashboard. Verify notification triggered.
**Test:** Watch Dashboard for protection state change, verify notification.
**Done when:** Protection state scenario works

### Step 5.1.5 — Error List Growth Scenario
**What:** Let mock run for 10+ minutes. Verify new errors added every 5 minutes. Verify list never exceeds 20 items.
**Test:** Check error count at 5, 10, 15, 20 minutes. Verify cap at 20.
**Done when:** Error list cap enforced correctly

---

## Step 5.2 — Unit Tests

### Step 5.2.1 — Model Tests
**What:** Write unit tests for all 6 data models. Test `copyWith`, equality, and JSON serialisation.
**Files:** `test/unit/models/`
**Test:** Run `flutter test test/unit/models/` — 100% pass rate.
**Done when:** All model tests pass

### Step 5.2.2 — Validator Tests
**What:** Write unit tests for all form validators (serial format, email, password, age).
**Files:** `test/unit/validators_test.dart`
**Test:** Run `flutter test test/unit/validators_test.dart` — 100% pass rate.
**Done when:** All validator tests pass

### Step 5.2.3 — Formatter Tests
**What:** Write unit tests for all value formatters (remaining time, temperature, SOC, protection state).
**Files:** `test/unit/formatters_test.dart`
**Test:** Run tests — 100% pass rate.
**Done when:** All formatter tests pass

---

## Step 5.3 — Widget Tests

### Step 5.3.1 — Reusable Widget Tests
**What:** Write widget tests for all 15 reusable widgets. Test all states for each.
**Files:** `test/widgets/`
**Test:** Run `flutter test test/widgets/` — all pass.
**Done when:** All widget tests pass

### Step 5.3.2 — Dashboard Stale Banner Test
**What:** Write the mandatory stale banner widget test from TRD.md Section 11.3.
**Files:** `test/screens/dashboard_test.dart`
**Test:** Test passes — stale banner appears after 45 seconds of no stream emissions.
**Done when:** Test passes

---

## Step 5.4 — Integration Test

### Step 5.4.1 — Full Journey Integration Test
**What:** Write integration test covering the complete user journey from splash to dashboard to logout.
**Files:** `integration_test/full_journey_test.dart`
**Test:** Run `flutter test integration_test/full_journey_test.dart` — passes.
**Done when:** Integration test passes

---

**Phase 5 Complete. Full frontend with mock layer is verified.**
**Push to GitHub. This is the supervisor demo build.**
**Supervisor reviews and approves before Phase 6 begins.**

---

# PHASE 6 — Backend

**Goal:** Implement all Firebase backend components. Runs independently of Phases 3–5 (can be built in parallel). Uses Firebase Emulator Suite — never the production Firebase project during development.

---

## Step 6.1 — Firebase Project Setup

### Step 6.1.1 — Create Firebase Project
**What:** Create Firebase project in Firebase Console. Enable Authentication (Email/Password), Cloud Firestore (Native mode), FCM, Cloud Functions (Blaze plan).
**Test:** Firebase Console shows all services enabled.
**Done when:** All Firebase services active

### Step 6.1.2 — Install Firebase CLI and Emulators
**What:** Install Firebase CLI. Run `firebase init`. Configure Firestore, Functions, Emulators. Set Node.js 20 for Functions.
**Files:** `firebase.json`, `.firebaserc`, `functions/package.json`
**Test:** Run `firebase emulators:start` — all emulators start without error.
**Done when:** Emulators start cleanly

---

## Step 6.2 — Firestore Configuration

### Step 6.2.1 — Deploy Security Rules
**What:** Create `firestore.rules` from DB_SCHEMA.md Section 7 exactly. Deploy to emulator.
**Files:** `firestore.rules`
**Test:** Test each rule: authenticated user can read own data, cannot read others'. Unauthenticated requests rejected. Client cannot write telemetry or errors.
**Done when:** All security rules work as specified

### Step 6.2.2 — Deploy Composite Indexes
**What:** Create `firestore.indexes.json` from DB_SCHEMA.md Section 8 exactly.
**Files:** `firestore.indexes.json`
**Test:** Run alerts query against emulator — no index error.
**Done when:** Query runs without index error

---

## Step 6.3 — Cloud Functions

### Step 6.3.1 — Setup Functions Project
**What:** Create TypeScript Cloud Functions project in `functions/` folder. Install Firebase Admin SDK and Functions SDK.
**Files:** `functions/src/index.ts`, `functions/package.json`, `functions/tsconfig.json`
**Test:** `npm run build` in functions/ — zero TypeScript errors.
**Done when:** Functions project builds cleanly

### Step 6.3.2 — Implement onTelemetryWrite Function
**What:** Implement `onTelemetryWrite` Cloud Function from DB_SCHEMA.md Section 9.1. All 3 notification triggers. Deduplication logic. `sendNotification` helper.
**Files:** `functions/src/index.ts` (partial)
**Test:** Using emulator, write a telemetry document with temp > 60. Verify `alerts` document created. Verify FCM payload formed correctly. Verify deduplication prevents second alert within 10 minutes.
**Done when:** All 3 triggers work, deduplication works

### Step 6.3.3 — Implement onErrorCreated Function
**What:** Implement `onErrorCreated` Cloud Function from DB_SCHEMA.md Section 9.2.
**Files:** `functions/src/index.ts` (partial)
**Test:** Create an error document in emulator. Verify alert created.
**Done when:** Error trigger creates alert correctly

### Step 6.3.4 — Implement removeDevice Function
**What:** Implement `removeDevice` HTTPS Callable from DB_SCHEMA.md Section 9.3. Handle `forceReprovision` flag.
**Files:** `functions/src/index.ts` (partial)
**Test:** Call function via emulator. Verify: `ownerUid` set to null, alerts deleted, `provisioned` reset when `forceReprovision: true`.
**Done when:** All cascade operations work

### Step 6.3.5 — Implement deleteAccount Function
**What:** Implement `deleteAccount` HTTPS Callable from DB_SCHEMA.md Section 9.4.
**Files:** `functions/src/index.ts` (complete)
**Test:** Call function via emulator. Verify: user document deleted, `ownerUid` nulled on device, all alerts deleted, Firebase Auth user deleted.
**Done when:** Full cascade works, Auth user deleted

---

## Step 6.4 — FCM Setup

### Step 6.4.1 — FCM Configuration
**What:** Configure FCM in Flutter app. Add `google-services.json` to Android project. Set up notification channel `ohmitron_alerts`. Implement `onTokenRefresh` listener. Implement foreground notification handler.
**Files:** `android/app/google-services.json`, `lib/main.dart` (modified)
**Test:** App receives FCM token on launch. Token written to Firestore (emulator). Foreground notification displays when app is open.
**Done when:** FCM token lifecycle works, foreground notification displays

---

**Phase 6 Complete. Push to GitHub before starting Phase 7.**

---

# PHASE 7 — Integration

**Goal:** Replace the mock data layer with the real Firebase implementation. `useMockData` remains `true` during this phase — both layers run in parallel for testing.

---

## Step 7.1 — Firebase Data Source Implementation

### Step 7.1.1 — FirebaseBatteryDataSource — Auth Methods
**What:** Create `lib/services/firebase_battery_data_source.dart`. Implement all auth methods using Firebase Auth SDK.
**Test:** Login with real Firebase credentials (emulator). Verify Auth user created. Verify `users` document written.
**Done when:** Auth methods work against Firebase emulator

### Step 7.1.2 — FirebaseBatteryDataSource — Device and Telemetry Methods
**What:** Implement device methods and `batteryStatusStream` using Timer-based polling with `.get()`. Never use `.snapshots()`.
**Test:** Manually write a `telemetry/latest` document to emulator. App reads and displays it. After 30 seconds, app re-reads.
**Done when:** Polling works, data displays correctly from Firestore

### Step 7.1.3 — FirebaseBatteryDataSource — Remaining Methods
**What:** Implement all remaining methods: errors, notifications, profile, device management.
**Test:** Each method tested against emulator with real Firestore documents.
**Done when:** All methods work

### Step 7.1.4 — Switch Data Source Provider
**What:** Update `data_source_provider.dart` to return `FirebaseBatteryDataSource` when `AppConfig.useMockData = false`. **Do NOT change `useMockData` yet** — just wire the provider.
**Test:** With `useMockData = true` — still uses mock. Ready to switch.
**Done when:** Provider correctly routes based on flag

---

## Step 7.2 — Integration Verification

### Step 7.2.1 — Full Flow with Firebase Emulator
**What:** Set `useMockData = false` temporarily. Run complete user flow against Firebase Emulator Suite.
**Test:** Complete entire new user flow using real Firebase (emulator). Verify all data writes and reads. Re-set `useMockData = true` after testing.
**Done when:** All screens work with real Firebase data (emulator)

---

**Phase 7 Complete. Push to GitHub.**
**Do not change useMockData in the committed code.**

---

# PHASE 8 — Real Device Testing and QA

**Goal:** Test the complete app on real Android hardware with a real ESP32 device. Only after full approval does the mock layer get deactivated.

---

## Step 8.1 — Pre-Production Configuration

### Step 8.1.1 — Switch to Production Firebase
**What:** Replace Firebase emulator configuration with production Firebase project. Ensure `useMockData = true` still set.
**Test:** App connects to production Firebase. Real Auth, real Firestore.
**Done when:** App uses production Firebase with mock data layer still active

---

## Step 8.2 — Real Device Testing

Each test item in this checklist is its own step. The agent tracks completion in `PROJECT_STATE.md`.

### Step 8.2.1 — BLE Provisioning with Real ESP32
**Test:** App successfully pairs with real ESP32 via BLE. Wi-Fi provisioning completes. `provisioned = true` written to production Firestore.
**Done when:** Real device provisioned successfully

### Step 8.2.2 — Real Telemetry on Dashboard
**Test:** Real ESP32 writes telemetry to Firestore. Dashboard displays real data. Values update every 30 seconds.
**Done when:** Live data visible on Dashboard

### Step 8.2.3 — Stale Banner with Real Offline
**Test:** Power off ESP32. Wait 46 seconds. Stale banner appears on Dashboard.
**Done when:** Stale banner appears on real device offline

### Step 8.2.4 — Push Notifications — Real Device
**Test:** Trigger a high temperature condition on real BMS. FCM notification received on real Android phone within 10 seconds.
**Done when:** Real push notification received

### Step 8.2.5 — Error Report with Real BMS Errors
**Test:** Real BMS generates an error. Error appears in Error Report screen.
**Done when:** Real error visible in app

### Step 8.2.6 — Multi-Device Testing
**Test:** Test on minimum 3 different Android devices. Test on Android 8.0 (API 26) specifically.
**Done when:** App works correctly on all test devices

### Step 8.2.7 — Account Lifecycle on Real Firebase
**Test:** Create account, pair device, remove device, re-pair, delete account. All cascade operations verified in Firebase Console.
**Done when:** All account operations work on production Firebase

### Step 8.2.8 — Crashlytics Verification
**Test:** Monitor Firebase Crashlytics for 24 hours of real use. Zero crashes recorded.
**Done when:** 24 hours clean in Crashlytics

### Step 8.2.9 — Firebase Free Tier Verification
**Test:** Check Firebase usage dashboard. Confirm daily reads/writes within free tier limits.
**Done when:** Usage confirmed within free tier

### Step 8.2.10 — Supervisor Formal Sign-Off
**Test:** Supervisor reviews the app on real hardware and formally approves.
**Done when:** Written supervisor approval received

---

## Step 8.3 — Mock Layer Deactivation

### Step 8.3.1 — Agent Requests Permission
**What:** After all Step 8.2.x items are verified, agent follows the Mock Layer Deactivation Protocol from AGENT.md Section 14. Asks for explicit written confirmation.
**Done when:** Confirmation received: "APPROVED — SET useMockData = false"

### Step 8.3.2 — Set useMockData = false
**What:** Change `AppConfig.useMockData` to `false`. Run full test suite. Build release APK.
**Files:** `lib/core/constants/app_config.dart`
**Test:** Run `flutter test` — all tests pass. Run `flutter build apk --release` — builds cleanly. App on real device uses real Firebase exclusively.
**Done when:** Release APK built, all tests pass, mock layer inactive

---

## Step 8.4 — Final Release

### Step 8.4.1 — Final GitHub Push
**What:** Final push to GitHub with `useMockData = false` and clean test results.
**Test:** Repository is clean. No debug flags active. Release APK verified.
**Done when:** Final push complete, project complete

---

**Phase 8 Complete. Project complete. 🎉**

---

## Summary

| Phase | Steps | Estimated Scope |
|-------|-------|----------------|
| 1 — Foundation | 22 steps | Project setup |
| 2 — Reusable Widgets | 15 steps | All shared widgets |
| 3 — Frontend Screens | 30 steps | All 11 screens |
| 4 — Navigation | 5 steps | Routing and flow |
| 5 — Mock Testing | 11 steps | Testing and QA |
| 6 — Backend | 11 steps | Firebase and functions |
| 7 — Integration | 5 steps | Wire real Firebase |
| 8 — Real Device QA | 12 steps | Hardware testing |
| **Total** | **111 steps** | |

---

*IMPLEMENTATION_PLAN.md — Version 1.0*
*Each step is atomic — one thing, fully done, fully verified.*
*The agent never skips a step. The agent never combines steps.*
*Progress is tracked in PROJECT_STATE.md after every verified step.*
