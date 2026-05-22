// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Game {

 String get id; String get teamId; HomeAway get homeAway; GameStatus get status; String? get opponentName; String? get parkName; String? get cityOrAddress; DateTime? get startTime; int? get ourScore; int? get oppScore; String? get result; String? get notes;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.homeAway, homeAway) || other.homeAway == homeAway)&&(identical(other.status, status) || other.status == status)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.parkName, parkName) || other.parkName == parkName)&&(identical(other.cityOrAddress, cityOrAddress) || other.cityOrAddress == cityOrAddress)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.ourScore, ourScore) || other.ourScore == ourScore)&&(identical(other.oppScore, oppScore) || other.oppScore == oppScore)&&(identical(other.result, result) || other.result == result)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,homeAway,status,opponentName,parkName,cityOrAddress,startTime,ourScore,oppScore,result,notes);

@override
String toString() {
  return 'Game(id: $id, teamId: $teamId, homeAway: $homeAway, status: $status, opponentName: $opponentName, parkName: $parkName, cityOrAddress: $cityOrAddress, startTime: $startTime, ourScore: $ourScore, oppScore: $oppScore, result: $result, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, HomeAway homeAway, GameStatus status, String? opponentName, String? parkName, String? cityOrAddress, DateTime? startTime, int? ourScore, int? oppScore, String? result, String? notes
});




}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamId = null,Object? homeAway = null,Object? status = null,Object? opponentName = freezed,Object? parkName = freezed,Object? cityOrAddress = freezed,Object? startTime = freezed,Object? ourScore = freezed,Object? oppScore = freezed,Object? result = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,homeAway: null == homeAway ? _self.homeAway : homeAway // ignore: cast_nullable_to_non_nullable
as HomeAway,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,parkName: freezed == parkName ? _self.parkName : parkName // ignore: cast_nullable_to_non_nullable
as String?,cityOrAddress: freezed == cityOrAddress ? _self.cityOrAddress : cityOrAddress // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,ourScore: freezed == ourScore ? _self.ourScore : ourScore // ignore: cast_nullable_to_non_nullable
as int?,oppScore: freezed == oppScore ? _self.oppScore : oppScore // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  HomeAway homeAway,  GameStatus status,  String? opponentName,  String? parkName,  String? cityOrAddress,  DateTime? startTime,  int? ourScore,  int? oppScore,  String? result,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.teamId,_that.homeAway,_that.status,_that.opponentName,_that.parkName,_that.cityOrAddress,_that.startTime,_that.ourScore,_that.oppScore,_that.result,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  HomeAway homeAway,  GameStatus status,  String? opponentName,  String? parkName,  String? cityOrAddress,  DateTime? startTime,  int? ourScore,  int? oppScore,  String? result,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.id,_that.teamId,_that.homeAway,_that.status,_that.opponentName,_that.parkName,_that.cityOrAddress,_that.startTime,_that.ourScore,_that.oppScore,_that.result,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  HomeAway homeAway,  GameStatus status,  String? opponentName,  String? parkName,  String? cityOrAddress,  DateTime? startTime,  int? ourScore,  int? oppScore,  String? result,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.id,_that.teamId,_that.homeAway,_that.status,_that.opponentName,_that.parkName,_that.cityOrAddress,_that.startTime,_that.ourScore,_that.oppScore,_that.result,_that.notes);case _:
  return null;

}
}

}

/// @nodoc


class _Game implements Game {
  const _Game({required this.id, required this.teamId, required this.homeAway, required this.status, this.opponentName, this.parkName, this.cityOrAddress, this.startTime, this.ourScore, this.oppScore, this.result, this.notes});
  

@override final  String id;
@override final  String teamId;
@override final  HomeAway homeAway;
@override final  GameStatus status;
@override final  String? opponentName;
@override final  String? parkName;
@override final  String? cityOrAddress;
@override final  DateTime? startTime;
@override final  int? ourScore;
@override final  int? oppScore;
@override final  String? result;
@override final  String? notes;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.homeAway, homeAway) || other.homeAway == homeAway)&&(identical(other.status, status) || other.status == status)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.parkName, parkName) || other.parkName == parkName)&&(identical(other.cityOrAddress, cityOrAddress) || other.cityOrAddress == cityOrAddress)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.ourScore, ourScore) || other.ourScore == ourScore)&&(identical(other.oppScore, oppScore) || other.oppScore == oppScore)&&(identical(other.result, result) || other.result == result)&&(identical(other.notes, notes) || other.notes == notes));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,homeAway,status,opponentName,parkName,cityOrAddress,startTime,ourScore,oppScore,result,notes);

@override
String toString() {
  return 'Game(id: $id, teamId: $teamId, homeAway: $homeAway, status: $status, opponentName: $opponentName, parkName: $parkName, cityOrAddress: $cityOrAddress, startTime: $startTime, ourScore: $ourScore, oppScore: $oppScore, result: $result, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, HomeAway homeAway, GameStatus status, String? opponentName, String? parkName, String? cityOrAddress, DateTime? startTime, int? ourScore, int? oppScore, String? result, String? notes
});




}
/// @nodoc
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? homeAway = null,Object? status = null,Object? opponentName = freezed,Object? parkName = freezed,Object? cityOrAddress = freezed,Object? startTime = freezed,Object? ourScore = freezed,Object? oppScore = freezed,Object? result = freezed,Object? notes = freezed,}) {
  return _then(_Game(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,homeAway: null == homeAway ? _self.homeAway : homeAway // ignore: cast_nullable_to_non_nullable
as HomeAway,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,parkName: freezed == parkName ? _self.parkName : parkName // ignore: cast_nullable_to_non_nullable
as String?,cityOrAddress: freezed == cityOrAddress ? _self.cityOrAddress : cityOrAddress // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,ourScore: freezed == ourScore ? _self.ourScore : ourScore // ignore: cast_nullable_to_non_nullable
as int?,oppScore: freezed == oppScore ? _self.oppScore : oppScore // ignore: cast_nullable_to_non_nullable
as int?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
