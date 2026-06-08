# UI_UX_BLUEPRINT.md
## Ohmitron Battery App — Screen-by-Screen Construction Manual
### Version 1.0 | Approved for Production

---

> This document is the construction manual for every screen in the Ohmitron app.
> It is read alongside FRONTEND_SKILL.md — never in isolation.
> Every colour, spacing, animation, and component referenced here is defined in FRONTEND_SKILL.md.
> The agent reads both documents before writing a single line of code for any screen.

---

## How to Use This Document

Each screen section contains:
- **Purpose** — why this screen exists
- **Route** — GoRouter path
- **Entry conditions** — what triggers navigation to this screen
- **Exit conditions** — where this screen navigates to and when
- **Scaffold structure** — exact Flutter scaffold configuration
- **Widget tree** — every widget, every property, every state
- **All screen states** — loading, empty, error, success, stale
- **All interactions** — every tap, swipe, gesture and its result
- **Animations** — exact transitions in and out, and all internal animations
- **Mock data bindings** — which mock field maps to which widget
- **Edge cases** — every error scenario with exact UI response

---

## Screen Index

| # | Screen | Route | File Path |
|---|--------|-------|-----------|
| 1 | Splash | `/splash` | `features/splash/presentation/splash_screen.dart` |
| 2 | Serial Number Entry | `/serial-entry` | `features/device_setup/presentation/serial_entry_screen.dart` |
| 3 | Login / Sign Up | `/auth` | `features/auth/presentation/auth_screen.dart` |
| 4 | Forgot Password | `/forgot-password` | `features/auth/presentation/forgot_password_screen.dart` |
| 5 | Wi-Fi Provisioning | `/provisioning` | `features/device_setup/presentation/provisioning_screen.dart` |
| 6 | Connection Type | `/connection-type` | `features/device_setup/presentation/connection_type_screen.dart` |
| 7 | Dashboard | `/dashboard` | `features/dashboard/presentation/dashboard_screen.dart` |
| 8 | Basic Information | `/basic-info` | `features/basic_info/presentation/basic_info_screen.dart` |
| 9 | Error Report | `/error-report` | `features/error_report/presentation/error_report_screen.dart` |
| 10 | Notifications | `/notifications` | `features/notifications/presentation/notifications_screen.dart` |
| 11 | Account | `/account` | `features/account/presentation/account_screen.dart` |

---

## Global Rules (Apply to Every Screen)

Before reading any individual screen spec, internalise these rules. They apply everywhere without exception.

1. **Every screen is a `ConsumerWidget`.** No `StatefulWidget` anywhere.
2. **Every screen background is `colorBackground` (`#F7F8FA`).** Never white, never any other colour.
3. **Every screen has 16px horizontal padding** on its content. Applied via `Padding` or `EdgeInsets.symmetric(horizontal: 16)`.
4. **Every async operation shows a loading state.** No exceptions.
5. **Every async operation handles its error state.** No exceptions.
6. **Every list handles its empty state** using `EmptyStateWidget`. No exceptions.
7. **No hardcoded strings in widget files.** All user-facing strings live in `core/constants/app_strings.dart`.
8. **No hardcoded colours in widget files.** Always reference `Theme.of(context).colorScheme` or the colour token constants.
9. **No hardcoded spacing values.** Always reference spacing tokens from `core/constants/app_spacing.dart`.
10. **All screens are scrollable** unless explicitly marked as fixed layout. Use `SingleChildScrollView` wrapping the body content to prevent overflow on small screens.

---

## Screen 1 — Splash Screen

### Purpose
Brand introduction. Silent auth state check. Auto-navigation entry point.

### Route
`/splash` — This is the initial route. GoRouter redirects from here immediately.

### Entry Conditions
- App cold start only. Never navigated to manually.

### Exit Conditions
- After exactly 2 seconds → navigate to `/serial-entry`
- The navigation replaces the splash route (no back stack entry created)

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  body: SafeArea(
    child: SplashBody()
  )
)
```
No app bar. No floating action button. No bottom navigation.

### Widget Tree

```
Column (mainAxisAlignment: center, crossAxisAlignment: center)
  │
  ├── Spacer (flex: 2)
  │
  ├── SvgPicture.asset('assets/images/ohmitron_logo.svg')
  │     width: 120px, height: 120px
  │
  ├── SizedBox (height: space16 = 16px)
  │
  ├── Text('OHMITRON')
  │     style: headlineLarge (24sp Bold)
  │     color: colorBlack
  │     letterSpacing: 4px (brand wordmark spacing)
  │
  ├── SizedBox (height: space8 = 8px)
  │
  ├── Text('Battery Monitor')
  │     style: bodyMedium (14sp Regular)
  │     color: colorDarkGrey
  │
  └── Spacer (flex: 3)
```

### Animation — Entrance
- The logo and text do not appear instantly. They fade in together.
- `FadeTransition` wrapping the Column content
- Duration: 600ms, curve: `easeOutCubic`
- Starts immediately when screen mounts
- No delay before fade-in begins

### Animation — Exit
- Screen fades out as it transitions to Serial Entry
- GoRouter page transition: fade only, duration 400ms

### Mock Data Bindings
- None. This screen has no data dependencies.

### Silent Auth Check
- During the 2-second window, the app calls `mockAuthService.isLoggedIn` (controlled by `mockIsLoggedIn` debug flag)
- Result is stored in the `authStateProvider`
- This does NOT delay navigation — the check runs in parallel with the 2-second timer
- If the check completes before 2 seconds, the result is cached and used when Serial Entry loads
- If the check has not completed by 2 seconds, Serial Entry shows its own loading state briefly

### Edge Cases
- If the app is launched while the phone has no internet: proceed normally. Serial Entry will handle network errors.
- No error state on this screen. It never fails.

---

## Screen 2 — Serial Number Entry Screen

### Purpose
The entry gate. Associates a physical battery device with a user account. Every app session starts here.

### Route
`/serial-entry`

### Entry Conditions
- From Splash (auto-navigation after 2 seconds)
- From Account screen after Logout
- From Account screen after Remove Device
- From Account screen after Delete Account
- All navigations to this screen clear the entire navigation back stack

### Exit Conditions
- Valid serial + user NOT logged in → `/auth` (retain serial in `pendingSerialProvider`)
- Valid serial + user IS logged in + serial validated in Firestore → provisioning check:
  - `provisioned = false` → `/provisioning`
  - `provisioned = true` AND `ownerUid = null` → call `forceReprovision` Cloud Function → `/provisioning`
  - `provisioned = true` AND `ownerUid = currentUser.uid` AND Connection Type seen before → `/dashboard`
  - `provisioned = true` AND `ownerUid = currentUser.uid` AND Connection Type never seen → `/connection-type`

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  body: SafeArea(
    child: SerialEntryBody()
  )
)
```
No app bar. No back button. This is a root screen.

### Widget Tree — Default State

```
Column (mainAxisAlignment: spaceBetween)
  │
  ├── Padding (top: space48)
  │     └── Column
  │           ├── SvgPicture.asset('assets/images/ohmitron_logo.svg')
  │           │     width: 64px, height: 64px
  │           │     alignment: center
  │           │
  │           ├── SizedBox (height: space32)
  │           │
  │           ├── Text('Enter Serial Number')
  │           │     style: headlineLarge (24sp Bold)
  │           │     color: colorBlack
  │           │     alignment: center
  │           │
  │           ├── SizedBox (height: space8)
  │           │
  │           └── Text('Found on the label on your battery unit')
  │                 style: bodyMedium (14sp Regular)
  │                 color: colorDarkGrey
  │                 alignment: center
  │
  ├── Padding (horizontal: space16)
  │     └── Column
  │           ├── AppTextField
  │           │     label: 'Serial Number'
  │           │     hint: 'e.g. OHM00123456'
  │           │     keyboardType: TextInputType.text
  │           │     textCapitalization: TextCapitalization.characters
  │           │     maxLength: 12
  │           │     inputFormatters: [AlphanumericFormatter]
  │           │     onChanged: updates serialInputProvider
  │           │
  │           ├── SizedBox (height: space8)
  │           │
  │           └── Text (error message — hidden by default)
  │                 style: bodySmall (12sp)
  │                 color: colorErrorRed
  │                 visible: when errorMessageProvider is not null
  │
  └── Padding (horizontal: space16, bottom: space32)
        └── AppButton (Primary variant)
              label: 'Continue'
              onTap: _onContinueTapped
              isEnabled: serial input passes format validation
              isLoading: when continuePressedProvider is true
```

