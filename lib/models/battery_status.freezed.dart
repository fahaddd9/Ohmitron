// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'battery_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BatteryStatus {

 DateTime get timestamp; double? get stateOfCharge; double? get remainingTimeHours; double get voltage; double get current; double? get dischargingWatts; bool get isCharging; bool get isDischarging; String get balanceState; String get protectionState; double get temperatureCelsius;
/// Create a copy of BatteryStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatteryStatusCopyWith<BatteryStatus> get copyWith => _$BatteryStatusCopyWithImpl<BatteryStatus>(this as BatteryStatus, _$identity);

  /// Serializes this BatteryStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BatteryStatus&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.stateOfCharge, stateOfCharge) || other.stateOfCharge == stateOfCharge)&&(identical(other.remainingTimeHours, remainingTimeHours) || other.remainingTimeHours == remainingTimeHours)&&(identical(other.voltage, voltage) || other.voltage == voltage)&&(identical(other.current, current) || other.current == current)&&(identical(other.dischargingWatts, dischargingWatts) || other.dischargingWatts == dischargingWatts)&&(identical(other.isCharging, isCharging) || other.isCharging == isCharging)&&(identical(other.isDischarging, isDischarging) || other.isDischarging == isDischarging)&&(identical(other.balanceState, balanceState) || other.balanceState == balanceState)&&(identical(other.protectionState, protectionState) || other.protectionState == protectionState)&&(identical(other.temperatureCelsius, temperatureCelsius) || other.temperatureCelsius == temperatureCelsius));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,stateOfCharge,remainingTimeHours,voltage,current,dischargingWatts,isCharging,isDischarging,balanceState,protectionState,temperatureCelsius);

@override
String toString() {
  return 'BatteryStatus(timestamp: $timestamp, stateOfCharge: $stateOfCharge, remainingTimeHours: $remainingTimeHours, voltage: $voltage, current: $current, dischargingWatts: $dischargingWatts, isCharging: $isCharging, isDischarging: $isDischarging, balanceState: $balanceState, protectionState: $protectionState, temperatureCelsius: $temperatureCelsius)';
}


}

