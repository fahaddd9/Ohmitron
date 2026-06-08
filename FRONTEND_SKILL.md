# FRONTEND_SKILL.md
## Ohmitron Battery App — Design System & Aesthetic Manifesto
### Version 1.0 | Approved for Production

---

> This document is the aesthetic DNA of the Ohmitron app. It is not a checklist.
> It is a philosophy — translated into precise, actionable rules.
> Every screen, every widget, every animation must pass through the lens of this document.
> When in doubt, come back here. The answer is always here.

---

## 1. Design Philosophy

The Ohmitron app monitors something physical, real, and important — a battery that powers equipment people depend on. The design must reflect that gravity without becoming heavy. It must communicate precision without becoming cold. It must be beautiful without ever being decorative.

Four principles govern every single decision in this app:

### 1.1 Clarity is the highest form of design
Every element on screen earns its place by communicating something. If a shadow, a border, a gradient, or an animation does not help the user understand something faster or feel something more clearly — it does not exist. This is not minimalism for aesthetic reasons. It is minimalism as a functional commitment. The user opens this app to check on their battery. Get out of their way.

### 1.2 Data is the hero
The numbers — state of charge, temperature, remaining time, protection status — are the reason this app exists. Typography, colour, spacing, and layout exist to make those numbers as readable, as immediate, and as meaningful as possible. Never let chrome compete with content. The UI is the frame. The data is the painting.

### 1.3 Motion has meaning
Every animation in this app communicates something. The battery gauge filling communicates level. The pulse animation communicates charging activity. The slide transition communicates direction and hierarchy. Animation that exists only to look impressive is noise. Animation that tells the user where they are, what just happened, or what is about to change is essential. Every animation must pass this test: what does this communicate?

### 1.4 Trust is built through consistency
A user who opens this app 200 times over two years should never be surprised by the interface. Every button looks the same. Every error message follows the same pattern. Every loading state behaves the same way. Consistency is not creative limitation — it is the foundation of user trust. A monitoring app that behaves unpredictably destroys confidence in the data it displays.

---

## 2. Colour System

The colour system is built on restraint. Brand green appears sparingly — as signal, not decoration. The palette is intentionally limited. Adding colours not defined here is not permitted.

### 2.1 Complete Colour Palette

| Token Name | Hex | RGB | Usage |
|-----------|-----|-----|-------|
| `colorBrandGreen` | `#3DAE2B` | 61, 174, 43 | Primary actions, active states, SOC gauge fill (high), success states, brand accent |
| `colorBlack` | `#000000` | 0, 0, 0 | Primary text, primary icons |
| `colorDarkGrey` | `#333333` | 51, 51, 51 | Secondary text, labels, subtitles |
| `colorBackground` | `#F7F8FA` | 247, 248, 250 | Every screen background — off-white, not pure white |
| `colorSurface` | `#FFFFFF` | 255, 255, 255 | Cards, input fields, sidebar background content areas |
| `colorDivider` | `#E8E8E8` | 232, 232, 232 | Dividers, input field borders, list separators, card borders |
| `colorDisabled` | `#BBBBBB` | 187, 187, 187 | Disabled button text, placeholder text, inactive icons |
| `colorErrorRed` | `#E53935` | 229, 57, 53 | Error messages, critical severity badge, destructive action buttons, battery gauge (critical low) |
| `colorWarningAmber` | `#F59E0B` | 245, 158, 11 | Stale data banner, warning severity badge, battery gauge (medium charge) |
| `colorInfoBlue` | `#3B82F6` | 59, 130, 246 | Info severity badge on Error Report and Notifications |
| `colorSidebarBackground` | `#F0F0F0` | 240, 240, 240 | Sidebar/drawer background |
| `colorScrim` | `#000000` at 40% opacity | — | Modal and drawer overlay behind content |

### 2.2 Colour Usage Rules

**Brand green `#3DAE2B` is used for:**
- Primary buttons (background)
- Active navigation indicators
- SOC gauge fill when charge > 40%
- Charging pulse animation
- Checkboxes and toggles when active
- Success state icons and messages
- The SET button on Basic Info screen
- "Continue" and "Send Reset Link" buttons

