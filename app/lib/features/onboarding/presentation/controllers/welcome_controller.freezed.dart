// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'welcome_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WelcomeFormState {

 bool get isSaving; String? get errorMessage;
/// Create a copy of WelcomeFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WelcomeFormStateCopyWith<WelcomeFormState> get copyWith => _$WelcomeFormStateCopyWithImpl<WelcomeFormState>(this as WelcomeFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WelcomeFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage);

@override
String toString() {
  return 'WelcomeFormState(isSaving: $isSaving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $WelcomeFormStateCopyWith<$Res>  {
  factory $WelcomeFormStateCopyWith(WelcomeFormState value, $Res Function(WelcomeFormState) _then) = _$WelcomeFormStateCopyWithImpl;
@useResult
$Res call({
 bool isSaving, String? errorMessage
});




}
/// @nodoc
class _$WelcomeFormStateCopyWithImpl<$Res>
    implements $WelcomeFormStateCopyWith<$Res> {
  _$WelcomeFormStateCopyWithImpl(this._self, this._then);

  final WelcomeFormState _self;
  final $Res Function(WelcomeFormState) _then;

/// Create a copy of WelcomeFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WelcomeFormState].
extension WelcomeFormStatePatterns on WelcomeFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WelcomeFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WelcomeFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WelcomeFormState value)  $default,){
final _that = this;
switch (_that) {
case _WelcomeFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WelcomeFormState value)?  $default,){
final _that = this;
switch (_that) {
case _WelcomeFormState() when $default != null:
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
case _WelcomeFormState() when $default != null:
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
case _WelcomeFormState():
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
case _WelcomeFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _WelcomeFormState extends WelcomeFormState {
  const _WelcomeFormState({this.isSaving = false, this.errorMessage}): super._();
  

@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;

/// Create a copy of WelcomeFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WelcomeFormStateCopyWith<_WelcomeFormState> get copyWith => __$WelcomeFormStateCopyWithImpl<_WelcomeFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WelcomeFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage);

@override
String toString() {
  return 'WelcomeFormState(isSaving: $isSaving, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$WelcomeFormStateCopyWith<$Res> implements $WelcomeFormStateCopyWith<$Res> {
  factory _$WelcomeFormStateCopyWith(_WelcomeFormState value, $Res Function(_WelcomeFormState) _then) = __$WelcomeFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSaving, String? errorMessage
});




}
/// @nodoc
class __$WelcomeFormStateCopyWithImpl<$Res>
    implements _$WelcomeFormStateCopyWith<$Res> {
  __$WelcomeFormStateCopyWithImpl(this._self, this._then);

  final _WelcomeFormState _self;
  final $Res Function(_WelcomeFormState) _then;

/// Create a copy of WelcomeFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSaving = null,Object? errorMessage = freezed,}) {
  return _then(_WelcomeFormState(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
