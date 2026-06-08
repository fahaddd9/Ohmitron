# Product Requirements Document (PRD)
## Ohmitron Battery App — Version 2.1 (MVP)

| Field | Detail |
|-------|--------|
| Document Version | 2.1 |
| Previous Version | 2.0 (2026-06-06) |
| Last Updated | 2026-06-08 |
| Product Owner | Ohmitron Team |
| Status | **Approved for Development** |
| Platform | Android 8.0 (API 26) and above. iOS is out of scope for V1. |

---

## Changelog: v2.0 → v2.1

| # | Change | Reason |
|---|--------|--------|
| 1 | Forgot Password changed from 4-digit code to Firebase link-based reset | Firebase handles natively — zero backend code, more secure |
| 2 | `passwordResetCodes` Firestore collection removed entirely | No longer needed with link-based reset |
| 3 | Cloud Functions reduced from 5 to 4 | Password reset functions removed |
| 4 | Serial number flow corrected — app creates `devices` document during provisioning | ESP32 carries its own metadata; no factory pre-registration needed |
| 5 | Unclaimed device (`ownerUid=null`, `provisioned=true`) forces re-provisioning | New owner needs their own Wi-Fi credentials |
| 6 | Device Name field merges "Bluetooth name" and "Friendly Name" into one field | BLE is off after provisioning; one field serves both purposes |
| 7 | Connection Type screen shown once only — immediately after provisioning | Returning users go straight to Dashboard |
| 8 | Telemetry changed to single overwritten document (`telemetry/latest`) | Eliminates collection growth; app only needs latest reading |
| 9 | `lastTelemetry` timestamp moved into `telemetry/latest` document | One Firestore read gets both data and timestamp |
| 10 | `alerts` collection scoped by both `targetUserUid` AND `deviceSerial` | Prevents old device alerts appearing after device change |
| 11 | Alerts deleted automatically on Remove Device AND Delete Account | No orphaned alerts in Firestore |
| 12 | Remove Device cascade moved to Cloud Function (4th function) | Batch delete of alerts requires server-side execution |
| 13 | All Firestore timestamps use `FieldValue.serverTimestamp()` | Prevents phone clock drift issues |
| 14 | Stale detection clarified — absolute 45-second check against server timestamp | Removes "1.5× interval" ambiguity |
| 15 | `devices` document preserved on Delete Account — only `ownerUid` nulled | Preserves device history for support and warranty |

---

## Table of Contents

1. Executive Summary
2. Goals and Success Metrics
3. User Personas
4. System Architecture Overview
5. User Flow
6. Detailed Functional Requirements (by Screen)
7. Non-Functional Requirements
8. Data Models (Firestore)
9. Push Notification Logic
10. Security Requirements
11. Out of Scope (V1)
12. Open Questions and Decisions Log
13. Glossary

---

## 1. Executive Summary

The **Ohmitron Battery App** is a Flutter-based mobile application that enables users to monitor the health, performance, and safety of their batteries in real time. The system consists of an ESP32-based hardware module connected to a Battery Management System (BMS). The ESP32 collects battery telemetry from the BMS and transmits it to Firebase Firestore over Wi-Fi every 30 seconds.

Users interact with the app to:
- Monitor live battery statistics (voltage, current, temperature, state of charge, protection and balance status).
- Receive push notifications for critical events (high temperature, protection faults, low charge, BMS errors).
- Manage their account and device pairing.
- View a history of device errors.

**Bluetooth Low Energy (BLE) is used only during the one-time initial Wi-Fi provisioning step.** After provisioning, all communication is exclusively over Wi-Fi via Firebase (cloud mode). This eliminates BLE-Wi-Fi hardware coexistence issues and allows the user to monitor their battery remotely from anywhere with an internet connection.

This document defines the complete scope for **Version 1 (MVP) targeting Android devices only**. iOS is planned for a future release.

---

## 2. Goals and Success Metrics

| Goal | Success Metric | Measurement Method |
|------|---------------|--------------------|
| Real-time battery monitoring | Dashboard load < 3 seconds on 4G | Manual and automated testing |
| Reliable telemetry delivery | > 95% of ESP32 updates reach Firestore | Firebase Analytics |
| Push notifications for critical events | Delivery rate > 99%, within 10 seconds of trigger | FCM delivery reports |
| Easy one-time device setup | Successful provisioning rate > 95% | Funnel tracking |
| Stable user sessions | Crash-free session rate > 99.5% | Firebase Crashlytics |
| User retention | > 40% of users return after 7 days | Firebase Analytics |
| Error visibility | All BMS errors visible within 60 seconds | QA testing |

---

## 3. User Personas

| Persona | Description | Primary Screens |
|---------|-------------|----------------|
| **Battery Owner** | Everyday user monitoring battery health and safety. Low to medium technical skill. Cares about at-a-glance status and notifications. | Dashboard, Notifications, Account |
| **Installer / Technician** | Sets up the device for the owner. Performs serial number pairing and Wi-Fi provisioning on first use. Medium technical skill. | Serial Entry, Provisioning, Basic Info |
| **Support Team** | Uses Firebase Console to assist with pairing issues, account deletion, and error analysis. Not a mobile app user. | Backend only |

---

## 4. System Architecture Overview