**Brand green is never used for:**
- Background of any screen or card
- Text (except on dark backgrounds where it appears as an icon label)
- Decorative elements with no functional meaning
- More than one element per visual group (avoid green overload)

**Error Red `#E53935` is used for:**
- Inline form validation error messages
- Critical severity badges
- Destructive action buttons (Delete Account, Remove Device confirm button)
- Battery gauge fill when SOC < 20%
- Protection state active indicator

**Warning Amber `#F59E0B` is used for:**
- Stale data banner background (at 15% opacity) with amber text and icon
- Warning severity badges
- Battery gauge fill when SOC 20%–40%

**Black `#000000` is used for:**
- All primary body text
- Screen titles and headings
- Primary navigation icons
- The Ohmitron wordmark

**Never use pure black as a background.** Never use pure white `#FFFFFF` as a screen background — always use `#F7F8FA`.

### 2.3 Colour Accessibility
All text-on-background combinations must meet WCAG 2.1 AA contrast ratio of 4.5:1 minimum.
- Black `#000000` on `#F7F8FA` — contrast ratio 19.6:1 ✅
- Dark Grey `#333333` on `#F7F8FA` — contrast ratio 10.7:1 ✅
- White `#FFFFFF` on Brand Green `#3DAE2B` — contrast ratio 3.2:1 — use only for button text at 16sp+ Bold ✅
- Never place `#BBBBBB` text on `#F7F8FA` for meaningful content — disabled only

---

## 3. Typography System

Typography in this app does one job: make data immediately readable. Inter was chosen because it is the finest screen-optimised typeface available. Its geometric construction gives numbers exceptional clarity at every size. Its letterforms are neutral enough to disappear behind content. Its extensive weight range allows a complete typographic hierarchy with a single typeface family.

### 3.1 Font Family
```
Primary: Inter
Weights used: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
Source: Google Fonts — inter
Flutter package: google_fonts
```

No other typeface is used anywhere in the app. The Ohmitron wordmark uses Arial Bold in the SVG logo asset — this is a brand asset, not a UI font, and is never replicated in Flutter text widgets.

### 3.2 Complete Type Scale

| Token | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| `displayLarge` | 48sp | 700 Bold | 56sp | -1.5px | SOC percentage hero number on Dashboard |
| `displayMedium` | 36sp | 700 Bold | 44sp | -1.0px | Remaining time hero value |
| `displaySmall` | 28sp | 600 SemiBold | 36sp | -0.5px | Large metric values |
| `headlineLarge` | 24sp | 700 Bold | 32sp | -0.5px | Screen titles in app bar |
| `headlineMedium` | 20sp | 600 SemiBold | 28sp | 0px | Section headers, card titles |
| `headlineSmall` | 18sp | 600 SemiBold | 26sp | 0px | Subsection headers |
| `bodyLarge` | 16sp | 400 Regular | 24sp | 0px | Primary body text, form field input text |
| `bodyMedium` | 14sp | 400 Regular | 20sp | 0px | Secondary body text, descriptions |
| `bodySmall` | 12sp | 400 Regular | 16sp | 0.2px | Captions, timestamps, helper text |
| `labelLarge` | 16sp | 600 SemiBold | 24sp | 0.1px | Button text, primary labels |
| `labelMedium` | 14sp | 500 Medium | 20sp | 0.1px | Badge text, chip text, tab labels |
| `labelSmall` | 12sp | 500 Medium | 16sp | 0.4px | Micro labels, status indicators |

### 3.3 Typography Rules

**Numbers are always Bold or SemiBold.** Data values — SOC percentage, temperature, voltage, remaining time — are displayed at the largest legible size for their context with minimum 600 weight. Numbers must never be Regular weight. A Regular weight number communicates uncertainty. A Bold number communicates fact.

**Units are always one size smaller than their value.** If the temperature value is `displaySmall` (28sp), the "°C" unit label is `headlineSmall` (18sp) in Dark Grey `#333333`. This creates visual hierarchy that guides the eye to the number first, then the context.

