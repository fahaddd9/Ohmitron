import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectionTypeSeenNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // False by default in memory mock
  }

  void markAsSeen() {
    state = true;
  }
}

final connectionTypeSeenProvider = NotifierProvider<ConnectionTypeSeenNotifier, bool>(ConnectionTypeSeenNotifier.new);
