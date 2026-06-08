// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ErrorEntry _$ErrorEntryFromJson(Map<String, dynamic> json) => _ErrorEntry(
  id: json['id'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  errorCode: json['errorCode'] as String,
  message: json['message'] as String,
  severity: json['severity'] as String,
);

Map<String, dynamic> _$ErrorEntryToJson(_ErrorEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'errorCode': instance.errorCode,
      'message': instance.message,
      'severity': instance.severity,
    };
