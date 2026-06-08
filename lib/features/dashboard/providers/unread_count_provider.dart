import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Notifier tracking the number of unread notifications.
/// Currently hardcoded to 2 for UI testing purposes.
class UnreadCountNotifier extends Notifier<int> {
  @override
  int build() => 2; // Mock value
}

/// Exposes the unread notifications count.
final unreadCountProvider = NotifierProvider<UnreadCountNotifier, int>(() {
  return UnreadCountNotifier();
});
