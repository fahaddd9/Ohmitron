import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info.freezed.dart';
part 'device_info.g.dart';

/// Represents a physical Ohmitron device.
/// 
/// Defined by DB_SCHEMA.md Section 3.1.
@freezed
abstract class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    String? ownerUid,
    required bool provisioned,
    required String friendlyName,
    required String deviceModel,
    required String firmwareVersion,
    required String bmsModel,
    required String bmsId,
    String? connectedSsid,
    required DateTime createdAt,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}