### Input Validation (Client-Side)
- Only alphanumeric characters (A-Z, 0-9). Enforced via `AlphanumericInputFormatter`.
- Minimum 8 characters, maximum 12 characters.
- "Continue" button is disabled (greyed, `colorDisabled`) until these conditions are met.
- No error is shown while typing — only after tapping "Continue".

### Interaction — "Continue" Button Tapped

```
Step 1: Set isLoading = true (button shows spinner)
Step 2: Check mockAuthService.isLoggedIn
  
  IF not logged in:
    Step 3a: Store serial in pendingSerialProvider (in-memory only)
    Step 4a: Navigate to /auth
    Step 5a: isLoading = false
  
  IF logged in:
    Step 3b: Query Firestore (mock: mockDataSource.validateSerial(serial))
    
    Result: Serial not found in Firestore AND BLE scan finds matching ESP32:
      Step 4b: Store serial in currentSerialProvider
      Step 5b: Pull metadata from ESP32 via BLE
      Step 6b: Create devices document in Firestore
      Step 7b: Navigate to /provisioning
    
    Result: Serial not found in Firestore AND BLE scan finds NO ESP32:
      Step 4b: Show error: 'Device not found. Make sure your battery
               is powered on and within 1 metre of your phone.'
      Step 5b: isLoading = false
    
    Result: Serial found, ownerUid = null, provisioned = true:
      Step 4b: Call forceReprovision Cloud Function
      Step 5b: Navigate to /provisioning
    
    Result: Serial found, ownerUid = anotherUser:
      Step 4b: Show error: 'This device is registered to another account.
               Contact support to transfer ownership.'
      Step 5b: isLoading = false
    
    Result: Serial found, ownerUid = currentUser, provisioned = false:
      Step 4b: Navigate to /provisioning
    
    Result: Serial found, ownerUid = currentUser, provisioned = true,
            connectionTypeSeen = false:
      Step 4b: Navigate to /connection-type
    
    Result: Serial found, ownerUid = currentUser, provisioned = true,
            connectionTypeSeen = true:
      Step 4b: Navigate to /dashboard
```

### Error Messages (Exact Strings)
- Wrong format: "Serial number must be 8–12 letters and numbers only."
- Device not found physically: "Device not found. Make sure your battery is powered on and within 1 metre of your phone."
- Owned by another user: "This device is registered to another account. Contact support to transfer ownership."
- Network error: "Could not connect. Please check your internet connection and try again."

### Animation — Screen Entrance
- Slides in from right (standard forward navigation)
- Duration: 300ms, curve: `easeOutCubic`

### Mock Data Bindings
- `mockDataSource.validateSerial(serial)` — returns `true` for any 8–12 alphanumeric string, `false` for "00000000"
- `mockIsLoggedIn` flag — controls auth state
- `pendingSerialProvider` — stores serial in memory during login redirect

---

## Screen 3 — Login / Sign Up Screen

### Purpose
Firebase Email/Password authentication. Two tabs on one screen.

### Route
`/auth`

### Entry Conditions
- From Serial Entry when user is not logged in
- Serial number is retained in `pendingSerialProvider` — this screen must never clear it

### Exit Conditions
- Successful login or signup → automatically validate `pendingSerialProvider` serial → follow Serial Entry exit logic
- This screen never navigates to Dashboard directly — always goes through serial validation first

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  body: SafeArea(
    child: AuthBody()
  )
)
```
No app bar. Back button behaviour: tapping Android back clears pending serial and returns to Serial Entry.

### Widget Tree

```
Column
  │
  ├── Padding (top: space32, horizontal: space16)
  │     └── Column
  │           ├── SvgPicture.asset logo — 56px × 56px, centred
  │           ├── SizedBox (height: space24)
  │           └── TabBar (2 tabs: 'Log In', 'Sign Up')
  │                 indicator: underline, color: colorBrandGreen
  │                 labelStyle: labelLarge (16sp SemiBold)
  │                 labelColor: colorBrandGreen
  │                 unselectedLabelColor: colorDarkGrey
  │
  └── Expanded
        └── TabBarView
              ├── LoginTab
              └── SignUpTab
```

### Tab 1 — Login Tab Widget Tree

```
SingleChildScrollView
  └── Padding (horizontal: space16)
        └── Column
              ├── SizedBox (height: space32)
              │
              ├── AppTextField
              │     label: 'Email'
              │     keyboardType: email
              │     textInputAction: TextInputAction.next
              │
              ├── SizedBox (height: space16)
              │
              ├── AppTextField
              │     label: 'Password'
              │     obscureText: true (toggle with eye icon)
              │     textInputAction: TextInputAction.done
              │     onSubmitted: triggers login
              │
              ├── SizedBox (height: space8)
              │
              ├── Align (alignment: centerRight)
              │     └── TextButton
              │           label: 'Forgot Password?'
              │           style: bodyMedium (14sp Regular)
              │           color: colorBrandGreen
              │           onTap: navigate to /forgot-password
              │
              ├── SizedBox (height: space24)
              │
              ├── AppButton (Primary)
              │     label: 'Log In'
              │     onTap: _onLoginTapped
              │     isLoading: loginLoadingProvider
              │
              └── SizedBox (height: space16)
```

### Login Interaction — "Log In" Tapped
```
Step 1: Validate email format and password not empty
Step 2: If invalid — show inline field errors
Step 3: If valid — set loginLoading = true
Step 4: Call mockAuthService.login(email, password)
Step 5a: Success → proceed to serial validation with pendingSerial
Step 5b: Failure → show SnackBar: 'Incorrect email or password. Please try again.'
Step 6: loginLoading = false
```

### Tab 2 — Sign Up Tab Widget Tree

```
SingleChildScrollView
  └── Padding (horizontal: space16)
        └── Column
              ├── SizedBox (height: space32)
              │
              ├── AppTextField
              │     label: 'Full Name'
              │     keyboardType: name
              │     maxLength: 60
              │     textInputAction: next
              │
              ├── SizedBox (height: space16)
              │
              ├── AppTextField
              │     label: 'Email'
              │     keyboardType: email
              │     textInputAction: next
              │
              ├── SizedBox (height: space16)
              │
              ├── AppTextField
              │     label: 'Password'
              │     obscureText: true
              │     helperText: 'Minimum 8 characters'
              │     textInputAction: next
              │
              ├── SizedBox (height: space16)
              │
              ├── AppTextField
              │     label: 'Confirm Password'
              │     obscureText: true
              │     textInputAction: next
              │
              ├── SizedBox (height: space16)
              │
              ├── GestureDetector (opens DatePicker)
              │     └── AppTextField (read-only display)
              │           label: 'Date of Birth'
              │           suffixIcon: calendar_today icon
              │           value: formatted date or empty
              │
              ├── SizedBox (height: space20)
              │
              ├── Row (crossAxisAlignment: start)
              │     ├── Checkbox
              │     │     activeColor: colorBrandGreen
              │     │     value: agreeToTermsProvider
              │     └── Expanded
              │           └── RichText
              │                 'I agree to the '
              │                 + TextSpan('Privacy Policy', color: colorBrandGreen,
              │                            onTap: openInAppBrowser)
              │                 + ' and '
              │                 + TextSpan('Terms of Service', color: colorBrandGreen,
              │                            onTap: openInAppBrowser)
              │
              ├── SizedBox (height: space24)
              │
              └── AppButton (Primary)
                    label: 'Create Account'
                    onTap: _onSignUpTapped
                    isEnabled: all fields valid AND checkbox checked
                    isLoading: signupLoadingProvider
