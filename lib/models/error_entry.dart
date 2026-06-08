import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_entry.freezed.dart';
part 'error_entry.g.dart';

/// Represents a BMS error record.
/// 
/// Defined by DB_SCHEMA.md Section 5.1.
@freezed
abstract class ErrorEntry with _$ErrorEntry {
  const factory ErrorEntry({
    String? id, // Firestore document ID
    required DateTime timestamp,
    required String errorCode,
    required String message,
    required String severity,
  }) = _ErrorEntry;

  factory ErrorEntry.fromJson(Map<String, dynamic> json) =>
      _$ErrorEntryFromJson(json);
}
