import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/info_row.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/stale_data_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/app_drawer.dart';
import 'widgets/dashboard_app_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatStaleTime(DateTime time) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[time.month - 1];
    final h = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$m ${time.day}, ${time.year} - $h:$min';
  }

  Widget _buildStateBadge(double current) {
    if (current > 0) {
      return const AppBadge(label: 'Charging', variant: AppBadgeVariant.green);
    } else if (current < 0) {
      return const AppBadge(label: 'Discharging', variant: AppBadgeVariant.amber);
    } else {
      return const AppBadge(label: 'Idle', variant: AppBadgeVariant.grey);
    }
  }

  String _formatTimeRemaining(double? hours) {
    if (hours == null || hours <= 0) return 'Calculating...';
    if (hours > 100) return '100+ hrs';
    
    final int h = hours.floor();
    final int m = ((hours - h) * 60).round();
    
    if (h == 0) return '$m min';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryAsync = ref.watch(dashboardProvider);
    final isStale = ref.watch(isDataStaleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DashboardAppBar(),
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: Center(
        child: batteryAsync.when(
          loading: () => const LoadingIndicator.fullScreen(label: 'Connecting to BMS...'),
          error: (err, stack) => Text('Error: $err', style: const TextStyle(color: AppColors.errorRed)),
          data: (status) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.space16),
              children: [
                StaleDataBanner(
                  isVisible: isStale,
                  lastUpdated: _formatStaleTime(status.timestamp.toLocal()),
                ),
                if (isStale) const SizedBox(height: AppSpacing.space16),
                // Battery Gauge
                Center(
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: ProgressRing(
                      percentage: status.stateOfCharge ?? 0.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(status.stateOfCharge ?? 0.0).toStringAsFixed(1)}%',
                            style: AppTextStyles.displayMedium.copyWith(color: AppColors.black),
                          ),
                          Text(
                            'SOC',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.darkGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space32),
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.electrical_services,
                        label: 'Voltage',
                        value: status.voltage.toStringAsFixed(2),
                        unit: 'V',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: StatCard(
                        icon: Icons.speed,
                        label: 'Current',
                        value: status.current.toStringAsFixed(2),
                        unit: 'A',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.thermostat,
                        label: 'Temperature',
                        value: status.temperatureCelsius.toStringAsFixed(1),
                        unit: '°C',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: StatCard(
                        icon: Icons.bolt,
                        label: 'Power',
                        value: (status.voltage * status.current).abs().toStringAsFixed(0),
                        unit: 'W',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space24),
                // Status Section Header
                Text('System Status', style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppSpacing.space16),
                
                // Status Section Content
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Current State', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey)),
                          _buildStateBadge(status.current),
                        ],
                      ),
                      const Divider(height: AppSpacing.space24, color: AppColors.divider),
                      InfoRow(
                        label: 'Time Remaining',
                        value: _formatTimeRemaining(status.remainingTimeHours),
                      ),
                      const Divider(height: AppSpacing.space24, color: AppColors.divider),
                      const InfoRow(
                        label: 'Cycle Count',
                        value: '142', // Mock static
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.space24),
                // Error Summary Row
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/error-report'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.space16),
                      child: Row(
                        children: [
                          const AppBadge(label: '1', variant: AppBadgeVariant.red),
                          const SizedBox(width: AppSpacing.space16),
                          Expanded(
                            child: Text(
                              'Active Errors',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.black),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.disabled),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