```

### Sign Up Validation Rules
| Field | Rule | Error Message |
|-------|------|---------------|
| Full Name | Not empty, max 60 chars | "Please enter your name" |
| Email | Valid email format | "Please enter a valid email address" |
| Password | Minimum 8 characters | "Password must be at least 8 characters" |
| Confirm Password | Matches password | "Passwords do not match" |
| Date of Birth | Age ≥ 13 years | "You must be at least 13 years old to use this app" |
| Terms checkbox | Must be checked | (button remains disabled — no error message) |

### Date Picker Behaviour
- Opens Flutter `showDatePicker`
- `firstDate`: 100 years ago
- `lastDate`: 13 years ago from today (enforces age minimum)
- Selected date displayed as: `DD MMM YYYY` (e.g., "15 Jan 1995")
- `primaryColor`: `colorBrandGreen`

### Sign Up Interaction
```
Step 1: Validate all fields on "Create Account" tap
Step 2: Show first failing field error only
Step 3: If all valid → set signupLoading = true
Step 4: Call mockAuthService.createAccount(name, email, password, dob)
Step 5a: Success → proceed to serial validation with pendingSerial
Step 5b: Email already exists → SnackBar: 'An account with this email already
         exists. Try logging in instead.'
Step 6: signupLoading = false
```

### Animation — Screen Entrance
- Slides in from right, 300ms `easeOutCubic`

### Animation — Tab Switch
- Tab content fades between Log In and Sign Up: 200ms `easeInOut`
- TabBar indicator slides along the underline: 200ms `easeOutCubic`

### Mock Data Bindings
- `mockAuthService.login(email, password)` — succeeds for any non-empty input, fails for email "fail@test.com"
- `mockAuthService.createAccount(...)` — succeeds for any valid input, fails for email "taken@test.com"

---

## Screen 4 — Forgot Password Screen

### Purpose
Allows users to reset their password via a Firebase-generated email link. Two-state animated stepper.

### Route
`/forgot-password`

### Entry Conditions
- Tapping "Forgot Password?" on the Login tab

### Exit Conditions
- "Back to Login" button → pop back to `/auth`, land on Login tab
- Android back button → same as above

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  appBar: AppBar(
    backgroundColor: colorBackground,
    elevation: 0,
    leading: BackButton (color: colorBlack)
    title: Text('Reset Password', style: headlineLarge)
  ),
  body: SafeArea(child: ForgotPasswordBody())
)
```

### Stepper States Overview
The screen has 2 states. Transitions between states use horizontal slide animation (300ms `easeOutCubic`).

**State 1 — Enter Email**
**State 2 — Confirmation**

### State 1 — Enter Email Widget Tree

```
Padding (horizontal: space16)
  └── Column
        ├── SizedBox (height: space32)
        │
        ├── Text('Enter your email address')
        │     style: headlineMedium (20sp SemiBold)
        │     color: colorBlack
        │
        ├── SizedBox (height: space8)
        │
        ├── Text('We'll send a link to reset your password.')
        │     style: bodyMedium (14sp Regular)
        │     color: colorDarkGrey
        │
        ├── SizedBox (height: space32)
        │
        ├── AppTextField
        │     label: 'Email Address'
        │     keyboardType: email
        │     textInputAction: done
        │     onSubmitted: triggers send
        │
        ├── SizedBox (height: space24)
        │
        └── AppButton (Primary)
              label: 'Send Reset Link'
              onTap: _onSendTapped
              isLoading: sendingProvider
```

### State 1 — Interaction
```
Step 1: Validate email format
Step 2: If invalid → show AppTextField error: 'Please enter a valid email address'
Step 3: If valid → set sending = true
Step 4: Call FirebaseAuth.sendPasswordResetEmail(email)
        (mock: mockAuthService.sendPasswordReset(email) — always returns success)
Step 5: ALWAYS transition to State 2 regardless of whether email exists
        (Firebase does not reveal if email exists — security by design)
Step 6: sending = false
```

### State 2 — Confirmation Widget Tree

```
Padding (horizontal: space16)
  └── Column (mainAxisAlignment: center)
        ├── Icon (mark_email_read, size: 64px, color: colorBrandGreen)
        │
        ├── SizedBox (height: space24)
        │
        ├── Text('Check your inbox')
        │     style: headlineMedium (20sp SemiBold)
        │     color: colorBlack
        │     textAlign: center
        │
        ├── SizedBox (height: space12)
        │
        ├── Text('A password reset link has been sent to [email].
        │         Follow the link in the email to set a new password.
        │         Check your spam folder if you don't see it.')
        │     style: bodyMedium (14sp Regular)
        │     color: colorDarkGrey
        │     textAlign: center
        │
        ├── SizedBox (height: space48)
        │
        └── AppButton (Secondary variant)
              label: 'Back to Login'
              onTap: pop to /auth
```

### Animation — State Transition (State 1 → State 2)
- State 1 content slides out to the left: translateX 0 → -100%, 300ms `easeInCubic`
- State 2 content slides in from the right: translateX +100% → 0, 300ms `easeOutCubic`
- Both animations run simultaneously

### Mock Data Bindings
- `mockAuthService.sendPasswordReset(email)` — always returns success after 1 second delay

---

## Screen 5 — Wi-Fi Provisioning Screen

### Purpose
One-time setup to deliver Wi-Fi credentials to the ESP32 via BLE. Never shown again after completion.

### Route
`/provisioning`

### Entry Conditions
- From Serial Entry when `provisioned = false`
- From Serial Entry when `ownerUid = null` and `provisioned = true` (force reprovision — `provisioned` already reset to `false` by Cloud Function before navigation)

### Exit Conditions
- Provisioning complete → navigate to `/connection-type` (replace, no back stack)
- "Cancel" on any error state → navigate to `/serial-entry` (replace, no back stack)

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  appBar: AppBar(
    backgroundColor: colorBackground,
    elevation: 0,
    title: Text('Device Setup', style: headlineLarge)
    automaticallyImplyLeading: false  // No back button — must complete or cancel
  ),
  body: SafeArea(child: ProvisioningBody())
)
```

### Provisioning States Overview
This screen has 7 states. Each state is a distinct UI shown inside the same scaffold.

```
State 1: Permission Check
State 2: Permission Denied
State 3: BLE Scanning
State 4: BLE Scan Failed
State 5: Wi-Fi Network Selection
State 6: Sending Credentials
State 7: Provisioning Complete
```

---

### State 1 — Permission Check
Shown briefly while checking BLE permission status. Usually transitions immediately.

```
Column (center)
  ├── LoadingIndicator (full screen variant)
  └── Text('Checking permissions...')
        style: bodyMedium, color: colorDarkGrey
```

Auto-transitions to State 2 (if permission denied) or State 3 (if permission granted).
If permission not yet requested → trigger system permission dialog → then evaluate result.

**Android API 31+:** Request `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT`
**Android API 23–30:** Request `ACCESS_FINE_LOCATION`

Pre-permission explanatory dialog (shown BEFORE system prompt):
```
ConfirmationDialog (not destructive — use Primary button)
  title: 'Bluetooth Required'
  body: 'We need Bluetooth access to connect to your battery
         device for this one-time setup. Bluetooth is not used
         after setup is complete.'
  confirmLabel: 'Allow'
  cancelLabel: 'Not Now' → navigates to /serial-entry
