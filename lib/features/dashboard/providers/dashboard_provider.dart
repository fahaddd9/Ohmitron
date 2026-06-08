import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/battery_status.dart';
import '../../../providers/data_source_provider.dart';

/// Provides the raw stream of battery status from the active data source.
final dashboardProvider = StreamProvider<BatteryStatus>((ref) {
  final dataSource = ref.watch(batteryDataSourceProvider);
  return dataSource.batteryStatusStream;
});

/// A Notifier that tracks if the incoming battery data is stale.
/// It resets a 45-second timer every time a new [BatteryStatus] is emitted.
class StaleDataNotifier extends Notifier<bool> {
  Timer? _staleTimer;

  @override
  bool build() {
    // Watch the stream and reset the timer whenever a new value arrives
    ref.listen<AsyncValue<BatteryStatus>>(dashboardProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // We received new data. It's not stale right now.
        state = false;
        
        // Reset the 45-second timer
        _staleTimer?.cancel();
        _staleTimer = Timer(const Duration(seconds: 45), () {
          // If this timer fires, 45 seconds have passed without new data.
          state = true;
        });
      }
    });

    ref.onDispose(() {
      _staleTimer?.cancel();
    });

    return false;
  }
}

/// Exposes the current staleness state of the dashboard data.
final isDataStaleProvider = NotifierProvider<StaleDataNotifier, bool>(() {
  return StaleDataNotifier();
});
