import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/notification_item.dart';
import 'providers/notifications_provider.dart';

/// The screen displaying all notifications.
/// Defined by UI_UX_BLUEPRINT.md Section 10.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Clear All',
      body: 'Are you sure you want to delete all notifications?',
      confirmLabel: 'Clear',
      isDestructive: true,
    );

    if (confirmed == true) {
      ref.read(notificationsProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
        ),
        actions: [
          notificationsState.maybeWhen(
            data: (notifications) {
              if (notifications.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _showClearAllDialog(context, ref),
                child: Text(
                  'Clear All',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.brandGreen),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: notificationsState.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'Failed to load notifications',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed),
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return const EmptyStateWidget(
                title: 'No Notifications',
                subtitle: 'You have no new notifications.',
                icon: Icons.notifications_none,
              );
            }

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification.id ?? notification.timestamp.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.errorRed,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Icon(Icons.delete_outline, color: AppColors.surface),
                  ),
                  onDismissed: (direction) {
                    if (notification.id != null) {
                      ref.read(notificationsProvider.notifier).deleteNotification(notification.id!);
                    }
                  },
                  child: NotificationItem(
                    notification: notification,
                    onTap: () {
                      if (!notification.read && notification.id != null) {
                        ref.read(notificationsProvider.notifier).markAsRead(notification.id!);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