```

---

### State 2 — Permission Denied

```
Column (center, padding: horizontal space16)
  ├── Icon (bluetooth_disabled, size: 56px, color: colorErrorRed)
  │
  ├── SizedBox (height: space24)
  │
  ├── Text('Bluetooth Permission Required')
  │     style: headlineSmall (18sp SemiBold), color: colorBlack, center
  │
  ├── SizedBox (height: space12)
  │
  ├── Text('Please enable Bluetooth permission in your
  │         phone's Settings to set up your device.')
  │     style: bodyMedium, color: colorDarkGrey, center
  │
  ├── SizedBox (height: space32)
  │
  ├── AppButton (Primary)
  │     label: 'Open Settings'
  │     onTap: openAppSettings() via permission_handler
  │
  ├── SizedBox (height: space16)
  │
  └── AppButton (Secondary)
        label: 'Cancel Setup'
        onTap: navigate to /serial-entry
```

---

### State 3 — BLE Scanning

```
Column (center, padding: horizontal space16)
  ├── AnimatedScanWidget
  │     (custom widget: pulsing concentric circles in colorBrandGreen at
  │      decreasing opacity: 100%, 60%, 30% — each circle pulses outward
  │      repeatedly, staggered by 400ms, duration 1500ms per pulse)
  │     size: 120px × 120px
  │
  ├── SizedBox (height: space32)
  │
  ├── Text('Searching for your device...')
  │     style: headlineSmall (18sp SemiBold), color: colorBlack, center
  │
  ├── SizedBox (height: space12)
  │
  ├── Text('Make sure your battery is powered on
  │         and within 1 metre of your phone.')
  │     style: bodyMedium, color: colorDarkGrey, center
  │
  └── SizedBox (height: space48)
        └── TextButton
              label: 'Cancel'
              color: colorDarkGrey
              onTap: navigate to /serial-entry
```

Scan timeout: 30 seconds. After 30 seconds with no device found → transition to State 4.
On device found → transition to State 5.

---

### State 4 — BLE Scan Failed

```
AppErrorWidget
  icon: bluetooth_searching (colorErrorRed)
  title: 'Device Not Found'
  subtitle: 'Make sure your battery is powered on and
             within 1 metre of your phone, then try again.'

Below AppErrorWidget:
  ├── AppButton (Primary)
  │     label: 'Try Again'
  │     onTap: restart scan → transition to State 3
  │
  └── SizedBox (height: space16)
        └── AppButton (Secondary)
              label: 'Cancel'
              onTap: navigate to /serial-entry
```

---

### State 5 — Wi-Fi Network Selection

```
Column
  ├── Padding (horizontal: space16)
  │     └── Column
  │           ├── Text('Select Wi-Fi Network')
  │           │     style: headlineSmall (18sp SemiBold), color: colorBlack
  │           │
  │           ├── SizedBox (height: space8)
  │           │
  │           └── Text('Choose the Wi-Fi network you want your
  │                     battery monitor to connect to.')
  │                 style: bodyMedium, color: colorDarkGrey
  │
  ├── SizedBox (height: space16)
  │
  ├── Expanded
  │     └── ListView.builder (networks list)
  │           Each item: NetworkListItem
  │             ├── Icon (wifi, size: 20px, color: colorBrandGreen)
  │             ├── Text (SSID name, bodyLarge)
  │             ├── Spacer
  │             └── Icon (signal strength indicator)
  │           Height: 56px per item
  │           Divider: colorDivider 1px between items
  │           On tap: select network → expand password field below
  │
  └── AnimatedContainer (expands when network selected)
        └── Padding (horizontal: space16, vertical: space16)
              └── Column
                    ├── Text('Password for "[selected SSID]"')
                    │     style: labelMedium, color: colorDarkGrey
                    │
                    ├── SizedBox (height: space8)
                    │
                    ├── AppTextField
                    │     label: 'Wi-Fi Password'
                    │     obscureText: true
                    │     textInputAction: done
                    │
                    ├── SizedBox (height: space16)
                    │
                    └── AppButton (Primary)
                          label: 'Connect Device'
                          onTap: _onConnectTapped
                          isEnabled: password field not empty
                          isLoading: connectingProvider
```

### Mock Wi-Fi Networks List
```dart
const mockNetworks = [
  WifiNetwork(ssid: 'HomeWiFi', signalStrength: -45),
  WifiNetwork(ssid: 'OfficeWiFi', signalStrength: -62),
  WifiNetwork(ssid: 'Ohmitron_Lab', signalStrength: -71),
  WifiNetwork(ssid: 'iPhone_Hotspot', signalStrength: -80),
];
```

---

### State 6 — Sending Credentials

```
Column (center)
  ├── LoadingIndicator (full screen)
  │
  ├── SizedBox (height: space24)
  │
  ├── Text('Connecting your device...')
  │     style: headlineSmall (18sp SemiBold), color: colorBlack, center
  │
  └── Text('This may take a few seconds.')
        style: bodyMedium, color: colorDarkGrey, center
```

On mock: waits 2 seconds → transitions to State 7 (success) or State 4 (failure).
On failure (wrong password or network unreachable): show `SnackBar`: "Could not connect to that network. Please check the password and try again." → return to State 5.

---

### State 7 — Provisioning Complete

```
Column (center, padding: horizontal space16)
  ├── Icon (check_circle, size: 64px, color: colorBrandGreen)
  │     Entrance animation: scale from 0 to 1.0, 400ms elasticOut
  │
  ├── SizedBox (height: space24)
  │
  ├── Text('Device Connected!')
  │     style: headlineMedium (20sp SemiBold), color: colorBlack, center
  │     Entrance: fade in 300ms after icon animation
  │
  ├── SizedBox (height: space12)
  │
  └── Text('Your battery monitor is now connected
  │         to [selected SSID] and sending data.')
        style: bodyMedium, color: colorDarkGrey, center
        Entrance: fade in 400ms after title
```

Auto-navigates to `/connection-type` after 2 seconds. No button needed.

### State Transition Animations
All state transitions inside the Provisioning screen use a cross-fade: current state fades out (200ms) → new state fades in (300ms `easeOutCubic`).

---

## Screen 6 — Connection Type Screen

### Purpose
Informs the user of the active connection method. Shown exactly once after provisioning completes. Never shown again.

### Route
`/connection-type`

### Entry Conditions
- From Provisioning screen (State 7 auto-navigation) — first and only time shown
- A `connectionTypeSeenProvider` flag is set to `true` after this screen is shown

### Exit Conditions
- "Continue" tapped → navigate to `/dashboard` (replace stack — no back)

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  body: SafeArea(child: ConnectionTypeBody())
)
```
No app bar. No back button. This screen is informational and cannot be revisited.

### Widget Tree

```
Column (mainAxisAlignment: spaceBetween)
  │
  ├── Padding (top: space48, horizontal: space16)
  │     └── Column
  │           ├── Text('Connection Method')
  │           │     style: headlineLarge (24sp Bold), color: colorBlack
  │           │
  │           └── SizedBox (height: space8)
  │                 └── Text('Your device is now configured to send
  │                           data via Wi-Fi from anywhere.')
  │                       style: bodyMedium, color: colorDarkGrey
  │
  ├── Padding (horizontal: space16)
  │     └── Column
  │           │
  │           ├── ConnectionTypeCard (ACTIVE — Wi-Fi)
  │           │     Container
  │           │       border: 2px solid colorBrandGreen
  │           │       borderRadius: 16px
  │           │       padding: space20
  │           │       background: colorSurface
  │           │       └── Row
  │           │             ├── Icon (wifi, 32px, colorBrandGreen)
  │           │             ├── SizedBox (width: space16)
  │           │             ├── Expanded
  │           │             │     └── Column
  │           │             │           ├── Text('Wi-Fi (Cloud Mode)')
  │           │             │           │     style: headlineSmall (18sp SemiBold)
  │           │             │           │     color: colorBlack
  │           │             │           └── Text('Monitor from anywhere via internet')
  │           │             │                 style: bodySmall, color: colorDarkGrey
  │           │             └── AppBadge (green, label: 'Active')
  │           │
  │           ├── SizedBox (height: space16)
  │           │
  │           └── ConnectionTypeCard (DISABLED — Bluetooth)
  │                 Container
  │                   border: 1.5px solid colorDivider
  │                   borderRadius: 16px
  │                   padding: space20
  │                   background: colorBackground (slightly dimmed)
  │                   opacity: 0.5
  │                   └── Row
  │                         ├── Icon (bluetooth, 32px, colorDisabled)
  │                         ├── SizedBox (width: space16)
  │                         ├── Expanded
  │                         │     └── Column
  │                         │           ├── Text('Bluetooth (Direct Mode)')
  │                         │           │     style: headlineSmall, color: colorDisabled
  │                         │           └── Text('Connect directly without internet')
  │                         │                 style: bodySmall, color: colorDisabled
  │                         └── AppBadge (grey, label: 'Coming Soon')
  │
  └── Padding (horizontal: space16, bottom: space32)
        └── AppButton (Primary)
              label: 'Continue'
              onTap: set connectionTypeSeenProvider = true → navigate to /dashboard
```

### Animation — Screen Entrance
- Fades in: 400ms `easeInOut` (this is the "arrival" transition — not a slide)
- Both cards animate in with staggered fade + slide up from 20px:
  - Wi-Fi card: delay 100ms, duration 400ms `easeOutCubic`
  - Bluetooth card: delay 200ms, duration 400ms `easeOutCubic`

---

## Screen 7 — Dashboard Screen

### Purpose
The heart of the app. Displays live battery telemetry. Refreshes every 30 seconds. The user returns here from all secondary screens.

### Route
`/dashboard`

### Entry Conditions
- From Connection Type screen (first time)
- From any secondary screen via back navigation
- From sidebar "Home" item

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  appBar: DashboardAppBar(),   // Custom — see below
  drawer: AppDrawer(),         // Custom sidebar — see below
  body: SafeArea(
    child: RefreshIndicator(
      color: colorBrandGreen,
      onRefresh: _onManualRefresh,
      child: DashboardBody()
    )
  )
)
```

### App Bar Widget Tree

```
AppBar
  backgroundColor: colorBackground
  elevation: 0
  leading: IconButton
    icon: Icon(menu, 24px, colorBlack)
    onTap: Scaffold.of(context).openDrawer()
  title: DeviceNameHeader (device friendly name)
  actions: [
    IconButton (photo_camera, 24px, colorBlack)
      onTap: _onShareTapped
    IconButton (notifications, 24px, colorBlack)
      onTap: navigate to /notifications
      badge: unread count (shown when > 0)
        badge color: colorErrorRed
        badge text color: white
        badge style: labelSmall (12sp Medium)
    IconButton (person, 24px, colorBlack)
      onTap: navigate to /account
  ]
```

### Sidebar (Drawer) Widget Tree

```
Drawer (width: 280px)
  └── Container (color: colorSidebarBackground)
        └── Column
              │
              ├── DrawerHeader (height: 160px)
              │     Container (color: colorBrandGreen)
              │       └── Column (mainAxisAlignment: center)
              │             ├── SvgPicture.asset logo (white tint, 48px)
              │             ├── SizedBox (height: space12)
              │             ├── Text('Ohmitron')
              │             │     style: headlineMedium, color: white
              │             └── Text(deviceFriendlyName)
              │                   style: bodyMedium, color: white 80% opacity
              │
              ├── DrawerItem
              │     icon: home
              │     label: 'Home'
              │     isActive: true (on Dashboard)
              │     onTap: close drawer
              │
              ├── DrawerItem
              │     icon: info
              │     label: 'Basic Information'
              │     isActive: false
              │     onTap: navigate to /basic-info (slide up)
              │
              └── DrawerItem
                    icon: warning
                    label: 'Error Report'
                    isActive: false
                    onTap: navigate to /error-report (slide up)
```

### Dashboard Body — Loading State (First Load Only)
Shown when `batteryStatusProvider` is in loading state AND no cached data exists.

```
Center
  └── LoadingIndicator (full screen variant)
        label: 'Loading your battery data...'
```

### Dashboard Body — Error State
Shown when Firestore read fails entirely.

```
AppErrorWidget
  title: 'Could Not Load Data'
  subtitle: 'Pull down to try again.'
```

### Dashboard Body — Data State (Normal)
Shown when data is available (fresh or stale).

```
SingleChildScrollView
  physics: AlwaysScrollableScrollPhysics (required for pull-to-refresh)
  └── Column
        │
        ├── StaleDataBanner (visible only when data is stale)
        │     Animated: slides down when shown, slides up when dismissed
        │
        ├── SizedBox (height: space24)
        │
        ├── Padding (horizontal: space16)  ← Battery Gauge Section
        │     └── AnimatedBatteryGauge
        │           soc: batteryStatus.stateOfCharge
        │           isCharging: batteryStatus.isCharging
        │           width: screenWidth - 32px
        │           height: 160px
        │
        ├── SizedBox (height: space32)
        │
        ├── Padding (horizontal: space16)  ← 2-Column Stats Grid
        │     └── Row
        │           ├── Expanded
        │           │     └── StatCard
        │           │           label: 'Remaining Time'
        │           │           value: formatRemainingTime(batteryStatus.remainingTimeHours)
        │           │           icon: schedule
        │           │
        │           └── SizedBox (width: space16)
        │                 └── Expanded
        │                       └── StatCard
        │                             label: 'Discharging'
        │                             value: '${batteryStatus.dischargingWatts}W'
        │                             icon: flash_on
        │                             showDash: batteryStatus.isCharging
        │
        ├── SizedBox (height: space24)
        │
        ├── Padding (horizontal: space16)  ← Status Section Header
        │     └── SectionHeader (label: 'Status')
        │
        ├── Padding (horizontal: space16)  ← Flat Status Fields
        │     └── Container
        │           decoration: border 1.5px colorDivider, borderRadius 16px
        │           background: colorSurface
        │           └── Column
        │                 ├── StatusRow
        │                 │     label: 'Charging'
        │                 │     value: AppBadge (green 'Active' or grey 'Inactive')
        │                 │     icon: bolt
        │                 │
        │                 ├── Divider (colorDivider, 1px)
        │                 │
        │                 ├── StatusRow
        │                 │     label: 'Discharging'
        │                 │     value: AppBadge
        │                 │     icon: battery_5_bar
        │                 │
        │                 ├── Divider
        │                 │
        │                 ├── StatusRow
        │                 │     label: 'Balance'
        │                 │     value: AppBadge based on balanceState
        │                 │     icon: balance
        │                 │
        │                 ├── Divider
        │                 │
        │                 ├── StatusRow
        │                 │     label: 'Protection'
        │                 │     value: AppBadge based on protectionState
        │                 │     icon: shield
        │                 │
        │                 ├── Divider
        │                 │
        │                 └── StatusRow
        │                       label: 'Temperature'
        │                       value: Text('${batteryStatus.temperatureCelsius}°C')
        │                       icon: device_thermostat
        │                       valueColor: temperature-based
        │                           < 50°C: colorBlack
        │                           50–60°C: colorWarningAmber
        │                           > 60°C: colorErrorRed
        │
        ├── SizedBox (height: space24)
        │
        └── Padding (horizontal: space16, bottom: space32)  ← Error Summary Row
              └── GestureDetector (onTap: navigate to /error-report)
                    └── Container
                          decoration: border 1.5px colorDivider,
                                      borderRadius 16px,
                                      background: colorSurface
                          padding: space16
                          └── Row
                                ├── Icon (warning, 20px, colorWarningAmber)
                                ├── SizedBox (width: space12)
                                ├── Expanded
                                │     └── Column
                                │           ├── Text('Latest Error')
                                │           │     style: labelMedium, colorDarkGrey
                                │           └── Text(latestError ?? 'No errors recorded')
                                │                 style: bodyMedium, colorBlack
                                └── Icon (chevron_right, 20px, colorDisabled)
```

### StatCard Widget (reusable sub-widget, Dashboard only)
```
Container
  decoration: border 1.5px colorDivider, borderRadius 16px, background colorSurface
  padding: space16
  └── Column (crossAxisAlignment: start)
        ├── Row
        │     ├── Icon (icon, 16px, colorDarkGrey)
        │     └── SizedBox (width: space4)
        │           └── Text(label, bodySmall, colorDarkGrey)
        ├── SizedBox (height: space8)
        └── Text(value, displaySmall or headlineMedium)
              color: colorBlack (or '--' in colorDisabled when N/A)
```

### Stale Data Logic
```dart
// Run on every poll result
final lastTelemetry = batteryStatus.timestamp; // from telemetry/latest
final now = DateTime.now();
final isStale = now.difference(lastTelemetry).inSeconds > 45;

// When isStale = true:
//   Show StaleDataBanner
//   Dim all telemetry values (opacity: 0.5)
//   Continue showing last known values

// When isStale = false:
//   Hide StaleDataBanner
//   All values at full opacity
```

### Polling Logic
```dart
// Timer-based polling every 30 seconds
// Implemented in dashboardProvider using Timer.periodic
// On each tick: call mockDataSource.getLatestTelemetry()
// Update batteryStatusProvider with new data
// Update lastUpdateTime for stale detection
// Pull-to-refresh calls same method immediately
```

### Value Formatting Rules
| Field | Format | Example | Edge Case |
|-------|--------|---------|-----------|
| Remaining Time | `Xh Ym` | `3h 42m` | If < 1 hour: `< 1h`. If null: `--` |
| Discharging Watts | `XX.X W` | `45.2 W` | If charging: `--` |
| State of Charge | `XX%` | `78%` | Always show even if charging |
| Temperature | `XX.X °C` | `28.5 °C` | Colour based on value |
| Balance State | Badge | `Balancing` | Map: inactive→grey, active→green, balancing→amber |
| Protection State | Badge | `Overcurrent` | Map: none→green 'Protected', others→red with state name |

### Share Functionality
```
onShareTapped:
  1. Capture screenshot of Dashboard body (excluding app bar)
     via ScreenshotController from screenshot package
  2. Save to temporary file
  3. Open system share sheet via share_plus:
     Share.shareXFiles([XFile(tempPath)],
       text: 'Ohmitron Battery Status — ${DateTime.now()}')
```

### Animation — Screen Entrance
- Fades in from Connection Type screen (400ms)
- For subsequent returns (from sidebar screens): instant — no transition animation

### Mock Data Bindings
```dart
MockBatteryStatus emitted every 30 seconds:
  stateOfCharge: random 20–100, decreasing slowly
  remainingTimeHours: calculated from SOC
  dischargingWatts: random 40–60 when discharging
  isCharging: false by default, toggle for testing
  isDischarging: true by default
  balanceState: cycles inactive → active → balancing
  protectionState: 'none' by default, cycles to over_current for 2 cycles
  temperatureCelsius: random 25–40, occasionally > 60 for notification testing
  timestamp: DateTime.now() (server time in production)

Debug controls:
  mockStaleData: bool — when true, stream stops emitting (triggers stale banner after 45s)
  mockHighTemp: bool — when true, emits temperatureCelsius = 65
  mockLowSOC: bool — when true, emits stateOfCharge = 15
```

---

## Screen 8 — Basic Information Screen

### Purpose
Displays read-only device metadata. Allows editing of the device name.

### Route
`/basic-info`

### Entry Conditions
- From sidebar "Basic Information" item (slides up from bottom)

### Exit Conditions
- Android back button or back gesture → slides back down to Dashboard

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  appBar: AppBar(
    backgroundColor: colorBackground,
    elevation: 0,
    leading: BackButton(color: colorBlack)
    title: Text('Basic Information', style: headlineLarge)
  ),
  body: SafeArea(child: BasicInfoBody())
)
```

### Widget Tree

```
SingleChildScrollView
  └── Column
        │
        ├── SectionHeader ('Device Name')
        │
        ├── Padding (horizontal: space16)
        │     └── Container
        │           decoration: border 1.5px colorDivider, borderRadius 16px,
        │                       background: colorSurface
        │           padding: space16
        │           └── Row
        │                 ├── Expanded
        │                 │     └── Column (crossAxisAlignment: start)
        │                 │           ├── Text('Device Name', bodySmall, colorDarkGrey)
        │                 │           └── AppTextField (inline edit mode)
        │                 │                 value: deviceFriendlyName
        │                 │                 maxLength: 30
        │                 │                 style: bodyLarge, colorBlack
        │                 │                 border: none (editing in place)
        │                 └── AppButton (Primary, auto-width)
        │                       label: 'SET'
        │                       width: 60px
        │                       height: 40px
        │                       onTap: _onSetNameTapped
        │                       isLoading: setNameLoadingProvider
        │
        ├── SizedBox (height: space24)
        │
        ├── SectionHeader ('Device Details')
        │
        ├── Padding (horizontal: space16)
        │     └── Container
        │           decoration: border 1.5px colorDivider, borderRadius 16px,
        │                       background: colorSurface
        │           └── Column
        │                 ├── InfoRow (label: 'Serial Number', value: serialNumber)
        │                 ├── InfoRow (label: 'Device Model', value: deviceModel)
        │                 ├── InfoRow (label: 'Firmware Version', value: firmwareVersion)
        │                 ├── InfoRow (label: 'BMS Model', value: bmsModel)
        │                 └── InfoRow (label: 'BMS ID', value: bmsId)
        │
        ├── SizedBox (height: space24)
        │
        ├── SectionHeader ('Barcode')
        │
        ├── Padding (horizontal: space16)
        │     └── Container
        │           decoration: border 1.5px colorDivider, borderRadius 16px,
        │                       background: colorSurface
        │           padding: space20
        │           └── Center
        │                 └── BarcodeWidget
        │                       data: serialNumber
        │                       barcode: Barcode.code128()
        │                       width: screenWidth - 96px
        │                       height: 80px
        │                       drawText: true
        │                       textStyle: bodySmall
        │
        ├── SizedBox (height: space24)
        │
        ├── SectionHeader ('Connection')
        │
        ├── Padding (horizontal: space16, bottom: space32)
        │     └── Container
        │           decoration: border 1.5px colorDivider, borderRadius 16px,
        │                       background: colorSurface
        │           └── Column
        │                 ├── InfoRow (label: 'Connection Type', value: 'Wi-Fi (Cloud Mode)')
        │                 └── InfoRow (label: 'Connected Network',
        │                             value: connectedSsid ?? 'Unknown')
```

### SET Button Interaction
```
Step 1: Validate name — not empty, max 30 characters
Step 2: If invalid → show SnackBar: 'Name must be between 1 and 30 characters'
Step 3: If valid → set setNameLoading = true
Step 4: Call mockDataSource.updateDeviceName(newName)
Step 5: Update deviceFriendlyNameProvider in memory
Step 6: Attempt HTTP sync to ESP32 (mock: always succeeds silently)
Step 7: Show SnackBar: 'Device name updated'
Step 8: setNameLoading = false
```

### Animation — Screen Entrance
- Slides up from bottom, 350ms `easeOutCubic`

### Mock Data Bindings
```dart
MockDeviceInfo:
  serialNumber: 'OHM00123456'
  deviceModel: 'OHM-BMS-100'
  firmwareVersion: '1.2.4'
  bmsModel: 'JK-BMS-200A'
  bmsId: 'BMS-9A3F2C'
  friendlyName: 'Ohmitron Battery'
  connectedSsid: 'HomeWiFi'
```

---

## Screen 9 — Error Report Screen

### Purpose
Displays the 20 most recent BMS errors for the paired device, most recent first.

### Route
`/error-report`

### Entry Conditions
- From sidebar "Error Report" item (slides up from bottom)
- From Dashboard error summary row tap (slides up from bottom)

### Exit Conditions
- Back button → slides back down to Dashboard

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  appBar: AppBar(
    backgroundColor: colorBackground,
    elevation: 0,
    leading: BackButton(color: colorBlack)
    title: Text('Error Report', style: headlineLarge)
  ),
  body: SafeArea(child: ErrorReportBody())
)
```

### Widget Tree — Loading State
```
LoadingIndicator (full screen variant)
  label: 'Loading error history...'
```

### Widget Tree — Empty State
```
EmptyStateWidget
  icon: check_circle_outline (colorBrandGreen — positive empty state)
  title: 'No Errors Recorded'
  subtitle: 'Your battery is running normally.'
```

### Widget Tree — Data State
```
RefreshIndicator (colorBrandGreen)
  └── ListView.builder
        itemCount: errors.length (max 20)
        itemBuilder: ErrorListItem
        physics: AlwaysScrollableScrollPhysics
```

Each `ErrorListItem`:
```
Container
  padding: space16 horizontal, space12 vertical
  decoration: bottom border colorDivider 1px
  └── Column (crossAxisAlignment: start)
        ├── Row
        │     ├── SeverityChip (info/warning/critical)
        │     ├── SizedBox (width: space8)
        │     ├── Text(errorCode, labelMedium, colorBlack, Bold)
        │     └── Spacer
        │           └── Text(timestamp, bodySmall, colorDisabled)
        │                 format: 'DD MMM YYYY HH:mm'
        │
        └── SizedBox (height: space8)
              └── Text(errorMessage, bodyMedium, colorDarkGrey)
```

### Mock Data Bindings
```dart
List<ErrorEntry> mockErrors = [
  ErrorEntry(code: 'E006', message: 'Short circuit protection triggered',
             severity: 'critical', timestamp: now - 5min),
  ErrorEntry(code: 'E001', message: 'Cell overvoltage detected',
             severity: 'critical', timestamp: now - 12min),
  ErrorEntry(code: 'E004', message: 'Overcurrent on discharge',
             severity: 'warning', timestamp: now - 28min),
  ErrorEntry(code: 'E005', message: 'Cell imbalance detected',
             severity: 'warning', timestamp: now - 1h),
  ErrorEntry(code: 'E007', message: 'BMS communication timeout',
             severity: 'info', timestamp: now - 2h),
  ErrorEntry(code: 'E003', message: 'Pack overtemperature',
             severity: 'critical', timestamp: now - 3h),
  ErrorEntry(code: 'E002', message: 'Cell undervoltage detected',
             severity: 'critical', timestamp: now - 5h),
]
// New random error added every 5 minutes during mock session
// List never exceeds 20 items — oldest dropped when limit reached
```

---

## Screen 10 — Notifications Screen

### Purpose
In-app history of all push notifications sent for this device.

### Route
`/notifications`

### Entry Conditions
- Tapping bell icon in Dashboard app bar

### Exit Conditions
- Back button → returns to Dashboard

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  appBar: AppBar(
    backgroundColor: colorBackground,
    elevation: 0,
    leading: BackButton(color: colorBlack)
    title: Text('Notifications', style: headlineLarge)
    actions: [
      TextButton
        label: 'Clear All'
        style: labelMedium, colorErrorRed
        onTap: _onClearAllTapped
        visible: only when notifications list is not empty
    ]
  ),
  body: SafeArea(child: NotificationsBody())
)
```

### Widget Tree — Empty State
```
EmptyStateWidget
  icon: notifications_none
  title: 'No Notifications'
  subtitle: 'You\'ll see alerts here when your battery needs attention.'
```

### Widget Tree — Data State
```
RefreshIndicator (colorBrandGreen)
  └── ListView.builder
        itemCount: notifications.length
        itemBuilder: NotificationListItem (swipe-to-delete)
        physics: AlwaysScrollableScrollPhysics
```

Each `NotificationListItem`:
```
Dismissible (key: notification id)
  direction: DismissDirection.endToStart
  background: Container (colorErrorRed)
    alignment: centerRight
    padding: space16
    child: Icon(delete, white, 24px)
  confirmDismiss: returns true (immediate delete)
  onDismissed: call mockDataSource.deleteNotification(id)

  child: Container
    padding: space16 horizontal, space12 vertical
    decoration: bottom border colorDivider 1px
    background: unread ? colorSurface : colorBackground
    └── Row
          ├── Container (8px circle, colorBrandGreen)
          │     visible: !notification.read
          │     Fade out on tap: 200ms
          │
          ├── SizedBox (width: space12)
          │
          ├── Expanded
          │     └── Column (crossAxisAlignment: start)
          │           ├── Text(title, labelMedium, colorBlack)
          │           ├── SizedBox (height: space4)
          │           └── Text(body, bodySmall, colorDarkGrey)
          │
          └── Text(relativeTime, bodySmall, colorDisabled)
                e.g. '2h ago', 'Yesterday'
```

### Clear All Interaction
```
ConfirmationDialog:
  title: 'Clear All Notifications'
  body: 'Delete all notifications? This cannot be undone.'
  confirmLabel: 'Delete All' (Destructive button)
  cancelLabel: 'Cancel'
  onConfirm: mockDataSource.clearAllNotifications()
             → list animates out (ListView animated removal)
             → EmptyStateWidget fades in
```

### Mock Data Bindings
```dart
List<AppNotification> mockNotifications triggered by:
  - temperatureCelsius > 60 → 'High Temperature Alert'
  - protectionState != 'none' → 'Battery Protection Activated'
  - stateOfCharge < 20 → 'Low Battery'
  - new error added → 'Battery Error Detected'

Each notification:
  AppNotification(
    id: uuid,
    title: 'High Temperature Alert',
    body: 'Your battery temperature has reached 65°C. Check your device.',
    timestamp: DateTime.now(),
    read: false,
    deviceSerial: 'OHM00123456'
  )
```

---

## Screen 11 — Account Screen

### Purpose
User profile management, password change, device management, and account lifecycle actions.

### Route
`/account`

### Entry Conditions
- Tapping person icon in Dashboard app bar

### Exit Conditions
- Back button → returns to Dashboard
- Logout → navigates to `/serial-entry` (replace entire stack)
- Remove Device → navigates to `/serial-entry` (replace entire stack)
- Delete Account → navigates to `/serial-entry` (replace entire stack)

### Scaffold Structure
```
Scaffold(
  backgroundColor: colorBackground,
  appBar: AppBar(
    backgroundColor: colorBackground,
    elevation: 0,
    leading: BackButton(color: colorBlack)
    title: Text('Account', style: headlineLarge)
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      child: AccountBody()
    )
  )
)
```

### Widget Tree

```
Column
  │
  ├── SectionHeader ('Profile')
  │
  ├── Padding (horizontal: space16)
  │     └── Container
  │           decoration: border 1.5px colorDivider, borderRadius 16px,
  │                       background: colorSurface
  │           padding: space16
  │           └── Column
  │                 ├── AppTextField
  │                 │     label: 'Full Name'
  │                 │     value: currentUser.name
  │                 │     maxLength: 60
  │                 │     textInputAction: next
  │                 │
  │                 ├── SizedBox (height: space16)
  │                 │
  │                 ├── GestureDetector (opens DatePicker)
  │                 │     └── AppTextField (read-only)
  │                 │           label: 'Date of Birth'
  │                 │           value: formatDate(currentUser.dob)
  │                 │           suffixIcon: calendar_today
  │                 │
  │                 ├── SizedBox (height: space16)
  │                 │
  │                 ├── AppTextField (read-only, no border highlight on focus)
  │                 │     label: 'Email Address'
  │                 │     value: currentUser.email
  │                 │     enabled: false
  │                 │     helperText: 'Email cannot be changed in this version'
  │                 │
  │                 ├── SizedBox (height: space20)
  │                 │
  │                 └── AppButton (Primary)
  │                       label: 'Save Changes'
  │                       onTap: _onSaveProfileTapped
  │                       isLoading: saveProfileLoadingProvider
  │
  ├── SizedBox (height: space24)
  │
  ├── SectionHeader ('Security')
  │
  ├── Padding (horizontal: space16)
  │     └── Container
  │           decoration: border 1.5px colorDivider, borderRadius 16px,
  │                       background: colorSurface
  │           └── ListTile
  │                 title: Text('Change Password', bodyLarge, colorBlack)
  │                 trailing: Icon(chevron_right, colorDisabled)
  │                 onTap: _onChangePasswordTapped (opens bottom sheet)
  │
  ├── SizedBox (height: space24)
  │
  ├── SectionHeader ('Device')
  │
  ├── Padding (horizontal: space16)
  │     └── Container
  │           decoration: border 1.5px colorDivider, borderRadius 16px,
  │                       background: colorSurface
  │           └── Column
  │                 ├── ListTile
  │                 │     leading: Icon(devices, colorDarkGrey)
  │                 │     title: Text('Paired Device', bodyLarge, colorBlack)
  │                 │     subtitle: Text(deviceSerialNumber, bodySmall, colorDarkGrey)
  │                 │     trailing: AppBadge (green, 'Connected')
  │                 │
  │                 └── Padding (horizontal: space16, bottom: space16)
  │                       └── AppButton (Secondary)
  │                             label: 'Remove Device'
  │                             onTap: _onRemoveDeviceTapped
  │
  ├── SizedBox (height: space24)
  │
  ├── SectionHeader ('Account')
  │
  ├── Padding (horizontal: space16)
  │     └── Container
  │           decoration: border 1.5px colorDivider, borderRadius 16px,
  │                       background: colorSurface
  │           └── Column
  │                 ├── ListTile
  │                 │     leading: Icon(logout, colorDarkGrey)
  │                 │     title: Text('Log Out', bodyLarge, colorBlack)
  │                 │     onTap: _onLogoutTapped
  │                 │
  │                 └── ListTile
  │                       leading: Icon(delete_forever, colorErrorRed)
  │                       title: Text('Delete Account', bodyLarge, colorErrorRed)
  │                       onTap: _onDeleteAccountTapped
  │
  └── SizedBox (height: space48)
```

### Change Password — Bottom Sheet

```
DraggableScrollableSheet (initialChildSize: 0.6)
  └── Padding (horizontal: space16)
        └── Column
              ├── SizedBox (height: space16)
              ├── Container (drag handle — 4px × 32px, colorDivider, rounded)
              ├── SizedBox (height: space24)
              ├── Text('Change Password', headlineMedium)
              ├── SizedBox (height: space24)
              ├── AppTextField (label: 'Current Password', obscure: true)
              ├── SizedBox (height: space16)
              ├── AppTextField (label: 'New Password', obscure: true,
              │                 helperText: 'Minimum 8 characters')
              ├── SizedBox (height: space16)
              ├── AppTextField (label: 'Confirm New Password', obscure: true)
              ├── SizedBox (height: space24)
              └── AppButton (Primary)
                    label: 'Update Password'
                    onTap: _onUpdatePasswordTapped
```

### Change Password Interaction
```
Step 1: Validate all 3 fields
Step 2: New password min 8 chars
Step 3: Confirm matches new password
Step 4: Call mockAuthService.changePassword(current, new)
Step 5a: Success → close bottom sheet → SnackBar: 'Password updated successfully'
Step 5b: Wrong current password → field error: 'Your current password is incorrect'
```

### Remove Device Interaction
```
ConfirmationDialog:
  title: 'Remove Device'
  body: 'Remove this device from your account? You can pair a
         new device afterwards. This will delete all notifications
         for this device.'
  confirmLabel: 'Remove' (Destructive)
  cancelLabel: 'Cancel'
  
onConfirm:
  Step 1: Call removeDeviceCloudFunction (mock: mockDataSource.unpairDevice())
  Step 2: Clear currentSerialProvider, deviceDataProvider, notificationsProvider
  Step 3: Clear connectionTypeSeenProvider (reset to false)
  Step 4: Navigate to /serial-entry (replace entire stack)
```

### Logout Interaction
```
ConfirmationDialog:
  title: 'Log Out'
  body: 'Are you sure you want to log out?'
  confirmLabel: 'Log Out' (Primary — not destructive)
  cancelLabel: 'Cancel'

onConfirm:
  Step 1: Call mockAuthService.logout()
  Step 2: Clear all providers
  Step 3: Navigate to /serial-entry (replace entire stack)
```

### Delete Account Interaction
```
Step 1 — First Confirmation Dialog:
  title: 'Delete Account'
  body: 'Are you sure? This will permanently delete your account
         and cannot be undone.'
  confirmLabel: 'Yes, Delete My Account' (Destructive)
  cancelLabel: 'Cancel'

Step 2 — Password Confirmation Bottom Sheet:
  title: 'Confirm Your Identity'
  body: AppTextField (label: 'Enter your password', obscure: true)
  button: AppButton (Destructive, label: 'Confirm Delete')

onConfirm:
  Step 3: Call deleteAccountCloudFunction (mock: mockDataSource.deleteAccount())
  Step 4: Clear all providers
  Step 5: Navigate to /serial-entry (replace entire stack)
  HapticFeedback.mediumImpact() on destructive confirm
```

### Mock Data Bindings
```dart
MockUser:
  name: 'Test User'
  email: 'test@ohmitron.com'
  dob: DateTime(1995, 6, 15)
  uid: 'mock-uid-123'
  deviceSerial: 'OHM00123456'
```

---

## Navigation Flow Summary

```
GoRouter configuration:

initialLocation: /splash

Routes:
  /splash             → SplashScreen (redirect after 2s)
  /serial-entry       → SerialEntryScreen (root — no back)
  /auth               → AuthScreen
  /forgot-password    → ForgotPasswordScreen
  /provisioning       → ProvisioningScreen
  /connection-type    → ConnectionTypeScreen (shown once)
  /dashboard          → DashboardScreen (home after setup)
  /basic-info         → BasicInfoScreen (slide up)
  /error-report       → ErrorReportScreen (slide up)
  /notifications      → NotificationsScreen
  /account            → AccountScreen

Guards:
  /dashboard, /basic-info, /error-report, /notifications, /account:
    → redirect to /serial-entry if not authenticated
    → redirect to /serial-entry if no paired device

  /provisioning, /connection-type:
    → redirect to /dashboard if already provisioned
      and connectionTypeSeen = true
```

---

## Provider Map (All Screens)

| Provider | Type | Scope | Used By |
|----------|------|-------|---------|
| `authStateProvider` | `AsyncNotifierProvider<AuthState>` | Global | All screens |
| `pendingSerialProvider` | `StateProvider<String?>` | Global | Serial Entry, Auth |
| `currentSerialProvider` | `StateProvider<String?>` | Global | All device screens |
| `batteryStatusProvider` | `StreamProvider<BatteryStatus>` | Dashboard | Dashboard |
| `deviceInfoProvider` | `FutureProvider<DeviceInfo>` | Device screens | Basic Info, Dashboard |
| `errorsProvider` | `FutureProvider<List<ErrorEntry>>` | Error Report | Error Report |
| `notificationsProvider` | `StateNotifierProvider<List<AppNotification>>` | Notifications | Notifications, App Bar badge |
| `connectionTypeSeenProvider` | `StateProvider<bool>` | Global | Router guard |
| `mockIsLoggedInProvider` | `StateProvider<bool>` | Debug only | Auth mock |
| `mockStaleDataProvider` | `StateProvider<bool>` | Debug only | Dashboard mock |
| `unreadCountProvider` | `Provider<int>` | Global | Dashboard app bar badge |

---

*UI_UX_BLUEPRINT.md — Version 1.0*
*Read alongside FRONTEND_SKILL.md at all times.*
*Every screen must implement all states: loading, error, empty, and data.*
*No screen is complete until all states are implemented and verified.*
