import 'package:freezed_annotation/freezed_annotation.dart';

part 'wifi_network.freezed.dart';
part 'wifi_network.g.dart';

/// Represents a Wi-Fi network discovered by the ESP32 during provisioning.
@freezed
abstract class WifiNetwork with _$WifiNetwork {
  const factory WifiNetwork({
    required String ssid,
    required int signalStrength,
  }) = _WifiNetwork;

  factory WifiNetwork.fromJson(Map<String, dynamic> json) =>
      _$WifiNetworkFromJson(json);
}
