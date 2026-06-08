// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => _DeviceInfo(
  ownerUid: json['ownerUid'] as String?,
  provisioned: json['provisioned'] as bool,
  friendlyName: json['friendlyName'] as String,
  deviceModel: json['deviceModel'] as String,
  firmwareVersion: json['firmwareVersion'] as String,
  bmsModel: json['bmsModel'] as String,
  bmsId: json['bmsId'] as String,
  connectedSsid: json['connectedSsid'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DeviceInfoToJson(_DeviceInfo instance) =>
    <String, dynamic>{
      'ownerUid': instance.ownerUid,
      'provisioned': instance.provisioned,
      'friendlyName': instance.friendlyName,
      'deviceModel': instance.deviceModel,
      'firmwareVersion': instance.firmwareVersion,
      'bmsModel': instance.bmsModel,
      'bmsId': instance.bmsId,
      'connectedSsid': instance.connectedSsid,
      'createdAt': instance.createdAt.toIso8601String(),
    };