```
┌─────────────────────┐      Wi-Fi / HTTPS      ┌──────────────────────────┐
│   ESP32 Hardware    │ ──── Firebase REST ─────▶│   Firebase (Cloud)       │
│   + BMS Module      │                          │   - Firestore Database   │
│                     │◀─── FCM (indirect) ──────│   - Cloud Functions      │
└─────────────────────┘                          │   - Firebase Auth        │
         │                                       │   - FCM                  │
         │ BLE (one-time only,                   └──────────┬───────────────┘
         │ during provisioning)                             │
         ▼                                                  ▼
┌─────────────────────┐                          ┌──────────────────────────┐
│   Flutter App       │◀───── Firestore SDK ─────│   Firestore Polling      │
│   (Android)         │       30s polling         │   (Timer.periodic +      │
└─────────────────────┘                          │    .get() — no streams)  │
                                                 └──────────────────────────┘
```

**Key architectural decisions:**
- The app **polls** Firestore every 30 seconds using `Timer.periodic` + `.get()`. Real-time stream listeners (`.snapshots()`) are never used for telemetry — this keeps read costs predictable and stale detection reliable.
- The ESP32 writes telemetry to a **single fixed document** (`telemetry/latest`) which is always overwritten — never appended. This eliminates collection growth and minimises Firestore costs.
- Cloud Functions are the only component that sends FCM push notifications.
- BLE is used exclusively for the provisioning handshake. After provisioning, BLE is never activated again.
- The `devices` document is **created by the Flutter app** during provisioning using metadata pulled directly from the ESP32 over BLE. No factory pre-registration is needed.

---

## 5. User Flow

### 5.1 Onboarding Gate

```
App Launch
    │
    ▼
[Splash Screen] ──── 2 seconds ────▶ [Serial Number Entry]
                                              │
                              ┌───────────────┴────────────────┐
                              │                                │
                        Not logged in                   Already logged in
                              │                                │
                              ▼                                ▼
                      [Login / Sign Up]            [Firestore serial check]
                              │                                │
                   (After successful auth)        ┌────────────┴────────────┐
                              │                 Found                   Not found
                              │                   │                        │
                              │          ┌────────┴──────────┐         BLE scan
                              │      ownerUid=              ownerUid=      │
                              │      other user             null or    Device
                              │          │                  current    found?
                              │          ▼                  user          │
                              │       Show error               │      ┌───┴───┐
                              │       (owned by             Check   Yes     No
                              │        another)           provisioned  │       │
                              │                               │     Pull    Show
                              │                    ┌──────────┴──┐ metadata  error
                              │                false           true   │
                              │                    │              │  Create
                              │                    │          ownerUid  devices
                              │                    │           =null?   doc
                              │                    │           (unclaimed)
                              │                    │              │
                              │                    │         Call forceReprovision
                              │                    │         Cloud Function
                              │                    │         (sets provisioned=false)
                              └────────────────────┘──────────────┘
                                                   │
                                                   ▼
                                          [Wi-Fi Provisioning]
                                                   │
                                                   ▼
                                        [Connection Type Screen]
                                        (shown once only — first time)
                                                   │
                                                   ▼
                                             [Dashboard]
```

**Critical rule — Serial retention through login:**
When an unauthenticated user enters a serial number and is redirected to Login/Sign Up, the app retains the serial in memory (`pendingSerialProvider`). After successful authentication, the serial is automatically validated without asking the user to re-enter it.

### 5.2 In-App Navigation

```
                     ┌─────────────────────┐
                     │      Dashboard       │
                     │  (app bar + sidebar) │
                     └──────────┬──────────┘
          ┌──────────┬──────────┼──────────┬──────────┐
          ▼          ▼          ▼          ▼          ▼
    [Basic Info] [Error    [Notifs]   [Account]  [Share]
                  Report]                │
                                 ┌───────┼────────┐
                                 ▼       ▼        ▼
                           [Remove  [Logout] [Delete
                            Device]          Account]
                                 │       │        │
                                 └───────┴────────┘
                                         │
                                         ▼
                               [Serial Number Entry]
```

**Navigation structure:**
- Hamburger icon (☰) opens the sidebar drawer: Home, Basic Info, Error Report
- App bar right side: Share (camera), Notifications (bell), Account (person) — Dashboard only
- Secondary screens (Basic Info, Error Report, Notifications, Account) show back arrow only
- Sidebar screens (Basic Info, Error Report) slide up from bottom
- Logout, Remove Device, Delete Account all return to Serial Entry and clear all state

---

## 6. Detailed Functional Requirements (by Screen)

### 6.1 Splash Screen

**Purpose:** Brand introduction and silent auth state check.

**UI:**
- Ohmitron logo (SVG, centred, 120×120px)
- "OHMITRON" wordmark in headlineLarge Bold, 4px letter spacing
- "Battery Monitor" subtitle in bodyMedium, dark grey
- Fade-in entrance animation (600ms)

**Behaviour:**
- Auto-navigates to Serial Number Entry after exactly 2 seconds
- During the 2-second window, silently checks Firebase Auth state (result cached in memory)
- No network calls, no BLE activity, no user interaction
- Navigation replaces the splash route — no back stack entry

---

### 6.2 Serial Number Entry Screen

