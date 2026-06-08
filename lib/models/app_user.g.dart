// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  uid: json['uid'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  dob: DateTime.parse(json['dob'] as String),
  deviceSerial: json['deviceSerial'] as String?,
  fcmToken: json['fcmToken'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'dob': instance.dob.toIso8601String(),
  'deviceSerial': instance.deviceSerial,
  'fcmToken': instance.fcmToken,
  'createdAt': instance.createdAt.toIso8601String(),
};
