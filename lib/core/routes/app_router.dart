
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/account/account_screen.dart';
import '../../features/auth/connection_type_screen.dart';
import '../../features/auth/serial_entry_screen.dart';
import '../../features/dashboard/basic_info_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/dashboard/error_report_screen.dart';
import '../../features/dashboard/notifications_screen.dart';
import '../../features/splash/splash_screen.dart';

/// The central router configuration for the application.
/// 
/// Defined by TRD.md Section 6.1 and 6.2.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    // Keeping guard simple for Step 1.6.1 as auth is not wired yet
    redirect: (context, state) {
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
        path: '/connection-type',
        builder: (context, state) => const ConnectionTypeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/basic-info',
        builder: (context, state) => const BasicInfoScreen(),
      ),
      GoRoute(
        path: '/error-report',
        builder: (context, state) => const ErrorReportScreen(),
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
