import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_config.dart';
import '../services/battery_data_source.dart';
import '../services/mock_battery_data_source.dart';

/// Provides the current active [BatteryDataSource] implementation.
/// 
/// As defined in TRD.md Section 5.4, this uses the [AppConfig.useMockData]
/// flag to determine whether to return the mock implementation or the
/// production implementation (which will be built in Phase 6).
final batteryDataSourceProvider = Provider<BatteryDataSource>((ref) {
  if (AppConfig.useMockData) {
    return MockBatteryDataSource();
  }
  
  // Phase 6 will implement FirebaseBatteryDataSource
  throw UnimplementedError('Firebase layer is not implemented yet. Set AppConfig.useMockData to true.');
});