**Never use italic.** This app displays monitoring data. Italic implies emphasis or quotation. Neither belongs here.

**Never use more than 3 type sizes on a single screen.** If you need a fourth size to solve a layout problem, the layout is the problem — not the type scale.

**Line length maximum: 72 characters.** Body text that spans more than 72 characters per line becomes difficult to read. Wrap or restructure.

---

## 4. Spacing System

All spacing in this app is based on a **4px base unit**. Every padding, margin, gap, and size is a multiple of 4. No exceptions. A spacing value that is not a multiple of 4 indicates an error in implementation.

### 4.1 Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `space2` | 2px | Micro gaps — icon to label, badge internal padding |
| `space4` | 4px | Tight internal padding — chip padding, small icon margins |
| `space8` | 8px | Standard internal padding — button vertical padding, small gaps |
| `space12` | 12px | Form field internal padding, list item vertical padding |
| `space16` | 16px | Standard horizontal screen padding, card internal padding |
| `space20` | 20px | Section gaps, larger card padding |
| `space24` | 24px | Between sections on screen |
| `space32` | 32px | Major section separation |
| `space48` | 48px | Hero element separation (battery gauge to stats grid) |
| `space64` | 64px | Full-section breathing room |

### 4.2 Screen Padding
Every screen uses **16px horizontal padding** on both sides. This is the standard content boundary. No content touches the screen edge.

The only exceptions:
- The animated battery gauge on Dashboard — extends to 24px from each edge for visual impact
- Full-width buttons — extend to 16px from each edge (padding is within the button itself)
- Dividers — extend full width with no horizontal padding

### 4.3 Component Sizing

| Component | Height | Border Radius | Notes |
|-----------|--------|---------------|-------|
| Primary Button | 52px | 12px | Full width in forms, auto-width in app bar contexts |
| Secondary Button | 48px | 12px | Outlined, brand green border |
| Destructive Button | 52px | 12px | Error red background |
| Text Input Field | 56px | 12px | Includes label above field |
| App Bar | 56px | 0px | Standard Material app bar height |
| Bottom of app bar to first content | 24px | — | Breathing room below app bar |
| List Item (standard) | 64px minimum | 0px | Taller if content requires |
| Card | Auto height | 16px | Minimum 16px internal padding |
| Badge/Chip | 28px height | 100px (pill) | Auto width based on content |
| Sidebar/Drawer width | 280px | 0px right edge | Standard drawer width |
| Confirmation Dialog | Auto height | 20px | Max width 320px |

---

## 5. Component Library

Every reusable component is defined here. The agent builds exactly these components in Phase 2. No component is invented during screen construction — if it is not here, it does not exist yet and must be added to this document first.

### 5.1 AppButton

Three variants. One widget with a `variant` parameter.

**Primary Button**
- Background: `colorBrandGreen`
- Text: White `#FFFFFF`, `labelLarge` (16sp SemiBold)
- Height: 52px, Border Radius: 12px, Full width
- Padding: 16px horizontal, 14px vertical
- Loading state: Replace text with `CircularProgressIndicator` (white, size 20px, strokeWidth 2px)
- Disabled state: Background `colorDisabled`, text white
- Tap feedback: Scale down to 0.97 on press, scale back on release (duration 100ms)
- Ripple: Disabled — scale animation replaces ripple entirely

**Secondary Button**
- Background: Transparent
- Border: 1.5px solid `colorBrandGreen`
- Text: `colorBrandGreen`, `labelLarge` (16sp SemiBold)
- Height: 48px, Border Radius: 12px
- Same loading, disabled, and tap feedback as Primary

**Destructive Button**
- Background: `colorErrorRed`
- Text: White, `labelLarge` (16sp SemiBold)
- Height: 52px, Border Radius: 12px
- Same loading, disabled, and tap feedback as Primary
- Used only in confirmation dialogs for irreversible actions

### 5.2 AppTextField

Single widget with validation support.

