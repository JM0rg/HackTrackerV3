// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_edit_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameFormState {

 bool get isSaving; String? get errorMessage;
/// Create a copy of GameFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameFormStateCopyWith<GameFormState> get copyWith => _$GameFormStateCopyWithImpl<GameFormState>(this as GameFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage);

@override
String toString() {
  return 'GameFormState(isSaving: $isSaving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $GameFormStateCopyWith<$Res>  {
  factory $GameFormStateCopyWith(GameFormState value, $Res Function(GameFormState) _then) = _$GameFormStateCopyWithImpl;
@useResult
$Res call({
 bool isSaving, String? errorMessage
});




}
/// @nodoc
class _$GameFormStateCopyWithImpl<$Res>
    implements $GameFormStateCopyWith<$Res> {
  _$GameFormStateCopyWithImpl(this._self, this._then);

  final GameFormState _self;
  final $Res Function(GameFormState) _then;

/// Create a copy of GameFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GameFormState].
extension GameFormStatePatterns on GameFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameFormState value)  $default,){
final _that = this;
switch (_that) {
case _GameFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameFormState value)?  $default,){
final _that = this;
switch (_that) {
case _GameFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _GameFormState():
return $default(_that.isSaving,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSaving,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _GameFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _GameFormState extends GameFormState {
  const _GameFormState({this.isSaving = false, this.errorMessage}): super._();
  

@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;

/// Create a copy of GameFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameFormStateCopyWith<_GameFormState> get copyWith => __$GameFormStateCopyWithImpl<_GameFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage);

@override
String toString() {
  return 'GameFormState(isSaving: $isSaving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$GameFormStateCopyWith<$Res> implements $GameFormStateCopyWith<$Res> {
  factory _$GameFormStateCopyWith(_GameFormState value, $Res Function(_GameFormState) _then) = __$GameFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSaving, String? errorMessage
});




}
/// @nodoc
class __$GameFormStateCopyWithImpl<$Res>
    implements _$GameFormStateCopyWith<$Res> {
  __$GameFormStateCopyWithImpl(this._self, this._then);

  final _GameFormState _self;
  final $Res Function(_GameFormState) _then;

/// Create a copy of GameFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(_GameFormState(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