/// @nodoc
abstract mixin class $BatteryStatusCopyWith<$Res>  {
  factory $BatteryStatusCopyWith(BatteryStatus value, $Res Function(BatteryStatus) _then) = _$BatteryStatusCopyWithImpl;
@useResult
$Res call({
 DateTime timestamp, double? stateOfCharge, double? remainingTimeHours, double voltage, double current, double? dischargingWatts, bool isCharging, bool isDischarging, String balanceState, String protectionState, double temperatureCelsius
});




}
/// @nodoc
class _$BatteryStatusCopyWithImpl<$Res>
    implements $BatteryStatusCopyWith<$Res> {
  _$BatteryStatusCopyWithImpl(this._self, this._then);

  final BatteryStatus _self;
  final $Res Function(BatteryStatus) _then;

/// Create a copy of BatteryStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timestamp = null,Object? stateOfCharge = freezed,Object? remainingTimeHours = freezed,Object? voltage = null,Object? current = null,Object? dischargingWatts = freezed,Object? isCharging = null,Object? isDischarging = null,Object? balanceState = null,Object? protectionState = null,Object? temperatureCelsius = null,}) {
  return _then(_self.copyWith(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,stateOfCharge: freezed == stateOfCharge ? _self.stateOfCharge : stateOfCharge // ignore: cast_nullable_to_non_nullable
as double?,remainingTimeHours: freezed == remainingTimeHours ? _self.remainingTimeHours : remainingTimeHours // ignore: cast_nullable_to_non_nullable
as double?,voltage: null == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as double,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,dischargingWatts: freezed == dischargingWatts ? _self.dischargingWatts : dischargingWatts // ignore: cast_nullable_to_non_nullable
as double?,isCharging: null == isCharging ? _self.isCharging : isCharging // ignore: cast_nullable_to_non_nullable
as bool,isDischarging: null == isDischarging ? _self.isDischarging : isDischarging // ignore: cast_nullable_to_non_nullable
as bool,balanceState: null == balanceState ? _self.balanceState : balanceState // ignore: cast_nullable_to_non_nullable
as String,protectionState: null == protectionState ? _self.protectionState : protectionState // ignore: cast_nullable_to_non_nullable
as String,temperatureCelsius: null == temperatureCelsius ? _self.temperatureCelsius : temperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BatteryStatus].
extension BatteryStatusPatterns on BatteryStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BatteryStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BatteryStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BatteryStatus value)  $default,){
final _that = this;
switch (_that) {
case _BatteryStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BatteryStatus value)?  $default,){
final _that = this;
switch (_that) {
case _BatteryStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime timestamp,  double? stateOfCharge,  double? remainingTimeHours,  double voltage,  double current,  double? dischargingWatts,  bool isCharging,  bool isDischarging,  String balanceState,  String protectionState,  double temperatureCelsius)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BatteryStatus() when $default != null:
return $default(_that.timestamp,_that.stateOfCharge,_that.remainingTimeHours,_that.voltage,_that.current,_that.dischargingWatts,_that.isCharging,_that.isDischarging,_that.balanceState,_that.protectionState,_that.temperatureCelsius);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime timestamp,  double? stateOfCharge,  double? remainingTimeHours,  double voltage,  double current,  double? dischargingWatts,  bool isCharging,  bool isDischarging,  String balanceState,  String protectionState,  double temperatureCelsius)  $default,) {final _that = this;
switch (_that) {
case _BatteryStatus():
return $default(_that.timestamp,_that.stateOfCharge,_that.remainingTimeHours,_that.voltage,_that.current,_that.dischargingWatts,_that.isCharging,_that.isDischarging,_that.balanceState,_that.protectionState,_that.temperatureCelsius);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime timestamp,  double? stateOfCharge,  double? remainingTimeHours,  double voltage,  double current,  double? dischargingWatts,  bool isCharging,  bool isDischarging,  String balanceState,  String protectionState,  double temperatureCelsius)?  $default,) {final _that = this;
switch (_that) {
case _BatteryStatus() when $default != null:
return $default(_that.timestamp,_that.stateOfCharge,_that.remainingTimeHours,_that.voltage,_that.current,_that.dischargingWatts,_that.isCharging,_that.isDischarging,_that.balanceState,_that.protectionState,_that.temperatureCelsius);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BatteryStatus implements BatteryStatus {
  const _BatteryStatus({required this.timestamp, this.stateOfCharge, this.remainingTimeHours, required this.voltage, required this.current, this.dischargingWatts, required this.isCharging, required this.isDischarging, required this.balanceState, required this.protectionState, required this.temperatureCelsius});
  factory _BatteryStatus.fromJson(Map<String, dynamic> json) => _$BatteryStatusFromJson(json);

@override final  DateTime timestamp;
@override final  double? stateOfCharge;
@override final  double? remainingTimeHours;
@override final  double voltage;
@override final  double current;
@override final  double? dischargingWatts;
@override final  bool isCharging;
@override final  bool isDischarging;
@override final  String balanceState;
@override final  String protectionState;
@override final  double temperatureCelsius;

/// Create a copy of BatteryStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatteryStatusCopyWith<_BatteryStatus> get copyWith => __$BatteryStatusCopyWithImpl<_BatteryStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatteryStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BatteryStatus&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.stateOfCharge, stateOfCharge) || other.stateOfCharge == stateOfCharge)&&(identical(other.remainingTimeHours, remainingTimeHours) || other.remainingTimeHours == remainingTimeHours)&&(identical(other.voltage, voltage) || other.voltage == voltage)&&(identical(other.current, current) || other.current == current)&&(identical(other.dischargingWatts, dischargingWatts) || other.dischargingWatts == dischargingWatts)&&(identical(other.isCharging, isCharging) || other.isCharging == isCharging)&&(identical(other.isDischarging, isDischarging) || other.isDischarging == isDischarging)&&(identical(other.balanceState, balanceState) || other.balanceState == balanceState)&&(identical(other.protectionState, protectionState) || other.protectionState == protectionState)&&(identical(other.temperatureCelsius, temperatureCelsius) || other.temperatureCelsius == temperatureCelsius));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timestamp,stateOfCharge,remainingTimeHours,voltage,current,dischargingWatts,isCharging,isDischarging,balanceState,protectionState,temperatureCelsius);

@override
String toString() {
  return 'BatteryStatus(timestamp: $timestamp, stateOfCharge: $stateOfCharge, remainingTimeHours: $remainingTimeHours, voltage: $voltage, current: $current, dischargingWatts: $dischargingWatts, isCharging: $isCharging, isDischarging: $isDischarging, balanceState: $balanceState, protectionState: $protectionState, temperatureCelsius: $temperatureCelsius)';
}


}

/// @nodoc
abstract mixin class _$BatteryStatusCopyWith<$Res> implements $BatteryStatusCopyWith<$Res> {
  factory _$BatteryStatusCopyWith(_BatteryStatus value, $Res Function(_BatteryStatus) _then) = __$BatteryStatusCopyWithImpl;
@override @useResult
$Res call({
 DateTime timestamp, double? stateOfCharge, double? remainingTimeHours, double voltage, double current, double? dischargingWatts, bool isCharging, bool isDischarging, String balanceState, String protectionState, double temperatureCelsius
});




}
/// @nodoc
class __$BatteryStatusCopyWithImpl<$Res>
    implements _$BatteryStatusCopyWith<$Res> {
  __$BatteryStatusCopyWithImpl(this._self, this._then);

  final _BatteryStatus _self;
  final $Res Function(_BatteryStatus) _then;

/// Create a copy of BatteryStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timestamp = null,Object? stateOfCharge = freezed,Object? remainingTimeHours = freezed,Object? voltage = null,Object? current = null,Object? dischargingWatts = freezed,Object? isCharging = null,Object? isDischarging = null,Object? balanceState = null,Object? protectionState = null,Object? temperatureCelsius = null,}) {
  return _then(_BatteryStatus(
timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,stateOfCharge: freezed == stateOfCharge ? _self.stateOfCharge : stateOfCharge // ignore: cast_nullable_to_non_nullable
as double?,remainingTimeHours: freezed == remainingTimeHours ? _self.remainingTimeHours : remainingTimeHours // ignore: cast_nullable_to_non_nullable
as double?,voltage: null == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as double,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,dischargingWatts: freezed == dischargingWatts ? _self.dischargingWatts : dischargingWatts // ignore: cast_nullable_to_non_nullable
as double?,isCharging: null == isCharging ? _self.isCharging : isCharging // ignore: cast_nullable_to_non_nullable
as bool,isDischarging: null == isDischarging ? _self.isDischarging : isDischarging // ignore: cast_nullable_to_non_nullable
as bool,balanceState: null == balanceState ? _self.balanceState : balanceState // ignore: cast_nullable_to_non_nullable
as String,protectionState: null == protectionState ? _self.protectionState : protectionState // ignore: cast_nullable_to_non_nullable
as String,temperatureCelsius: null == temperatureCelsius ? _self.temperatureCelsius : temperatureCelsius // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