- Height: 56px (label + field combined)
- Label: `labelMedium` (14sp Medium) in `colorDarkGrey`, sits above the field
- Input text: `bodyLarge` (16sp Regular) in `colorBlack`
- Border: 1.5px solid `colorDivider` at rest
- Border focused: 1.5px solid `colorBrandGreen` — animates over 200ms
- Border error: 1.5px solid `colorErrorRed`
- Background: `colorSurface` white
- Border radius: 12px
- Error message: `bodySmall` (12sp) in `colorErrorRed`, appears below field with fade-in animation (150ms)
- Password fields: suffix icon for show/hide — eye icon, `colorDarkGrey`
- Placeholder text: `colorDisabled`

### 5.3 AppBadge

Coloured pill badge for status display.

- Height: 28px, Border Radius: 100px (full pill)
- Padding: 8px horizontal, 4px vertical
- Text: `labelMedium` (14sp Medium) in white
- Variants by colour:
  - Green (`colorBrandGreen`): Active, Normal, Protected states
  - Red (`colorErrorRed`): Critical, Protection Active states
  - Amber (`colorWarningAmber`): Warning states, Balancing
  - Blue (`colorInfoBlue`): Info states, Inactive
  - Grey (`colorDisabled` background, `colorDarkGrey` text): Unknown, None states

### 5.4 SeverityChip

Used exclusively in Error Report and Notifications for severity labelling.

- Same dimensions as AppBadge
- Three fixed variants: `info` (blue), `warning` (amber), `critical` (red)
- Text is always the capitalised severity name: "Info", "Warning", "Critical"

### 5.5 LoadingIndicator

Two variants:

**Full Screen Loading**
- Centred vertically and horizontally on screen
- `CircularProgressIndicator` in `colorBrandGreen`, strokeWidth 3px, size 40px
- Subtle fade-in animation (200ms) to prevent flash on fast loads
- Optional label below: `bodyMedium` in `colorDarkGrey` (e.g., "Loading your battery data…")

**Inline Loading**
- `CircularProgressIndicator` in `colorBrandGreen`, strokeWidth 2px, size 20px
- Used inside buttons during async operations
- Used in list headers when refreshing

### 5.6 EmptyStateWidget

Used when a list has no items to display.

- Centred vertically and horizontally in its container
- Icon: Relevant outlined icon in `colorDisabled`, size 64px
- Title: `headlineSmall` (18sp SemiBold) in `colorDarkGrey`
- Subtitle: `bodyMedium` (14sp Regular) in `colorDisabled`
- No button unless the empty state has a clear action
- Fade-in animation: 300ms ease-out
- Example: Error Report empty — icon: `check_circle_outline`, title: "No Errors Recorded", subtitle: "Your battery is running normally"

### 5.7 ConfirmationDialog

Used for all destructive or irreversible actions.

- Max width: 320px, Border Radius: 20px
- Background: `colorSurface` white
- Title: `headlineMedium` (20sp SemiBold) in `colorBlack`
- Body: `bodyMedium` (14sp Regular) in `colorDarkGrey`
- Button row: Cancel (Secondary variant) left, Confirm (Primary or Destructive) right
- Appears with: fade + scale from 0.92 to 1.0, duration 250ms, curve `easeOutCubic`
- Dismisses with: fade + scale from 1.0 to 0.92, duration 200ms
- Background scrim: `colorScrim` (black at 40% opacity), animated fade-in 200ms

### 5.8 StaleDataBanner

Appears on Dashboard when `lastTelemetry` is more than 45 seconds old.

- Full width, no horizontal margin
- Background: `colorWarningAmber` at 15% opacity (`#FEF3C7` effectively)
- Left border accent: 4px solid `colorWarningAmber`
- Icon: `warning_amber_rounded` in `colorWarningAmber`, size 20px
- Primary text: "Data Stale — Device may be offline" — `labelMedium` (14sp Medium) in `colorBlack`
- Secondary text: "Last updated: [timestamp]" — `bodySmall` (12sp Regular) in `colorDarkGrey`
- Appears with: slide down from top + fade-in, duration 300ms, curve `easeOutCubic`
- Dismisses automatically when fresh data arrives: slide up + fade-out, duration 250ms
- Never manually dismissible by the user