**Purpose:** Entry gate that associates a physical battery device with a user account.

**UI:**
- Logo (64×64px), heading "Enter Serial Number", helper text "Found on the label on your battery unit"
- Text input: alphanumeric only (enforced via input formatter), 8–12 characters, all-caps keyboard
- "Continue" button (disabled until format validation passes)
- Error message area (hidden by default)

**Input Validation (client-side):**
- Only A-Z and 0-9 characters. No spaces, hyphens, or special characters.
- Minimum 8 characters, maximum 12 characters.
- Error: "Serial number must be 8–12 letters and numbers only."

**On "Continue" tapped:**

*User NOT logged in:*
1. Store serial in `pendingSerialProvider` (memory only — never persisted to disk)
2. Navigate to Login / Sign Up
3. After successful auth, automatically resume serial validation

*User IS logged in:*
1. Query Firestore `devices` collection for this serial number
2. **Document does not exist:**
   - BLE scan for an ESP32 advertising this serial number
   - If ESP32 found: connect via BLE, pull all metadata (model, firmware, BMS details), create `devices` document in Firestore, proceed to provisioning
   - If ESP32 not found after 30 seconds: show error "Device not found. Make sure your battery is powered on and within 1 metre of your phone."
3. **Document exists, `ownerUid` = another user:** Show error "This device is registered to another account. Contact support to transfer ownership."
4. **Document exists, `ownerUid` = null, `provisioned` = true (unclaimed device):** Call `removeDevice` Cloud Function with `forceReprovision: true` → proceed to provisioning
5. **Document exists, `ownerUid` = current user, `provisioned` = false:** Navigate to provisioning
6. **Document exists, `ownerUid` = current user, `provisioned` = true, Connection Type never seen:** Navigate to Connection Type screen
7. **Document exists, `ownerUid` = current user, `provisioned` = true, Connection Type already seen:** Navigate to Dashboard directly

**Important constraint:** One device per user account. `users.deviceSerial` is a single string — never an array. Multi-device support is out of scope for V1.

---

### 6.3 Login / Sign Up Screen

**Purpose:** Firebase Email/Password authentication.

**UI Pattern:** Two tabs — "Log In" and "Sign Up" — on the same screen. Default tab: Log In.

#### 6.3.1 Log In Tab
- Email field, Password field (with show/hide toggle)
- "Forgot Password?" text link (right-aligned)
- "Log In" primary button
- On success: proceed to serial validation with retained serial
- On failure: SnackBar with user-friendly message (never raw Firebase error codes)

#### 6.3.2 Sign Up Tab
- Full Name (max 60 chars), Email, Password (min 8 chars), Confirm Password
- Date of Birth (date picker — user must be ≥ 13 years old)
- Terms checkbox: "I agree to the Privacy Policy and Terms of Service" (links open in-app browser)
- "Create Account" button (disabled until all fields valid and checkbox checked)
- On success: create Firebase Auth user + write `users` document to Firestore, proceed to serial validation
- On email already exists: "An account with this email already exists. Try logging in instead."

#### 6.3.3 Forgot Password (2-state animated stepper)
This is a single screen with two animated states. Transitions between states use a horizontal slide animation.

**State 1 — Enter Email:**
- Email input field
- "Send Reset Link" button
- On tap: call `FirebaseAuth.sendPasswordResetEmail(email)`
- **Always transitions to State 2** regardless of whether the email exists in Firebase. Firebase intentionally does not reveal whether an email account exists (prevents email enumeration attacks).

**State 2 — Confirmation:**
- Success icon
- Message: "A password reset link has been sent to [email]. Follow the link to set a new password. Check your spam folder if you don't see it."
- "Back to Login" button → returns to Log In tab

**No 4-digit code. No custom backend. No expiry management. Firebase handles everything.**

---

### 6.4 Wi-Fi Provisioning Screen

**Purpose:** One-time setup to deliver Wi-Fi credentials to the ESP32 via BLE.

**Trigger:** `devices.provisioned = false` (either new device or forced reprovision for unclaimed device).
**Shown:** Once per device. After `provisioned = true` is set, this screen is never shown again for this device.

#### 6.4.1 BLE Permission Handling (runs before provisioning UI)

**Android 12+ (API 31+):** Requires `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT`
**Android 6–11 (API 23–30):** Requires `ACCESS_FINE_LOCATION`

**Flow:**
1. Show explanatory dialog before system permission prompt:
   - "We need Bluetooth access to connect to your battery device for this one-time setup. Bluetooth is not used after setup is complete."
   - Buttons: "Allow" / "Not Now" (Not Now → returns to Serial Entry)
2. Trigger system permission request
3. If denied: Show "Open Settings" button (deep-links to app permissions) + "Cancel Setup" button
4. If permanently denied: Same UI — only path is "Open Settings"
5. Only proceed to BLE scan after all permissions granted

#### 6.4.2 Provisioning States (7 states, cross-fade transitions)

**State 1 — Permission Check:** Brief loading while checking permission status. Auto-transitions.

**State 2 — Permission Denied:** Error UI with "Open Settings" and "Cancel Setup" buttons.

**State 3 — BLE Scanning:**
- Animated pulsing scan rings (brand green, 3 concentric circles pulsing outward)
- "Searching for your device..."
- "Cancel" button
- Timeout: 30 seconds → transitions to State 4

