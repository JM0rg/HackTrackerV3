// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthFormState {

 bool get isSaving; String? get errorMessage; bool get codeSent; String? get pendingEmail;
/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFormStateCopyWith<AuthFormState> get copyWith => _$AuthFormStateCopyWithImpl<AuthFormState>(this as AuthFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.codeSent, codeSent) || other.codeSent == codeSent)&&(identical(other.pendingEmail, pendingEmail) || other.pendingEmail == pendingEmail));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,codeSent,pendingEmail);

@override
String toString() {
  return 'AuthFormState(isSaving: $isSaving, errorMessage: $errorMessage, codeSent: $codeSent, pendingEmail: $pendingEmail)';
}


}

/// @nodoc
abstract mixin class $AuthFormStateCopyWith<$Res>  {
  factory $AuthFormStateCopyWith(AuthFormState value, $Res Function(AuthFormState) _then) = _$AuthFormStateCopyWithImpl;
@useResult
$Res call({
 bool isSaving, String? errorMessage, bool codeSent, String? pendingEmail
});




}
/// @nodoc
class _$AuthFormStateCopyWithImpl<$Res>
    implements $AuthFormStateCopyWith<$Res> {
  _$AuthFormStateCopyWithImpl(this._self, this._then);

  final AuthFormState _self;
  final $Res Function(AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? codeSent = null,Object? pendingEmail = freezed,}) {
  return _then(_self.copyWith(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,codeSent: null == codeSent ? _self.codeSent : codeSent // ignore: cast_nullable_to_non_nullable
as bool,pendingEmail: freezed == pendingEmail ? _self.pendingEmail : pendingEmail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthFormState].
extension AuthFormStatePatterns on AuthFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthFormState value)  $default,){
final _that = this;
switch (_that) {
case _AuthFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool codeSent,  String? pendingEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.codeSent,_that.pendingEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSaving,  String? errorMessage,  bool codeSent,  String? pendingEmail)  $default,) {final _that = this;
switch (_that) {
case _AuthFormState():
return $default(_that.isSaving,_that.errorMessage,_that.codeSent,_that.pendingEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSaving,  String? errorMessage,  bool codeSent,  String? pendingEmail)?  $default,) {final _that = this;
switch (_that) {
case _AuthFormState() when $default != null:
return $default(_that.isSaving,_that.errorMessage,_that.codeSent,_that.pendingEmail);case _:
  return null;

}
}

}

/// @nodoc


class _AuthFormState extends AuthFormState {
  const _AuthFormState({this.isSaving = false, this.errorMessage, this.codeSent = false, this.pendingEmail}): super._();
  

@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
@override@JsonKey() final  bool codeSent;
@override final  String? pendingEmail;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthFormStateCopyWith<_AuthFormState> get copyWith => __$AuthFormStateCopyWithImpl<_AuthFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthFormState&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.codeSent, codeSent) || other.codeSent == codeSent)&&(identical(other.pendingEmail, pendingEmail) || other.pendingEmail == pendingEmail));
}


@override
int get hashCode => Object.hash(runtimeType,isSaving,errorMessage,codeSent,pendingEmail);

@override
String toString() {
  return 'AuthFormState(isSaving: $isSaving, errorMessage: $errorMessage, codeSent: $codeSent, pendingEmail: $pendingEmail)';
}


}

/// @nodoc
abstract mixin class _$AuthFormStateCopyWith<$Res> implements $AuthFormStateCopyWith<$Res> {
  factory _$AuthFormStateCopyWith(_AuthFormState value, $Res Function(_AuthFormState) _then) = __$AuthFormStateCopyWithImpl;
@override @useResult
$Res call({
 bool isSaving, String? errorMessage, bool codeSent, String? pendingEmail
});




}
/// @nodoc
class __$AuthFormStateCopyWithImpl<$Res>
    implements _$AuthFormStateCopyWith<$Res> {
  __$AuthFormStateCopyWithImpl(this._self, this._then);

  final _AuthFormState _self;
  final $Res Function(_AuthFormState) _then;

/// Create a copy of AuthFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSaving = null,Object? errorMessage = freezed,Object? codeSent = null,Object? pendingEmail = freezed,}) {
  return _then(_AuthFormState(
isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,codeSent: null == codeSent ? _self.codeSent : codeSent // ignore: cast_nullable_to_non_nullable
as bool,pendingEmail: freezed == pendingEmail ? _self.pendingEmail : pendingEmail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
