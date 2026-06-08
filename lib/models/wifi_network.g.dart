// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wifi_network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WifiNetwork _$WifiNetworkFromJson(Map<String, dynamic> json) => _WifiNetwork(
  ssid: json['ssid'] as String,
  signalStrength: (json['signalStrength'] as num).toInt(),
);

Map<String, dynamic> _$WifiNetworkToJson(_WifiNetwork instance) =>
    <String, dynamic>{
      'ssid': instance.ssid,
      'signalStrength': instance.signalStrength,
    };