**State 4 — BLE Scan Failed:**
- Error icon, "Device Not Found" message
- "Try Again" button (restarts scan) and "Cancel" button

**State 5 — Wi-Fi Network Selection:**
- List of nearby Wi-Fi networks from Android Wi-Fi manager
- 4 mock networks during frontend development
- User selects SSID → password field expands below list
- "Connect Device" button

**State 6 — Sending Credentials:**
- Loading indicator, "Connecting your device..."
- On wrong password or unreachable network: SnackBar error, return to State 5

**State 7 — Provisioning Complete:**
- Green check icon with scale entrance animation
- "Device Connected!" message
- Auto-navigates to Connection Type screen after 2 seconds

**Security constraints:**
- Serial number in BLE advertisement verified against entered serial (Proof of Possession) before any credentials sent
- Wi-Fi password held in a local variable only — never stored in any provider, file, or log
- Variable cleared immediately after transmission completes
- BLE GATT communication uses encrypted transport (bonding required on ESP32)

**Firestore write on completion:**
- Set `devices/{serial}.provisioned = true`
- Set `devices/{serial}.ownerUid = currentUser.uid`
- Retry up to 3 times on failure. If all retries fail: show warning that setup is nearly complete, attempt write on next launch.

---

### 6.5 Connection Type Screen

**Purpose:** Informs the user of the active connection method. Shown exactly once.

**Trigger:** Immediately after successful provisioning. After seen, `connectionTypeSeenProvider = true` is set and this screen is never shown again.

**UI:**
- Active card: Wi-Fi (Cloud Mode) — green border, "Active" badge
- Disabled card: Bluetooth (Direct Mode) — grey, 50% opacity, "Coming Soon" badge
- Cards animate in with stagger (100ms delay between cards)
- "Continue" button → navigates to Dashboard (fade transition — not a slide)

---

### 6.6 Dashboard Screen

**Purpose:** The primary screen. Displays live battery telemetry. Refreshes every 30 seconds.

#### 6.6.1 App Bar
- Left: Hamburger icon (☰) → opens sidebar
- Centre: Device friendly name (`DeviceNameHeader`)
- Right: Share (camera icon), Notifications (bell icon with unread badge), Account (person icon)
- App bar icons are on **Dashboard only**. All other screens show a simple back arrow.

#### 6.6.2 Sidebar (Drawer)
- Green header: Ohmitron logo (white tint, 48px), "Ohmitron" text, device name below
- Navigation items: Home (Dashboard), Basic Information, Error Report
- Active item highlighted in brand green

#### 6.6.3 Dashboard Layout (Hybrid — Option C)
The Dashboard uses a three-section hybrid layout:

**Section 1 — Animated Battery Gauge (top, full width)**
- Rectangular battery shape (16px corner radius) with terminal on right
- Fill animates left to right based on SOC percentage
- Fill colour: green (> 40%), amber (20–40%), red (< 20%) — animated colour transition
- SOC percentage displayed in large bold text centred inside gauge
- Charging state: repeating pulse animation + lightning bolt icon on fill
- Entrance animation: fill from 0% to actual SOC over 1200ms on first load
- Update animation: fill to new value over 800ms on each refresh

**Section 2 — 2-Column Key Stats Grid**
- Left card: Remaining Time (`Xh Ym` format, `< 1h` if under 1 hour, `--` if null)
- Right card: Discharging Watts (`XX.X W`, `--` when charging)

**Section 3 — Flat Status Section**
Grouped in a bordered card:
- Charging status: Active/Inactive badge
- Discharging status: Active/Inactive badge
- Balance state: Inactive (blue), Active (green), Balancing (amber)
- Protection state: Protected (green) when `none`, red badge with state name when active
- Temperature: colour shifts amber above 50°C, red above 60°C

**Section 4 — Error Summary Row (bottom)**
- Tappable row showing latest error message or "No errors recorded"
- Chevron icon → navigates to Error Report screen

#### 6.6.4 Data Refresh Behaviour
- **First load:** Full-screen loading spinner while first Firestore read completes
- **Subsequent returns to Dashboard:** Show last cached values instantly, silent background refresh
- **Polling:** Every 30 seconds via `Timer.periodic` + Firestore `.get(GetOptions(source: Source.server))`
- **Pull-to-refresh:** Forces immediate re-query of `telemetry/latest`
- **Stale detection:** `DateTime.now().difference(telemetry.timestamp).inSeconds > 45` → show `StaleDataBanner`

#### 6.6.5 Stale Data Banner
- Appears when ESP32 has not written telemetry for > 45 seconds
- Amber banner with left accent border
- Text: "⚠ Data Stale — Device may be offline" + "Last updated: [timestamp]"
- All telemetry values remain visible but dimmed (50% opacity)
- Slides down when shown (300ms), slides up when fresh data arrives (250ms)
- Not manually dismissible
- **The 45-second threshold is absolute** — it compares `DateTime.now()` against the server timestamp in `telemetry/latest`. It is not relative to the 30-second polling interval.

#### 6.6.6 Share Functionality
- Capture screenshot of Dashboard body (excluding app bar) via `screenshot` package
- Open Android system share sheet via `share_plus`

