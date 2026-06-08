import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// The sidebar navigation drawer.
/// Displays the current device name and primary navigation routes.
class AppDrawer extends StatelessWidget {
  /// The current active route to highlight the corresponding drawer item.
  final String currentRoute;

  const AppDrawer({super.key, this.currentRoute = '/dashboard'});

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isActive = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.brandGreen : AppColors.darkGrey,
      ),
      title: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: isActive ? AppColors.brandGreen : AppColors.black,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.brandGreen.withValues(alpha: 0.1),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        if (!isActive) {
          context.go(route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 64, // SafeArea equivalent for top
              bottom: AppSpacing.space24,
              left: AppSpacing.space24,
              right: AppSpacing.space24,
            ),
            color: AppColors.brandGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.battery_charging_full, // Placeholder for SVG logo
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.space16),
                Text(
                  'OHM-BMS-100', // Mock device name
                  style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space8),
          _buildDrawerItem(
            context: context,
            icon: Icons.home_outlined,
            title: 'Home',
            route: '/dashboard',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.info_outline,
            title: 'Basic Info',
            route: '/basic-info',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.bug_report_outlined,
            title: 'Error Report',
            route: '/error-report',
          ),
        ],
      ),
    );
  }
}
