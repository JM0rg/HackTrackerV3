// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lineup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Lineup {

 String get id; String get gameId; String get teamId; String? get name;
/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineupCopyWith<Lineup> get copyWith => _$LineupCopyWithImpl<Lineup>(this as Lineup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lineup&&(identical(other.id, id) || other.id == id)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,gameId,teamId,name);

@override
String toString() {
  return 'Lineup(id: $id, gameId: $gameId, teamId: $teamId, name: $name)';
}


}

/// @nodoc
abstract mixin class $LineupCopyWith<$Res>  {
  factory $LineupCopyWith(Lineup value, $Res Function(Lineup) _then) = _$LineupCopyWithImpl;
@useResult
$Res call({
 String id, String gameId, String teamId, String? name
});




}
/// @nodoc
class _$LineupCopyWithImpl<$Res>
    implements $LineupCopyWith<$Res> {
  _$LineupCopyWithImpl(this._self, this._then);

  final Lineup _self;
  final $Res Function(Lineup) _then;

/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gameId = null,Object? teamId = null,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Lineup].
extension LineupPatterns on Lineup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lineup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lineup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lineup value)  $default,){
final _that = this;
switch (_that) {
case _Lineup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lineup value)?  $default,){
final _that = this;
switch (_that) {
case _Lineup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gameId,  String teamId,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lineup() when $default != null:
return $default(_that.id,_that.gameId,_that.teamId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gameId,  String teamId,  String? name)  $default,) {final _that = this;
switch (_that) {
case _Lineup():
return $default(_that.id,_that.gameId,_that.teamId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gameId,  String teamId,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _Lineup() when $default != null:
return $default(_that.id,_that.gameId,_that.teamId,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _Lineup implements Lineup {
  const _Lineup({required this.id, required this.gameId, required this.teamId, this.name});
  

@override final  String id;
@override final  String gameId;
@override final  String teamId;
@override final  String? name;

/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineupCopyWith<_Lineup> get copyWith => __$LineupCopyWithImpl<_Lineup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lineup&&(identical(other.id, id) || other.id == id)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,id,gameId,teamId,name);

@override
String toString() {
  return 'Lineup(id: $id, gameId: $gameId, teamId: $teamId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$LineupCopyWith<$Res> implements $LineupCopyWith<$Res> {
  factory _$LineupCopyWith(_Lineup value, $Res Function(_Lineup) _then) = __$LineupCopyWithImpl;
@override @useResult
$Res call({
 String id, String gameId, String teamId, String? name
});




}
/// @nodoc
class __$LineupCopyWithImpl<$Res>
    implements _$LineupCopyWith<$Res> {
  __$LineupCopyWithImpl(this._self, this._then);

  final _Lineup _self;
  final $Res Function(_Lineup) _then;

/// Create a copy of Lineup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gameId = null,Object? teamId = null,Object? name = freezed,}) {
  return _then(_Lineup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$LineupSlot {

 String get id; String get lineupId; String get teamId; String get playerId; int get battingOrder; String? get fieldPosition;
/// Create a copy of LineupSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineupSlotCopyWith<LineupSlot> get copyWith => _$LineupSlotCopyWithImpl<LineupSlot>(this as LineupSlot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineupSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.lineupId, lineupId) || other.lineupId == lineupId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.battingOrder, battingOrder) || other.battingOrder == battingOrder)&&(identical(other.fieldPosition, fieldPosition) || other.fieldPosition == fieldPosition));
}


@override
int get hashCode => Object.hash(runtimeType,id,lineupId,teamId,playerId,battingOrder,fieldPosition);

@override
String toString() {
  return 'LineupSlot(id: $id, lineupId: $lineupId, teamId: $teamId, playerId: $playerId, battingOrder: $battingOrder, fieldPosition: $fieldPosition)';
}


}

/// @nodoc
abstract mixin class $LineupSlotCopyWith<$Res>  {
  factory $LineupSlotCopyWith(LineupSlot value, $Res Function(LineupSlot) _then) = _$LineupSlotCopyWithImpl;
@useResult
$Res call({
 String id, String lineupId, String teamId, String playerId, int battingOrder, String? fieldPosition
});




}
/// @nodoc
class _$LineupSlotCopyWithImpl<$Res>
    implements $LineupSlotCopyWith<$Res> {
  _$LineupSlotCopyWithImpl(this._self, this._then);

  final LineupSlot _self;
  final $Res Function(LineupSlot) _then;

/// Create a copy of LineupSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lineupId = null,Object? teamId = null,Object? playerId = null,Object? battingOrder = null,Object? fieldPosition = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lineupId: null == lineupId ? _self.lineupId : lineupId // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,battingOrder: null == battingOrder ? _self.battingOrder : battingOrder // ignore: cast_nullable_to_non_nullable
as int,fieldPosition: freezed == fieldPosition ? _self.fieldPosition : fieldPosition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LineupSlot].
extension LineupSlotPatterns on LineupSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LineupSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LineupSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LineupSlot value)  $default,){
final _that = this;
switch (_that) {
case _LineupSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LineupSlot value)?  $default,){
final _that = this;
switch (_that) {
case _LineupSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String lineupId,  String teamId,  String playerId,  int battingOrder,  String? fieldPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LineupSlot() when $default != null:
return $default(_that.id,_that.lineupId,_that.teamId,_that.playerId,_that.battingOrder,_that.fieldPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String lineupId,  String teamId,  String playerId,  int battingOrder,  String? fieldPosition)  $default,) {final _that = this;
switch (_that) {
case _LineupSlot():
return $default(_that.id,_that.lineupId,_that.teamId,_that.playerId,_that.battingOrder,_that.fieldPosition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String lineupId,  String teamId,  String playerId,  int battingOrder,  String? fieldPosition)?  $default,) {final _that = this;
switch (_that) {
case _LineupSlot() when $default != null:
return $default(_that.id,_that.lineupId,_that.teamId,_that.playerId,_that.battingOrder,_that.fieldPosition);case _:
  return null;

}
}

}

/// @nodoc


class _LineupSlot implements LineupSlot {
  const _LineupSlot({required this.id, required this.lineupId, required this.teamId, required this.playerId, required this.battingOrder, this.fieldPosition});
  

@override final  String id;
@override final  String lineupId;
@override final  String teamId;
@override final  String playerId;
@override final  int battingOrder;
@override final  String? fieldPosition;

/// Create a copy of LineupSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LineupSlotCopyWith<_LineupSlot> get copyWith => __$LineupSlotCopyWithImpl<_LineupSlot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LineupSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.lineupId, lineupId) || other.lineupId == lineupId)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.battingOrder, battingOrder) || other.battingOrder == battingOrder)&&(identical(other.fieldPosition, fieldPosition) || other.fieldPosition == fieldPosition));
}


@override
int get hashCode => Object.hash(runtimeType,id,lineupId,teamId,playerId,battingOrder,fieldPosition);

@override
String toString() {
  return 'LineupSlot(id: $id, lineupId: $lineupId, teamId: $teamId, playerId: $playerId, battingOrder: $battingOrder, fieldPosition: $fieldPosition)';
}


}

/// @nodoc
abstract mixin class _$LineupSlotCopyWith<$Res> implements $LineupSlotCopyWith<$Res> {
  factory _$LineupSlotCopyWith(_LineupSlot value, $Res Function(_LineupSlot) _then) = __$LineupSlotCopyWithImpl;
@override @useResult
$Res call({
 String id, String lineupId, String teamId, String playerId, int battingOrder, String? fieldPosition
});




}
/// @nodoc
class __$LineupSlotCopyWithImpl<$Res>
    implements _$LineupSlotCopyWith<$Res> {
  __$LineupSlotCopyWithImpl(this._self, this._then);

  final _LineupSlot _self;
  final $Res Function(_LineupSlot) _then;

/// Create a copy of LineupSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lineupId = null,Object? teamId = null,Object? playerId = null,Object? battingOrder = null,Object? fieldPosition = freezed,}) {
  return _then(_LineupSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lineupId: null == lineupId ? _self.lineupId : lineupId // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,battingOrder: null == battingOrder ? _self.battingOrder : battingOrder // ignore: cast_nullable_to_non_nullable
as int,fieldPosition: freezed == fieldPosition ? _self.fieldPosition : fieldPosition // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