### 5.9 AppErrorWidget

Full-screen error state for when a screen fails to load entirely.

- Centred vertically and horizontally
- Icon: `error_outline` in `colorErrorRed`, size 56px
- Title: `headlineSmall` (18sp SemiBold) in `colorBlack`
- Subtitle: `bodyMedium` (14sp Regular) in `colorDarkGrey`
- Retry button: Primary variant, auto-width, centred
- Fade-in animation: 300ms

### 5.10 AnimatedBatteryGauge

The hero widget of the Dashboard. This is the most important widget in the app.

**Structure:**
- Outer shell: Rectangular battery shape with rounded corners (16px radius)
- Battery terminal: Small rounded rectangle on the right end of the battery (8px wide, 20px tall, centred vertically)
- Shell border: 2.5px solid `colorDivider`
- Fill: Animated coloured rectangle inside the shell, fills left to right
- SOC percentage: `displayLarge` (48sp Bold) centred inside the battery
- "Charged" label: `labelSmall` (12sp Medium) below the percentage in `colorDarkGrey`

**Fill colour transitions (animated, not stepped):**
- SOC > 40%: `colorBrandGreen` `#3DAE2B`
- SOC 20%–40%: `colorWarningAmber` `#F59E0B`
- SOC < 20%: `colorErrorRed` `#E53935`
- Colour transition: `AnimatedContainer` with duration 600ms, curve `easeInOut`

**Fill animation:**
- On first load: Fill animates from 0% to actual SOC value over 1200ms, curve `easeOutCubic`
- On data update: Fill animates from current to new value over 800ms, curve `easeInOut`

**Charging pulse animation:**
- When `isCharging = true`: The fill has a repeating shimmer/pulse animation
- Implementation: `AnimationController` repeating, opacity pulses from 1.0 to 0.7 over 1000ms, curve `easeInOut`, reverses and repeats
- A small lightning bolt icon `bolt` in white appears centred on the fill when charging

**Dimensions:**
- Width: Screen width minus 32px (16px padding each side)
- Height: 160px
- This widget is never used at a different size

### 5.11 ErrorListItem

Single item in the Error Report list.

- Height: 80px minimum (taller if message wraps)
- Padding: 16px horizontal, 12px vertical
- Layout: SeverityChip top-left, error code bold next to it, timestamp top-right, message below in `bodyMedium`
- Divider: `colorDivider` 1px at bottom of each item
- No tap action in V1 (read-only)

### 5.12 NotificationListItem

Single item in the Notifications list.

- Height: 72px minimum
- Padding: 16px horizontal, 12px vertical
- Unread indicator: 8px filled circle in `colorBrandGreen`, left side, vertically centred
- Layout: Title in `labelMedium` (14sp Medium), body in `bodySmall` (12sp Regular) below, timestamp top-right in `bodySmall` `colorDisabled`
- Swipe left to reveal delete action: Red background with trash icon, width 80px
- On tap: Mark as read (unread indicator disappears with fade-out 200ms)
- Divider: `colorDivider` 1px at bottom

### 5.13 SectionHeader

Used in Basic Info and Account screens to separate content groups.

- Text: `headlineSmall` (18sp SemiBold) in `colorBlack`
- Padding: 16px horizontal, 20px top, 8px bottom
- No background — sits directly on screen background
- No divider above (breathing room is provided by spacing)

### 5.14 InfoRow

Used in Basic Info screen for read-only field display.

- Height: 56px
- Padding: 16px horizontal, 12px vertical
- Label: `bodySmall` (12sp Regular) in `colorDarkGrey`, above value
- Value: `bodyLarge` (16sp Regular) in `colorBlack`
- Divider: `colorDivider` 1px at bottom
- No tap interaction

### 5.15 DeviceNameHeader

Displays the current device's friendly name. Used in Dashboard app bar centre.

- Text: `headlineLarge` (24sp Bold) in `colorBlack`
- Truncates with ellipsis at 20 characters if name is long
- No tap interaction in V1

---

## 6. Animation System

