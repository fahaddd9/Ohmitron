import 'package:freezed_annotation/freezed_annotation.dart';

part 'battery_status.freezed.dart';
part 'battery_status.g.dart';

/// Represents the instantaneous telemetry readings from the battery.
/// 
/// Defined by DB_SCHEMA.md Section 4.2.
@freezed
abstract class BatteryStatus with _$BatteryStatus {
  const factory BatteryStatus({
    required DateTime timestamp,
    double? stateOfCharge,
    double? remainingTimeHours,
    required double voltage,
    required double current,
    double? dischargingWatts,
    required bool isCharging,
    required bool isDischarging,
    required String balanceState,
    required String protectionState,
    required double temperatureCelsius,
  }) = _BatteryStatus;

  factory BatteryStatus.fromJson(Map<String, dynamic> json) =>
      _$BatteryStatusFromJson(json);
}