---

### 6.7 Basic Information Screen

**Purpose:** Displays device metadata. Allows editing of the device name.

**Access:** Sidebar → "Basic Information" (slides up from bottom)

**Sections:**

**Device Name (editable):**
- Single text field with "SET" button
- Max 30 characters
- On SET: validate → save to Firestore `devices.friendlyName` → attempt HTTP sync to ESP32 (silently skip if unreachable) → show success toast
- This single field replaces both "Friendly Name" and "Bluetooth name" — they are the same thing. BLE is not active after provisioning; the name is managed via Firestore and optional HTTP sync.

**Device Details (read-only):**
- Serial Number, Device Model, Firmware Version, BMS Model, BMS ID

**Barcode:**
- Code 128 barcode generated client-side from the serial number
- Generated using `barcode_widget` Flutter package

**Connection:**
- Connection Type: "Wi-Fi (Cloud Mode)" (hardcoded)
- Connected Network: `devices.connectedSsid` (updated by ESP32, shown as "Unknown" if null)

---

### 6.8 Error Report Screen

**Purpose:** Displays the 20 most recent BMS errors, most recent first.

**Access:** Sidebar → "Error Report" or Dashboard error summary row tap (slides up from bottom)

**Query:** `devices/{serial}/errors` ordered by `timestamp` descending, limit 20

**Each error item shows:**
- Severity badge: Info (blue), Warning (amber), Critical (red)
- Error code (bold), timestamp (local format: `DD MMM YYYY HH:mm`)
- Human-readable error message

**Empty state:** "No Errors Recorded. Your battery is running normally."
**Pull-to-refresh:** Re-queries latest 20 errors.
**Note:** Errors are read-only in V1. Users cannot delete or acknowledge errors.

**V1 limit:** Display maximum 20 errors. No pagination. Oldest dropped from display (not from Firestore).

---

### 6.9 Notifications Screen

**Purpose:** In-app history of all push notifications sent for this device.

**Access:** Bell icon in Dashboard app bar

**Data source:** `alerts` collection filtered by `targetUserUid == currentUser.uid` AND `deviceSerial == pairedSerial`, ordered by `timestamp` descending.

**Each notification item shows:**
- Unread indicator (green dot, fades out on tap)
- Title (bold), message body, relative timestamp (e.g., "2h ago")
- Swipe left to delete individual notification
- Tapping marks as read (`read = true` in Firestore)

**"Clear All" button:**
- Confirmation dialog: "Delete all notifications? This cannot be undone."
- On confirm: deletes all `alerts` documents for this user + device

**Empty state:** "No Notifications Yet. You'll see alerts here when your battery needs attention."

**Unread badge:** Bell icon in Dashboard app bar shows red badge with unread count when count > 0.

---

### 6.10 Account Screen

**Purpose:** User profile management, security, device management, and account lifecycle.

**Access:** Person icon in Dashboard app bar

#### 6.10.1 Profile Section
- Editable: Full Name (max 60 chars), Date of Birth (date picker, age ≥ 13)
- Read-only: Email address ("Email cannot be changed in this version")
- "Save Changes" button → updates `users/{uid}` in Firestore

#### 6.10.2 Change Password
- Opens bottom sheet: Current Password, New Password (min 8 chars), Confirm New Password
- Re-authenticates with Firebase before updating
- On wrong current password: field error "Your current password is incorrect"
- On success: success toast, dismiss sheet

#### 6.10.3 Remove Device (Unpair)
- Confirmation dialog: "Remove this device from your account? You can pair a new device afterwards. This will delete all notifications for this device."
- On confirm: calls `removeDevice` Cloud Function
  1. Sets `users/{uid}.deviceSerial = null`
  2. Sets `devices/{serial}.ownerUid = null`
  3. Does NOT reset `provisioned` flag (unless new user claims the device and triggers `forceReprovision`)
  4. Deletes all `alerts` where `targetUserUid == uid AND deviceSerial == serial`
  5. Clears `connectionTypeSeenProvider` (reset to false for next pairing)
- Navigates to Serial Number Entry (full stack replacement)

#### 6.10.4 Logout
- Confirmation dialog: "Are you sure you want to log out?"
- On confirm: Firebase sign out, clear all local state, navigate to Serial Number Entry

#### 6.10.5 Delete Account
- Two-step confirmation: dialog ("This action cannot be undone") → password confirmation bottom sheet
- On confirm: calls `deleteAccount` Cloud Function
  1. Sets `devices/{serial}.ownerUid = null` (preserves device document and all history)
  2. Deletes `users/{uid}` Firestore document
  3. Deletes all `alerts` where `targetUserUid == uid`
  4. Deletes Firebase Auth user account
- Navigates to Serial Number Entry (full stack replacement)
- **Why the `devices` document is preserved:** Contains firmware version, BMS model, error history needed for support and warranty. Ownership severed by nulling `ownerUid`, not by deleting the document.

---

## 7. Non-Functional Requirements

