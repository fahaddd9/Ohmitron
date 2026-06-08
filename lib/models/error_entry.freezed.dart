// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ErrorEntry {

 String? get id;// Firestore document ID
 DateTime get timestamp; String get errorCode; String get message; String get severity;
/// Create a copy of ErrorEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorEntryCopyWith<ErrorEntry> get copyWith => _$ErrorEntryCopyWithImpl<ErrorEntry>(this as ErrorEntry, _$identity);

  /// Serializes this ErrorEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.severity, severity) || other.severity == severity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,errorCode,message,severity);

@override
String toString() {
  return 'ErrorEntry(id: $id, timestamp: $timestamp, errorCode: $errorCode, message: $message, severity: $severity)';
}


}

/// @nodoc
abstract mixin class $ErrorEntryCopyWith<$Res>  {
  factory $ErrorEntryCopyWith(ErrorEntry value, $Res Function(ErrorEntry) _then) = _$ErrorEntryCopyWithImpl;
@useResult
$Res call({
 String? id, DateTime timestamp, String errorCode, String message, String severity
});




}
/// @nodoc
class _$ErrorEntryCopyWithImpl<$Res>
    implements $ErrorEntryCopyWith<$Res> {
  _$ErrorEntryCopyWithImpl(this._self, this._then);

  final ErrorEntry _self;
  final $Res Function(ErrorEntry) _then;

/// Create a copy of ErrorEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? timestamp = null,Object? errorCode = null,Object? message = null,Object? severity = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ErrorEntry].
extension ErrorEntryPatterns on ErrorEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ErrorEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ErrorEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ErrorEntry value)  $default,){
final _that = this;
switch (_that) {
case _ErrorEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ErrorEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ErrorEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  DateTime timestamp,  String errorCode,  String message,  String severity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ErrorEntry() when $default != null:
return $default(_that.id,_that.timestamp,_that.errorCode,_that.message,_that.severity);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  DateTime timestamp,  String errorCode,  String message,  String severity)  $default,) {final _that = this;
switch (_that) {
case _ErrorEntry():
return $default(_that.id,_that.timestamp,_that.errorCode,_that.message,_that.severity);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  DateTime timestamp,  String errorCode,  String message,  String severity)?  $default,) {final _that = this;
switch (_that) {
case _ErrorEntry() when $default != null:
return $default(_that.id,_that.timestamp,_that.errorCode,_that.message,_that.severity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ErrorEntry implements ErrorEntry {
  const _ErrorEntry({this.id, required this.timestamp, required this.errorCode, required this.message, required this.severity});
  factory _ErrorEntry.fromJson(Map<String, dynamic> json) => _$ErrorEntryFromJson(json);

@override final  String? id;
// Firestore document ID
@override final  DateTime timestamp;
@override final  String errorCode;
@override final  String message;
@override final  String severity;

/// Create a copy of ErrorEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorEntryCopyWith<_ErrorEntry> get copyWith => __$ErrorEntryCopyWithImpl<_ErrorEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ErrorEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ErrorEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.severity, severity) || other.severity == severity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,timestamp,errorCode,message,severity);

@override
String toString() {
  return 'ErrorEntry(id: $id, timestamp: $timestamp, errorCode: $errorCode, message: $message, severity: $severity)';
}


}

/// @nodoc
abstract mixin class _$ErrorEntryCopyWith<$Res> implements $ErrorEntryCopyWith<$Res> {
  factory _$ErrorEntryCopyWith(_ErrorEntry value, $Res Function(_ErrorEntry) _then) = __$ErrorEntryCopyWithImpl;
@override @useResult
$Res call({
 String? id, DateTime timestamp, String errorCode, String message, String severity
});




}
/// @nodoc
class __$ErrorEntryCopyWithImpl<$Res>
    implements _$ErrorEntryCopyWith<$Res> {
  __$ErrorEntryCopyWithImpl(this._self, this._then);

  final _ErrorEntry _self;
  final $Res Function(_ErrorEntry) _then;

/// Create a copy of ErrorEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? timestamp = null,Object? errorCode = null,Object? message = null,Object? severity = null,}) {
  return _then(_ErrorEntry(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,errorCode: null == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
