import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/dashboard_provider.dart';
import '../providers/unread_count_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// The top app bar for the dashboard screen.
/// Implements the header from Blueprint Section 7.
class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.black), // Colours hamburger
      centerTitle: true,
      title: Text(
        'OHM-BMS-100', // Mock device name, will be dynamic later
        style: AppTextStyles.headlineLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.black),
          onPressed: () {
            final batteryAsync = ref.read(dashboardProvider);
            batteryAsync.whenData((status) {
              final state = status.current > 0 ? 'Charging' : (status.current < 0 ? 'Discharging' : 'Idle');
              final shareText = 'Ohmipower BMS: ${(status.stateOfCharge ?? 0).toStringAsFixed(1)}% SOC, '
                  '${status.voltage.toStringAsFixed(1)}V, $state';
              Share.share(shareText);
            });
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.black),
              onPressed: () {
                context.push('/notifications');
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.errorRed,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.black),
          onPressed: () {
            context.push('/account');
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
