import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// Represents an alert/notification targeted at a user for a specific device.
/// 
/// Defined by DB_SCHEMA.md Section 6.1.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    String? id, // Firestore document ID
    required String targetUserUid,
    required String deviceSerial,
    required String title,
    required String body,
    required DateTime timestamp,
    required bool read,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