| Category | Requirement | Detail |
|----------|-------------|--------|
| Performance | Dashboard refresh < 2 seconds | Under normal 4G/Wi-Fi conditions |
| Performance | App cold start < 3 seconds | On mid-range Android device |
| Reliability | Crash-free rate > 99.5% | Firebase Crashlytics |
| Reliability | Graceful network disconnection | Stale banner, never crash on network loss |
| Usability | User-friendly error messages | Zero raw Firebase codes or stack traces shown |
| Usability | All async operations show loading state | No exception |
| Compatibility | Android 8.0 (API 26) and above | Test on API 26, 29, 31, 33, 34 |
| Power efficiency | No background BLE after provisioning | BLE only active during provisioning screen |
| Offline behaviour | No offline sync | Show last known data with stale banner |
| Push notifications | FCM delivery within 10 seconds | From Cloud Function trigger to device |
| Security | No plaintext password storage | Wi-Fi password cleared immediately after BLE transmission |
| Accessibility | WCAG 2.1 AA contrast ratio 4.5:1 minimum | All text elements |

---

## 8. Data Models (Firestore)

### Design Principles
- All timestamps: Firestore `Timestamp` type using `FieldValue.serverTimestamp()` — never device local time
- All string enums: lowercase with underscores (e.g., `over_current`, not `Overcurrent`)
- Absent/unknown values: `null` — never empty strings
- `devices` document: created by Flutter app during provisioning using metadata from ESP32. Never pre-created at factory. Never deleted.

---

### 8.1 `users` Collection
**Document ID:** Firebase Auth UID

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `name` | string | No | Full name. Max 60 characters. |
| `email` | string | No | Email address. Matches Firebase Auth. |
| `dob` | Timestamp | No | Date of birth. Age ≥ 13 required. |
| `deviceSerial` | string | **Yes** | Currently paired device serial. `null` if none paired. **Single string — one device per user.** |
| `fcmToken` | string | **Yes** | Current FCM registration token. `null` if permission denied or token invalid. Updated on every app launch. |
| `createdAt` | Timestamp | No | Account creation time. Set once, never updated. |

---

### 8.2 `devices` Collection
**Document ID:** Serial number (e.g., `OHM00123456`)

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `ownerUid` | string | **Yes** | Firebase Auth UID of paired user. `null` when unowned. Set to `null` (never deleted) on Remove Device or Delete Account. |
| `provisioned` | boolean | No | `true` after ESP32 receives Wi-Fi credentials. `false` at creation. Set to `false` only by `removeDevice` Cloud Function with `forceReprovision: true`. |
| `friendlyName` | string | No | User-editable device name. Default: `"Ohmitron Battery"`. Max 30 characters. Shown in Dashboard app bar and Basic Info screen. |
| `deviceModel` | string | No | Hardware model. Set during provisioning from ESP32 metadata. |
| `firmwareVersion` | string | No | ESP32 firmware version. Set during provisioning, updated by ESP32 on boot. |
| `bmsModel` | string | No | BMS model identifier. Set during provisioning from ESP32 metadata. |
| `bmsId` | string | No | BMS unique identifier. Set during provisioning from ESP32 metadata. |
| `connectedSsid` | string | **Yes** | Wi-Fi SSID the ESP32 is connected to. Updated by ESP32 on each connection. `null` if not connected. |
| `createdAt` | Timestamp | No | When the document was created (during provisioning). |
| `lastHighTempAlert` | Timestamp | **Yes** | Last time a high-temperature notification was sent (deduplication). Managed by Cloud Function. |
| `lastProtectionAlert` | Timestamp | **Yes** | Last time a protection state notification was sent (deduplication). |
| `lastLowSocAlert` | Timestamp | **Yes** | Last time a low-SOC notification was sent (deduplication). |

---

### 8.3 `devices/{serial}/telemetry/latest`
**Document ID:** Fixed string `"latest"` — always overwritten, never appended.
**Written by:** ESP32 firmware every 30 seconds via Firebase REST API.
**Read by:** Flutter app every 30 seconds via `.get()`.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `timestamp` | Timestamp | No | When measurement was taken. **Must use `FieldValue.serverTimestamp()`**. Used for stale detection: if `DateTime.now() - timestamp > 45 seconds` → device is offline. |
| `stateOfCharge` | number | **Yes** | Battery charge percentage (0.0–100.0). `null` if BMS does not expose SOC. Required for low-battery notification trigger. |
| `remainingTimeHours` | number | **Yes** | Estimated runtime in fractional hours (e.g., `3.7` = 3h 42m). `null` if not calculable. |
| `voltage` | number | No | Pack voltage in Volts. Raw BMS value. |
| `current` | number | No | Pack current in Amps. Positive = discharging, negative = charging. |
| `dischargingWatts` | number | **Yes** | Instantaneous power draw (`voltage × current`). `null` or 0 when charging. |
| `isCharging` | boolean | No | `true` if BMS indicates charging. |
| `isDischarging` | boolean | No | `true` if BMS indicates discharging. Mutually exclusive with `isCharging`. |
| `balanceState` | string | No | One of: `"inactive"`, `"active"`, `"balancing"`. |
| `protectionState` | string | No | One of: `"none"`, `"over_current"`, `"over_voltage"`, `"under_voltage"`, `"over_temperature"`, `"short_circuit"`. |
| `temperatureCelsius` | number | No | Battery temperature in °C. |

**Why a single document:** The Dashboard only ever needs the latest reading. Storing one document that is always overwritten eliminates collection growth, cuts Firestore costs by ~99% compared to appending, and removes the need for a retention policy.

