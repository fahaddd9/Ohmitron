import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app_notification.dart';
import '../../../../providers/data_source_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final user = await ref.watch(authProvider.future);
    if (user == null || user.deviceSerial == null) {
      return [];
    }
    
    final dataSource = ref.watch(batteryDataSourceProvider);
    return dataSource.getNotifications(user.uid, user.deviceSerial!);
  }

  Future<void> markAsRead(String id) async {
    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      previousState.map((n) => n.id == id ? n.copyWith(read: true) : n).toList(),
    );

    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.markNotificationRead(id);
    } catch (e, stack) {
      // Revert on error
      state = AsyncValue.data(previousState);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNotification(String id) async {
    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      previousState.where((n) => n.id != id).toList(),
    );

    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.deleteNotification(id);
    } catch (e, stack) {
      // Revert on error
      state = AsyncValue.data(previousState);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearAll() async {
    final user = ref.read(authProvider).value;
    if (user == null || user.deviceSerial == null) return;

    final previousState = state.value;
    if (previousState == null) return;

    // Optimistic update
    state = const AsyncValue.data([]);

    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.clearAllNotifications(user.uid, user.deviceSerial!);
    } catch (e, stack) {
      // Revert on error
      state = AsyncValue.data(previousState);
      state = AsyncValue.error(e, stack);
    }
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(() {
  return NotificationsNotifier();
});