Animation in this app is purposeful, physics-based, and always meaningful. Every duration and curve defined here is non-negotiable. Consistency in motion is as important as consistency in colour.

### 6.1 Duration Scale

| Token | Duration | Usage |
|-------|----------|-------|
| `durationInstant` | 100ms | Button press scale, immediate feedback |
| `durationFast` | 150ms | Error message fade-in, badge colour change |
| `durationNormal` | 200ms | Input field border colour, icon state change, dialog scrim |
| `durationMedium` | 250ms | Dialog appear/dismiss, banner dismiss |
| `durationSlow` | 300ms | Screen element fade-in, banner appear, empty state appear |
| `durationExpressive` | 600ms | Battery fill colour transition |
| `durationHero` | 800ms | Battery fill level update animation |
| `durationEntrance` | 1200ms | Battery fill entrance animation on first load |

### 6.2 Animation Curves

| Token | Curve | Usage |
|-------|-------|-------|
| `curveStandard` | `Curves.easeInOut` | General state transitions |
| `curveDecelerate` | `Curves.easeOutCubic` | Elements entering the screen |
| `curveAccelerate` | `Curves.easeInCubic` | Elements leaving the screen |
| `curveSharp` | `Curves.easeOut` | Quick feedback animations |
| `curveSpring` | `Curves.elasticOut` | Never used — too playful for this app's tone |
| `curveBounce` | `Curves.bounceOut` | Never used — too playful for this app's tone |

### 6.3 Screen Transition Rules

Screen transitions communicate spatial hierarchy. Every transition type is defined and must be used exactly as specified.

**Forward navigation (pushing a new screen):**
- New screen slides in from the right (translateX from +100% to 0)
- Previous screen slides out to the left (translateX from 0 to -30%)
- Duration: 300ms, curve `easeOutCubic`
- Used for: Serial Entry → Login, Login → Dashboard (after Connection Type), all standard push navigations

**Back navigation (popping a screen):**
- Current screen slides out to the right (translateX from 0 to +100%)
- Previous screen slides in from the left (translateX from -30% to 0)
- Duration: 250ms, curve `easeInCubic`

**Sidebar screens (Basic Info, Error Report):**
- Screen slides up from bottom (translateY from +100% to 0)
- Duration: 350ms, curve `easeOutCubic`
- Dismisses by sliding back down: 300ms, curve `easeInCubic`

**Modals and dialogs:**
- Background scrim fades in: 200ms `easeInOut`
- Dialog scales from 0.92 + fades in: 250ms `easeOutCubic`
- Dismisses: scale to 0.92 + fade out: 200ms `easeInCubic`

**Forgot Password stepper steps:**
- Forward (next step): Content slides left (translateX from 0 to -100%), new content slides in from right (+100% to 0)
- Backward (previous step): Content slides right (translateX from 0 to +100%), previous content slides in from left (-100% to 0)
- Duration: 300ms, curve `easeOutCubic`

**Connection Type → Dashboard (one-time only):**
- Fade transition only — no slide
- Duration: 400ms, curve `easeInOut`
- This transition feels like "arriving" not "navigating"

### 6.4 Micro-animation Rules

**Button press:**
- Scale: 1.0 → 0.97 on press down (100ms `easeOut`)
- Scale: 0.97 → 1.0 on release (100ms `easeOut`)
- No ripple effect — scale replaces ripple entirely

**Input field focus:**
- Border colour animates from `colorDivider` to `colorBrandGreen`: 200ms `easeInOut`
- No other visual change

**List item swipe (Notifications delete):**
- Swipe threshold: 40% of item width to reveal action
- Red background reveals progressively as user swipes
- Snap to revealed or snap back: 200ms spring physics

**Pull to refresh:**
- Standard Flutter `RefreshIndicator` with `colorBrandGreen`
- No custom animation — keep it native and familiar

**Stale banner appear/dismiss:**
- Appear: Slide down from 0 height to full height + fade in: 300ms `easeOutCubic`
- Dismiss: Slide up to 0 height + fade out: 250ms `easeInCubic`

