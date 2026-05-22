import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/base/base_notifier.dart';
import '../../data/auth_repository.dart';

part 'auth_controller.freezed.dart';

/// Form state for the sign-in flow. [codeSent]/[pendingEmail] drive the
/// transition to the OTP verification screen.
@freezed
abstract class AuthFormState
    with _$AuthFormState
    implements BaseNotifierState<AuthFormState> {
  const factory AuthFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default(false) bool codeSent,
    String? pendingEmail,
  }) = _AuthFormState;

  const AuthFormState._();

  @override
  AuthFormState withSaving(bool saving) => copyWith(isSaving: saving);

  @override
  AuthFormState withError(String? error) =>
      copyWith(errorMessage: error, isSaving: isSaving);
}

/// Drives sign-in actions. Auth *state* (signed in/out) for routing comes from
/// [authChangesProvider]; this controller only owns the form's busy/error.
class AuthController extends Notifier<AuthFormState>
    with BaseNotifierMixin<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> sendCode(String email) async {
    final ok = await guard(() => _repo.sendEmailOtp(email));
    if (ok) state = state.copyWith(codeSent: true, pendingEmail: email);
  }

  Future<bool> verifyCode(String token) {
    final email = state.pendingEmail;
    if (email == null) return Future.value(false);
    return guard(() => _repo.verifyEmailOtp(email: email, token: token));
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthFormState>(
  AuthController.new,
);

/// Streams Supabase auth changes; the router listens to this to re-run redirect
/// logic on sign-in/out.
final authChangesProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
