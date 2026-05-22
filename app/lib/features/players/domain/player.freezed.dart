// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Player {

 String get id; String get teamId; String get name; PlayerStatus get status; List<String> get defaultPositions; String? get jerseyNumber; Handedness? get throws; BattingSide? get bats; String? get gender; String? get phone; String? get email;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.defaultPositions, defaultPositions)&&(identical(other.jerseyNumber, jerseyNumber) || other.jerseyNumber == jerseyNumber)&&(identical(other.throws, throws) || other.throws == throws)&&(identical(other.bats, bats) || other.bats == bats)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,name,status,const DeepCollectionEquality().hash(defaultPositions),jerseyNumber,throws,bats,gender,phone,email);

@override
String toString() {
  return 'Player(id: $id, teamId: $teamId, name: $name, status: $status, defaultPositions: $defaultPositions, jerseyNumber: $jerseyNumber, throws: $throws, bats: $bats, gender: $gender, phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 String id, String teamId, String name, PlayerStatus status, List<String> defaultPositions, String? jerseyNumber, Handedness? throws, BattingSide? bats, String? gender, String? phone, String? email
});




}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamId = null,Object? name = null,Object? status = null,Object? defaultPositions = null,Object? jerseyNumber = freezed,Object? throws = freezed,Object? bats = freezed,Object? gender = freezed,Object? phone = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlayerStatus,defaultPositions: null == defaultPositions ? _self.defaultPositions : defaultPositions // ignore: cast_nullable_to_non_nullable
as List<String>,jerseyNumber: freezed == jerseyNumber ? _self.jerseyNumber : jerseyNumber // ignore: cast_nullable_to_non_nullable
as String?,throws: freezed == throws ? _self.throws : throws // ignore: cast_nullable_to_non_nullable
as Handedness?,bats: freezed == bats ? _self.bats : bats // ignore: cast_nullable_to_non_nullable
as BattingSide?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Player].
extension PlayerPatterns on Player {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Player value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Player value)  $default,){
final _that = this;
switch (_that) {
case _Player():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Player value)?  $default,){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamId,  String name,  PlayerStatus status,  List<String> defaultPositions,  String? jerseyNumber,  Handedness? throws,  BattingSide? bats,  String? gender,  String? phone,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.teamId,_that.name,_that.status,_that.defaultPositions,_that.jerseyNumber,_that.throws,_that.bats,_that.gender,_that.phone,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamId,  String name,  PlayerStatus status,  List<String> defaultPositions,  String? jerseyNumber,  Handedness? throws,  BattingSide? bats,  String? gender,  String? phone,  String? email)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.id,_that.teamId,_that.name,_that.status,_that.defaultPositions,_that.jerseyNumber,_that.throws,_that.bats,_that.gender,_that.phone,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamId,  String name,  PlayerStatus status,  List<String> defaultPositions,  String? jerseyNumber,  Handedness? throws,  BattingSide? bats,  String? gender,  String? phone,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.teamId,_that.name,_that.status,_that.defaultPositions,_that.jerseyNumber,_that.throws,_that.bats,_that.gender,_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc


class _Player implements Player {
  const _Player({required this.id, required this.teamId, required this.name, required this.status, final  List<String> defaultPositions = const [], this.jerseyNumber, this.throws, this.bats, this.gender, this.phone, this.email}): _defaultPositions = defaultPositions;
  

@override final  String id;
@override final  String teamId;
@override final  String name;
@override final  PlayerStatus status;
 final  List<String> _defaultPositions;
@override@JsonKey() List<String> get defaultPositions {
  if (_defaultPositions is EqualUnmodifiableListView) return _defaultPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultPositions);
}

@override final  String? jerseyNumber;
@override final  Handedness? throws;
@override final  BattingSide? bats;
@override final  String? gender;
@override final  String? phone;
@override final  String? email;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCopyWith<_Player> get copyWith => __$PlayerCopyWithImpl<_Player>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.id, id) || other.id == id)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._defaultPositions, _defaultPositions)&&(identical(other.jerseyNumber, jerseyNumber) || other.jerseyNumber == jerseyNumber)&&(identical(other.throws, throws) || other.throws == throws)&&(identical(other.bats, bats) || other.bats == bats)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,id,teamId,name,status,const DeepCollectionEquality().hash(_defaultPositions),jerseyNumber,throws,bats,gender,phone,email);

@override
String toString() {
  return 'Player(id: $id, teamId: $teamId, name: $name, status: $status, defaultPositions: $defaultPositions, jerseyNumber: $jerseyNumber, throws: $throws, bats: $bats, gender: $gender, phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamId, String name, PlayerStatus status, List<String> defaultPositions, String? jerseyNumber, Handedness? throws, BattingSide? bats, String? gender, String? phone, String? email
});




}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamId = null,Object? name = null,Object? status = null,Object? defaultPositions = null,Object? jerseyNumber = freezed,Object? throws = freezed,Object? bats = freezed,Object? gender = freezed,Object? phone = freezed,Object? email = freezed,}) {
  return _then(_Player(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlayerStatus,defaultPositions: null == defaultPositions ? _self._defaultPositions : defaultPositions // ignore: cast_nullable_to_non_nullable
as List<String>,jerseyNumber: freezed == jerseyNumber ? _self.jerseyNumber : jerseyNumber // ignore: cast_nullable_to_non_nullable
as String?,throws: freezed == throws ? _self.throws : throws // ignore: cast_nullable_to_non_nullable
as Handedness?,bats: freezed == bats ? _self.bats : bats // ignore: cast_nullable_to_non_nullable
as BattingSide?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
