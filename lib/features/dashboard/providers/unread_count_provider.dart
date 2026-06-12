import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/presentation/providers/notifications_provider.dart';

/// A Notifier tracking the number of unread notifications.
class UnreadCountNotifier extends Notifier<int> {
  @override
  int build() {
    final notificationsState = ref.watch(notificationsProvider);
    
    return notificationsState.maybeWhen(
      data: (notifications) => notifications.where((n) => !n.read).length,
      orElse: () => 0,
    );
  }
}

/// Exposes the unread notifications count.
final unreadCountProvider = NotifierProvider<UnreadCountNotifier, int>(() {
  return UnreadCountNotifier();
});