**Unread notification dot dismiss:**
- Fade out: 200ms `easeInOut` when notification is tapped

### 6.5 What is Never Animated
- Screen background colour
- Text content (no typewriter effects, no text fade between values)
- Icons switching state (instant swap — not animated)
- List reordering
- Anything that makes the user wait for animation to complete before interacting

---

## 7. Iconography

### 7.1 Icon Library
Use **Material Symbols** (outlined variant) exclusively. Never mix outlined and filled variants on the same screen. Never use custom icon assets unless the Material Symbols library does not have an equivalent.

### 7.2 Icon Sizes

| Context | Size | Usage |
|---------|------|-------|
| App bar icons | 24px | Share, Notifications, Account, Hamburger |
| Sidebar icons | 24px | Home, Basic Info, Error Report |
| List item icons | 20px | InfoRow leading icons, notification icons |
| Status icons | 16px | Inline status indicators within text |
| Empty state icons | 64px | EmptyStateWidget centred illustration |
| Error state icons | 56px | AppErrorWidget centred icon |
| Battery terminal | — | Custom drawn, not an icon |

### 7.3 Icon Colour Rules
- Navigation icons (active): `colorBrandGreen`
- Navigation icons (inactive): `colorDisabled`
- Action icons (app bar): `colorBlack`
- Status icons: Match their status colour (green, red, amber, blue)
- Decorative icons (empty state, error state): `colorDisabled`

### 7.4 Specific Icon Assignments

| Icon | Material Symbol | Usage |
|------|----------------|-------|
| Hamburger menu | `menu` | App bar left |
| Share/Screenshot | `photo_camera` | App bar right |
| Notifications | `notifications` | App bar right |
| Account | `person` | App bar right |
| Home | `home` | Sidebar |
| Basic Information | `info` | Sidebar |
| Error Report | `warning` | Sidebar |
| Charging | `bolt` | Dashboard charging state |
| Discharging | `battery_5_bar` | Dashboard discharging state |
| Temperature | `device_thermostat` | Dashboard temperature |
| Balance | `balance` | Dashboard balance state |
| Protection | `shield` | Dashboard protection state |
| Delete/Remove | `delete` | Swipe action, destructive buttons |
| Edit/SET | `edit` | Device name field |
| Back arrow | `arrow_back` | Secondary screen app bars |
| Check/Success | `check_circle` | Success states |
| Warning | `warning_amber` | Stale banner, warning states |
| Error | `error_outline` | Error states |
| Barcode | Rendered via `barcode_widget` package | Basic Info screen |

---

## 8. Interaction Design Rules

### 8.1 Touch Targets
Every tappable element must be at least **48×48px** in touch target size, even if the visual element is smaller. Use padding to extend the touch target without changing the visual size.

### 8.2 Loading States
Every async operation must show a loading state. There is no exception to this rule. A user must never tap a button and see nothing happen. Loading states:
- Button loading: Replace button text with inline `LoadingIndicator`
- Screen loading: `LoadingIndicator` full screen variant
- List refresh: `RefreshIndicator` with `colorBrandGreen`
- Partial refresh (background): No visual indicator — happens silently

### 8.3 Error States
Every async operation must handle its error state. There is no exception. Error states:
- Form validation: Inline error below the field (AppTextField error state)
- Screen load failure: `AppErrorWidget` full screen with retry
- Action failure (button tap): Show a `SnackBar` with error message in `colorErrorRed`
- Network loss: `StaleDataBanner` on Dashboard; `SnackBar` on other screens

### 8.4 Empty States
Every list must handle its empty state. There is no exception. Use `EmptyStateWidget` with context-appropriate icon, title, and subtitle.

### 8.5 Haptic Feedback
- Primary button tap: `HapticFeedback.lightImpact()`
- Destructive action confirm: `HapticFeedback.mediumImpact()`
- Error state triggered: `HapticFeedback.vibrate()`
- Success state: `HapticFeedback.selectionClick()`

### 8.6 Keyboard Behaviour
- On any screen with a text input, tapping outside the input dismisses the keyboard
- The screen does not resize when the keyboard appears — use `resizeToAvoidBottomInset: false` and scroll the content instead
- "Next" keyboard action moves focus to the next field in form order
- "Done" or "Send" keyboard action triggers the primary form action

