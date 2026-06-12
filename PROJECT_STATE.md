# PROJECT_STATE.md

## Current Status
Phase: 4 — Navigation and Flow
Step: 4.1.1 & 4.2.1 — Page Transitions + Route Guards
Status: Awaiting Verification

## Completed Steps
- [1.1.1] Create Flutter project — Flutter 3.44.0, Dart 3.12.0 — Verified ✅
- [1.1.2] Create PROJECT_STATE.md — Verified ✅
- [1.1.3] Configure pubspec.yaml — Verified ✅
- [1.1.4] Create asset folders and add logo — Verified ✅
- [1.1.5] Configure Android build files — Verified ✅
- [1.1.6] Configure analysis_options.yaml — Verified ✅
- [1.2.1] App colours — Verified ✅
- [1.2.2] App spacing — Verified ✅
- [1.2.3] App text styles — Verified ✅
- [1.2.4] App strings — Verified ✅
- [1.2.5] App config — Verified ✅
- [1.3.1] Build AppTheme — Verified ✅
- [1.4.1] BatteryStatus model — Verified ✅
- [1.4.2] DeviceInfo model — Verified ✅
- [1.4.3] ErrorEntry model — Verified ✅
- [1.4.4] AppNotification model — Verified ✅
- [1.4.5] AppUser model — Verified ✅
- [1.4.6] WifiNetwork model — Verified ✅
- [1.5.1] Abstract BatteryDataSource interface — Verified ✅
- [1.5.2] MockBatteryDataSource — Auth methods — Verified ✅
- [1.5.3] MockBatteryDataSource — Device methods — Verified ✅
- [1.5.4] MockBatteryDataSource — Telemetry stream — Verified ✅
- [1.5.5] MockBatteryDataSource — Error and notification methods — Verified ✅
- [1.5.6] Data source provider — Verified ✅
- [1.6.1] Define all routes (placeholder screens) — Verified ✅
- [1.6.2] Wire router to app — Verified ✅
- [2.1.1] AppButton Widget — Verified ✅
- [2.2.1] AppTextField Widget — Verified ✅
- [2.3.1] AppBadge Widget — Verified ✅
- [2.4.1] SeverityChip Widget — Verified ✅
- [2.5.1] LoadingIndicator Widget — Verified ✅
- [2.6.1] EmptyStateWidget — Verified ✅
- [2.7.1] ConfirmationDialog Widget — Verified ✅
- [2.8.1] StaleDataBanner Widget — Verified ✅
- [2.9.1] AppErrorWidget — Verified ✅
- [2.10.1] NotificationItem Widget — Verified ✅
- [2.11.1] ProgressRing Widget — Verified ✅
- [2.12.1] StatCard Widget — Verified ✅
- [2.13.1] SettingsTile Widget — Verified ✅
- [2.14.1] InfoRow Widget — Verified ✅
- [2.15.1] ErrorListTile Widget — Verified ✅
- [3.10.1] Account Provider — Verified ✅
- [3.10.2] Account Screen — Profile & Security Sections — Verified ✅
- [3.10.3] Account Screen — Device & Account Sections — Verified ✅
- [3.11.1] Splash Screen — Verified ✅

## Current Step Detail
Rewrote `app_router.dart` with: (4.1.1) Three named transition helpers — `_slideRight` (300ms, standard push), `_slideUp` (350ms, detail screens), `_fade` (400ms, Dashboard entry + Splash exit) — applied correctly to every route. (4.2.1) Full redirect guard reading `authProvider`, `connectionTypeSeenProvider`: protected routes redirect to `/serial-entry` if not authenticated or no paired device; `/connection-type` redirects to `/dashboard` if already seen.

## Pending Steps
### Phase 3 — Frontend Screens (11 screens)
- [x] 3.1.1 — Dashboard Provider
- [x] 3.1.2 — Dashboard StatCard Sub-Widget (Built in Phase 2)
- [x] 3.1.3 — Dashboard App Bar
- [x] 3.1.4 — Dashboard Sidebar (Drawer)
- [x] 3.1.5 — Dashboard Body — Loading State
- [x] 3.1.6 — Dashboard Body — Battery Gauge and Stats Grid
- [x] 3.1.7 — Dashboard Body — Status Section
- [x] 3.1.8 — Dashboard Body — Error Summary Row and Stale Banner
- [x] 3.1.9 — Dashboard Share Functionality
- [x] 3.2.1 — Auth Provider
- [x] 3.2.2 — Login Tab
- [x] 3.2.3 — Sign Up Tab
- [x] 3.3.1 — Forgot Password Screen
- [x] 3.4.1 — Serial Entry Provider
- [x] 3.4.2 — Serial Entry Screen
- [x] 3.5.1 — Provisioning Screen
- [x] 3.6.1 — Connection Type Screen
- [x] 3.7.1 — Basic Information Screen
- [x] 3.8.1 — Error Report Screen
- [x] 3.9.1 — Notifications Screen
- [x] 3.10.1 — Account Provider
- [x] 3.10.2 — Account Screen — Profile and Security Sections
- [x] 3.10.3 — Account Screen — Device and Account Sections
- [x] 3.11.1 — Splash Screen
### Phase 4 — Navigation and Flow
### Phase 5 — Mock Layer and Testing
### Phase 6 — Backend
### Phase 7 — Integration
### Phase 8 — Real Device Testing and QA

## Decisions Made During Build
- [Step 1.1.1] Dart SDK version is 3.12.0 (bundled with Flutter 3.44.0), not 3.8.0 as listed in TRD. TRD was drafted before Flutter 3.44.0 shipped. This is the correct bundled SDK.
- [Step 1.1.1] Flutter generated Kotlin build scripts (build.gradle.kts) instead of Groovy (build.gradle). This is the default for Flutter 3.44.0.
- [Step 1.1.3] Removed riverpod_annotation, riverpod_generator, riverpod_lint, and custom_lint from pubspec due to version incompatibility. TRD specified forward-looking versions that don't exist on pub.dev. The project uses flutter_riverpod 3.3.1 directly with manual Notifier/AsyncNotifier patterns as all project docs describe. Code generation is not required.
- [Step 1.1.3] Placeholder SVG logos created in assets/images/ — will be replaced with final brand assets.
- [Step 3.5.1] Implemented real `permission_handler` logic mixed with mocked returns to gracefully handle Android permissions during the Wi-Fi provisioning BLE mock scan.
- [Step 3.6.1] Implemented `ConnectionTypeSeenNotifier` as an in-memory riverpod provider instead of `shared_preferences` since the `shared_preferences` package was not requested in TRD pubspec dependencies.

## Known Issues / Blockers
(none)

## Next Step
Phase 4, Step 4.3.1 — Complete New User Flow (Manual Verification)
