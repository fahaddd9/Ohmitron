
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/account/account_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/device_setup/presentation/connection_type_screen.dart';
import '../../features/device_setup/presentation/providers/connection_type_provider.dart';
import '../../features/device_setup/presentation/serial_entry_screen.dart';
import '../../features/device_setup/presentation/provisioning_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/basic_info/presentation/basic_info_screen.dart';
import '../../features/dashboard/error_report_screen.dart';
import '../../features/dashboard/notifications_screen.dart';
import '../../features/splash/splash_screen.dart';

/// The central router configuration for the application.
/// 
/// Defined by TRD.md Section 6.1 and 6.2.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/error-report',
    // Keeping guard simple for Step 1.6.1 as auth is not wired yet
    redirect: (context, state) {
      final connectionTypeSeen = ref.read(connectionTypeSeenProvider);
      if (state.matchedLocation == '/connection-type' && connectionTypeSeen) {
        return '/dashboard';
      }
      return null; 
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/serial-entry',
        builder: (context, state) => const SerialEntryScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/connection-type',
        builder: (context, state) => const ConnectionTypeScreen(),
      ),
      GoRoute(
        path: '/provisioning',
        builder: (context, state) => const ProvisioningScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/basic-info',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const BasicInfoScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      GoRoute(
        path: '/error-report',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ErrorReportScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
    ],
  );
});
