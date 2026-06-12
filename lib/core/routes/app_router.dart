
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/account/presentation/account_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/device_setup/presentation/connection_type_screen.dart';
import '../../features/device_setup/presentation/providers/connection_type_provider.dart';
import '../../features/device_setup/presentation/serial_entry_screen.dart';
import '../../features/device_setup/presentation/provisioning_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/basic_info/presentation/basic_info_screen.dart';
import '../../features/dashboard/error_report_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/splash/splash_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Transition helpers  (TRD.md Section 6.3)
// ─────────────────────────────────────────────────────────────────────────────

/// Standard forward slide: new screen slides in from the right. 300ms.
CustomTransitionPage<void> _slideRight({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
  );
}

/// Slide up: screen slides in from the bottom (sidebar/detail screens). 350ms.
CustomTransitionPage<void> _slideUp({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
  );
}

/// Fade: used for Connection Type → Dashboard transition. 400ms.
CustomTransitionPage<void> _fade({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

/// The central router configuration for the application.
///
/// Defined by TRD.md Section 6.1, 6.2, and 6.3.
/// Step 4.1.1 — Custom page transitions on every route.
/// Step 4.2.1 — Auth and device guards.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Read auth state — if still loading, let it through (Serial Entry handles it)
      final authAsync = ref.read(authProvider);
      final isAuthenticated = authAsync.value != null;
      final hasPairedDevice = authAsync.value?.deviceSerial != null;
      final connectionTypeSeen = ref.read(connectionTypeSeenProvider);

      // ── Protected routes: require auth + paired device ────────────────────
      const protectedRoutes = [
        '/dashboard',
        '/basic-info',
        '/error-report',
        '/notifications',
        '/account',
      ];
      if (protectedRoutes.contains(location)) {
        if (!isAuthenticated) return '/serial-entry';
        if (!hasPairedDevice) return '/serial-entry';
      }

      // ── Connection Type: skip if already seen ─────────────────────────────
      if (location == '/connection-type' && connectionTypeSeen) {
        return '/dashboard';
      }

      return null; // no redirect
    },
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fade(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // ── Serial Entry — root screen, no back ────────────────────────────────
      GoRoute(
        path: '/serial-entry',
        pageBuilder: (context, state) => _slideRight(
          key: state.pageKey,
          child: const SerialEntryScreen(),
        ),
      ),

      // ── Auth ───────────────────────────────────────────────────────────────
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => _slideRight(
          key: state.pageKey,
          child: const AuthScreen(),
        ),
      ),

      // ── Forgot Password ───────────────────────────────────────────────────
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _slideRight(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),

      // ── Provisioning ──────────────────────────────────────────────────────
      GoRoute(
        path: '/provisioning',
        pageBuilder: (context, state) => _slideRight(
          key: state.pageKey,
          child: const ProvisioningScreen(),
        ),
      ),

      // ── Connection Type ───────────────────────────────────────────────────
      GoRoute(
        path: '/connection-type',
        pageBuilder: (context, state) => _slideRight(
          key: state.pageKey,
          child: const ConnectionTypeScreen(),
        ),
      ),

      // ── Dashboard — fade in from Connection Type ───────────────────────────
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _fade(
          key: state.pageKey,
          child: const DashboardScreen(),
        ),
      ),

      // ── Basic Info — slide up (sidebar/detail) ────────────────────────────
      GoRoute(
        path: '/basic-info',
        pageBuilder: (context, state) => _slideUp(
          key: state.pageKey,
          child: const BasicInfoScreen(),
        ),
      ),

      // ── Error Report — slide up (sidebar/detail) ──────────────────────────
      GoRoute(
        path: '/error-report',
        pageBuilder: (context, state) => _slideUp(
          key: state.pageKey,
          child: const ErrorReportScreen(),
        ),
      ),

      // ── Notifications — forward slide ─────────────────────────────────────
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _slideRight(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),

      // ── Account — forward slide ───────────────────────────────────────────
      GoRoute(
        path: '/account',
        pageBuilder: (context, state) => _slideRight(
          key: state.pageKey,
          child: const AccountScreen(),
        ),
      ),
    ],
  );
});