---

## 9. Sidebar / Drawer Design

The sidebar is the primary navigation mechanism beyond the app bar.

- Width: 280px
- Background: `colorSidebarBackground` `#F0F0F0`
- Opens with: slide in from left, 300ms `easeOutCubic`
- Closes with: slide out to left, 250ms `easeInCubic`
- Scrim: `colorScrim` (black 40% opacity), tapping scrim closes drawer

**Drawer header:**
- Height: 160px
- Background: `colorBrandGreen`
- Ohmitron logo (SVG asset) centred, white tinted, size 48px
- App name "Ohmitron" below logo: `headlineMedium` (20sp SemiBold) in white
- Device name below app name: `bodyMedium` (14sp Regular) in white at 80% opacity

**Navigation items:**
- Height: 56px each
- Padding: 16px horizontal
- Icon: 24px, left side
- Label: `labelLarge` (16sp SemiBold)
- Active state: `colorBrandGreen` icon, `colorBrandGreen` text, light green background at 10% opacity (`#3DAE2B1A`)
- Inactive state: `colorDarkGrey` icon and text
- No dividers between items
- Tap feedback: Scale 0.98, duration 100ms

**Items in order:**
1. Home (Dashboard)
2. Basic Information
3. Error Report

---

## 10. Forms and Validation

### 10.1 Validation Timing
- Validate on blur (when user leaves a field) — never on every keystroke
- Validate all fields on form submission
- Show the first error only — not all errors simultaneously
- Clear error when user starts typing again

### 10.2 Form Layout Rules
- Label above field — never placeholder-as-label (placeholder disappears on type)
- 16px gap between each field
- 24px gap between last field and submit button
- Group related fields with a `SectionHeader`

### 10.3 Password Fields
- Always obscured by default
- Show/hide toggle icon on right side (`visibility` / `visibility_off`)
- Minimum 8 characters — show requirement as helper text below field before any error

---

## 11. Do's and Don'ts

### ✅ Always Do
- Use colour tokens — never hardcode hex values in widget code
- Use spacing tokens — never hardcode pixel values
- Use the defined type scale — never set arbitrary font sizes
- Add loading, error, and empty states to every async operation
- Use `HapticFeedback` for all interactive elements
- Follow the animation duration and curve definitions exactly
- Use `AppButton`, `AppTextField`, and other reusable widgets — never rebuild them inline
- Test every screen on a small screen (360px wide) and a large screen (414px wide)

### ❌ Never Do
- Never use `Colors.green` — always use `colorBrandGreen`
- Never use `Colors.white` as a screen background — always use `colorBackground`
- Never use `StatefulWidget` — always use `ConsumerWidget` with Riverpod
- Never hardcode strings — use the constants file
- Never use `Curves.elasticOut` or `Curves.bounceOut` — too playful for this app
- Never animate text content directly — swap values instantly
- Never show raw error messages, Firebase error codes, or stack traces to the user
- Never place more than 3 interactive elements in the app bar
- Never use more than 2 font weights on a single screen
- Never add a colour not in the defined palette without updating this document first
- Never skip the loading state because "it loads fast enough" — network conditions vary

---

## 12. Asset References

| Asset | Path | Format | Usage |
|-------|------|--------|-------|
| Ohmitron Logo | `assets/images/ohmitron_logo.svg` | SVG | Splash screen, sidebar header |
| Ohmitron Logo (white) | `assets/images/ohmitron_logo_white.svg` | SVG | Sidebar header (tinted white) |
| Inter Font | Via `google_fonts` package | TTF | All text throughout app |

All SVG assets are rendered using `flutter_svg` package (`SvgPicture.asset()`). Never convert SVGs to PNG — they must remain vector for all screen densities.

---

*FRONTEND_SKILL.md — Version 1.0*
*This document is the single source of truth for all visual and interaction decisions.*
*No design decision that contradicts this document is valid.*
*Update this document first — then update the code.*