---

### 8.4 `devices/{serial}/errors/{auto-id}`
**Written by:** ESP32 firmware when a BMS error occurs.
**Read by:** Flutter app — latest 20 only. Never deleted.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `timestamp` | Timestamp | No | When error occurred. `FieldValue.serverTimestamp()`. |
| `errorCode` | string | No | Short code (e.g., `"E001"`). See error registry below. |
| `message` | string | No | Human-readable description. |
| `severity` | string | No | One of: `"info"`, `"warning"`, `"critical"`. |

**Error Code Registry (V1):**

| Code | Message | Severity |
|------|---------|----------|
| E001 | Cell overvoltage detected | critical |
| E002 | Cell undervoltage detected | critical |
| E003 | Pack overtemperature | critical |
| E004 | Overcurrent on discharge | warning |
| E005 | Cell imbalance detected | warning |
| E006 | Short circuit protection triggered | critical |
| E007 | BMS communication timeout | info |

---

### 8.5 `alerts/{auto-id}`
**Created by:** Cloud Functions only.
**Read/updated/deleted by:** Flutter app.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `targetUserUid` | string | No | Firebase Auth UID of user to notify. |
| `deviceSerial` | string | No | Serial of the device that triggered this alert. Used to scope notifications to current device only. |
| `title` | string | No | Short notification title. |
| `body` | string | No | Notification body text. |
| `timestamp` | Timestamp | No | When created. `FieldValue.serverTimestamp()`. |
| `read` | boolean | No | `false` on creation. Set to `true` by Flutter app when user views notification. |

**Cleanup:** All alerts for a user+device pair are deleted when Remove Device or Delete Account is executed (via Cloud Function).

---

## 9. Push Notification Logic

All push notification logic runs exclusively in Firebase Cloud Functions. The app never sends notifications directly.

### 9.1 Triggers

| Trigger | Condition | Title | Body |
|---------|-----------|-------|------|
| High temperature | `temperatureCelsius > 60` | "High Temperature Alert" | "Your battery temperature has reached [X]°C. Check your device." |
| Protection active | `protectionState != "none"` | "Battery Protection Activated" | "Protection triggered: [state]. Check your battery immediately." |
| Low charge | `stateOfCharge < 20` (if not null) | "Low Battery" | "Your battery is at [X]%. Connect a charger soon." |
| New error | New document in `errors` subcollection | "Battery Error Detected" | "[errorCode]: [message]" |

### 9.2 Deduplication
The same notification type is not sent more than once every 10 minutes per device. Enforced via `lastHighTempAlert`, `lastProtectionAlert`, `lastLowSocAlert` timestamp fields on the `devices` document.

### 9.3 Cloud Functions (4 Total)

| Function | Trigger | Purpose |
|----------|---------|---------|
| `onTelemetryWrite` | `onDocumentWritten` on `telemetry/latest` | Evaluate temperature, protection, and SOC notification triggers |
| `onErrorCreated` | `onDocumentCreated` on `errors/{id}` | Send push notification for new BMS error |
| `removeDevice` | HTTPS Callable | Unlink device from user, delete alerts, optionally reset provisioned flag |
| `deleteAccount` | HTTPS Callable | Full account deletion cascade |

### 9.4 FCM Token Lifecycle
- On every app launch: call `FirebaseMessaging.instance.getToken()` and write to `users/{uid}.fcmToken`
- Register `onTokenRefresh` listener to update Firestore when FCM rotates the token
- If FCM returns `messaging/registration-token-not-registered`: Cloud Function deletes stale token from Firestore

---

## 10. Security Requirements

### 10.1 Authentication
- Firebase Email/Password only. No anonymous access. No social login in V1.
- All Firestore reads and writes require an authenticated Firebase Auth session.

### 10.2 Firestore Security Rules Summary
- Users read/write only their own `users/{uid}` document
- Device owners read their `devices/{serial}` document; can update `friendlyName`, `provisioned`, `ownerUid` only
- Telemetry and errors subcollections: read-only for device owner; write forbidden from client (ESP32 service account only)
- Alerts: owner can read, update `read` field only, and delete their own alerts; create forbidden from client (Cloud Functions only)
- Full rules: DB_SCHEMA.md Section 7

### 10.3 BLE Security
- Serial number Proof of Possession: BLE advertisement serial verified against user-entered serial before any credentials sent
- Wi-Fi password transmitted over encrypted BLE GATT channel (bonding required)
- Wi-Fi password held in local variable only — never stored in any provider, file, SharedPreferences, or log
- Variable cleared immediately after `provisionWiFi()` completes

### 10.4 ESP32 Security
- Wi-Fi credentials stored in encrypted NVS partition on ESP32
- Firebase REST API calls use service account JWT — not user's Firebase Auth token
- Service account has write-only access scoped to its own device serial

