import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Represents a user account.
/// 
/// Defined by DB_SCHEMA.md Section 2.1.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid, // Firebase Auth UID / Firestore document ID
    required String name,
    required String email,
    required DateTime dob,
    String? deviceSerial,
    String? fcmToken,
    required DateTime createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
