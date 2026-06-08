// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battery_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BatteryStatus _$BatteryStatusFromJson(Map<String, dynamic> json) =>
    _BatteryStatus(
      timestamp: DateTime.parse(json['timestamp'] as String),
      stateOfCharge: (json['stateOfCharge'] as num?)?.toDouble(),
      remainingTimeHours: (json['remainingTimeHours'] as num?)?.toDouble(),
      voltage: (json['voltage'] as num).toDouble(),
      current: (json['current'] as num).toDouble(),
      dischargingWatts: (json['dischargingWatts'] as num?)?.toDouble(),
      isCharging: json['isCharging'] as bool,
      isDischarging: json['isDischarging'] as bool,
      balanceState: json['balanceState'] as String,
      protectionState: json['protectionState'] as String,
      temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
    );

Map<String, dynamic> _$BatteryStatusToJson(_BatteryStatus instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'stateOfCharge': instance.stateOfCharge,
      'remainingTimeHours': instance.remainingTimeHours,
      'voltage': instance.voltage,
      'current': instance.current,
      'dischargingWatts': instance.dischargingWatts,
      'isCharging': instance.isCharging,
      'isDischarging': instance.isDischarging,
      'balanceState': instance.balanceState,
      'protectionState': instance.protectionState,
      'temperatureCelsius': instance.temperatureCelsius,
    };