### 10.5 Data Privacy
- Date of birth stored for age verification only — not shared with third parties
- On Delete Account: all user-identifiable data deleted (`users/{uid}`, user's `alerts`, Firebase Auth record). `devices` document preserved but `ownerUid` nulled.

---

## 11. Out of Scope (V1)

| Feature | Reason Deferred |
|---------|----------------|
| iOS support | Separate BLE permission model, APNs setup, different build pipeline |
| Bluetooth direct mode | Complex ESP32 state machine, BLE-Wi-Fi coexistence risk |
| Multi-device support per user | `users.deviceSerial` is a single string in V1 |
| Telemetry history / graphs | Significant UI complexity and Firestore read cost |
| Error list pagination beyond 20 | V1.1 enhancement |
| Device firmware OTA updates | Security and UX complexity |
| Social login (Google, Apple) | Out of scope for MVP |
| Email address change | Requires Firebase re-authentication flow |
| Enterprise Wi-Fi (802.1X) provisioning | ESP32 does not support it in V1 firmware |
| Offline write queue | Cloud-first architecture; monitoring does not require offline writes |
| Telemetry data export | Post-MVP |
| Web dashboard | Mobile-first for V1 |
| Barcode scanner on Serial Entry | Manual entry only for V1; scanner is V1.1 |
| Telemetry auto-deletion (retention policy) | Review after 30 days of production data; Cloud Function scheduled for V1.1 |

---

## 12. Open Questions and Decisions Log

| # | Question | Status | Resolution |
|---|----------|--------|-----------|
| 1 | Does BMS expose native SOC, or must firmware calculate it? | **Open — firmware team** | If not native, firmware must calculate and provide `stateOfCharge` field |
| 2 | BLE pairing method — Passkey Entry or Numeric Comparison? | **Open — firmware team** | Flutter app must support whichever is chosen |
| 3 | BLE service UUID for provisioning? | **Open — firmware team** | Required before provisioning screen can be built |
| 4 | GATT characteristic UUID for Wi-Fi credential transfer? | **Open — firmware team** | Required before provisioning screen can be built |
| 5 | HTTP endpoint for device name sync to ESP32? | **Open — nice to have** | If unavailable at launch, Firestore-only update is acceptable |
| 6 | Complete BMS error code registry (E001–E00X)? | **Open — firmware team** | V1 mock uses E001–E007; production list needed before backend launch |
| 7 | Firebase project region preference? | **Open — supervisor** | Default: `us-central1`. Confirm if different region needed. |
| 8 | Telemetry retention policy timeline? | **Decision: No auto-deletion in V1.** Review after 30 days of data. Cloud Function scheduled for V1.1. | |
| 9 | Supervisor sign-off criteria for Phase 8? | **Decision: Phase 8 checklist in IMPLEMENTATION_PLAN.md Section 8.2** | |

---

## 13. Glossary

| Term | Definition |
|------|-----------|
| **BLE** | Bluetooth Low Energy. Short-range wireless protocol. Used only during one-time Wi-Fi provisioning. |
| **BMS** | Battery Management System. Hardware that measures and manages cell voltages, temperature, and protection states. |
| **Connection Type screen** | Informational screen shown once after provisioning to confirm Wi-Fi cloud mode is active. |
| **ESP32** | The microcontroller unit connected to the BMS. Reads BMS data and writes to Firebase over Wi-Fi every 30 seconds. |
| **FCM** | Firebase Cloud Messaging. Google's push notification service for Android. |
| **Firestore** | Google Firebase's NoSQL cloud database. Single source of truth for all app data. |
| **Friendly Name / Device Name** | User-editable label for their battery (e.g., "Workshop Battery"). Default: "Ohmitron Battery". Managed via a single field — `devices.friendlyName`. |
| **forceReprovision** | Flag passed to `removeDevice` Cloud Function when an unclaimed device needs its `provisioned` flag reset to `false`, requiring new Wi-Fi setup from the new owner. |
| **NVS** | Non-Volatile Storage. Encrypted storage on ESP32 where Wi-Fi credentials persist across reboots. |
| **pendingSerialProvider** | In-memory Riverpod provider that holds the serial number entered before login, so it is not lost during the auth redirect. |
| **Proof of Possession** | Security mechanism that verifies the user is pairing with their own device. Implemented by matching the serial number in the BLE advertisement against the serial number the user typed. |
| **Provisioning** | One-time process of sending Wi-Fi credentials to the ESP32 via BLE. Sets `provisioned = true` in Firestore on completion. |
| **Serial Number** | Unique 8–12 character alphanumeric identifier on the physical battery unit. Used as the Firestore `devices` document ID. |
| **SOC** | State of Charge. Remaining battery capacity as a percentage (0–100%). |
| **Stale Data** | Telemetry not updated for > 45 seconds, indicating the ESP32 may be offline. Triggers the StaleDataBanner on Dashboard. |
| **telemetry/latest** | Single Firestore document (`devices/{serial}/telemetry/latest`) always overwritten by the ESP32. Contains the most recent battery reading. |
| **useMockData** | Feature flag in `AppConfig`. `true` during all development and testing phases. Set to `false` only after Phase 8 explicit approval. |

---

*Ohmitron Battery App — PRD v2.1*
*This is the definitive product requirements document.*
*All decisions from PRD v2.0 and subsequent discussions are incorporated here.*
*Read this document alongside UI_UX_BLUEPRINT.md, TRD.md, FRONTEND_SKILL.md,*
*DB_SCHEMA.md, AGENT.md, IMPLEMENTATION_PLAN.md, and MASTER_PROMPT.md.*
*Approved for development — 2026-06-08*
