import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/di/supabase_providers.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/services/app_logger.dart';

/// The auth boundary. Passwordless email one-time code only. Converts
/// network/auth exceptions into typed [AuthFailure]s so controllers never see
/// raw throws.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Emits on every sign-in / sign-out / token refresh.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  bool get hasSession => _client.auth.currentSession != null;

  /// Sends a one-time code / magic link to [email].
  Future<Result<void>> sendEmailOtp(String email) => _guard(
    () => _client.auth.signInWithOtp(email: email),
    'Could not send sign-in code',
  );

  /// Verifies the [token] emailed to [email], establishing a session.
  Future<Result<void>> verifyEmailOtp({
    required String email,
    required String token,
  }) => _guard(
    () =>
        _client.auth.verifyOTP(email: email, token: token, type: OtpType.email),
    'Invalid or expired code',
  );

  Future<Result<void>> signOut() =>
      _guard(_client.auth.signOut, 'Sign-out failed');

  Future<Result<void>> _guard(
    Future<void> Function() action,
    String fallbackMessage,
  ) async {
    try {
      await action();
      return const Result.ok(null);
    } on AuthException catch (e, stack) {
      AppLogger.error(fallbackMessage, e, stack);
      return Result.err(AuthFailure(e.message));
    } catch (e, stack) {
      AppLogger.error(fallbackMessage, e, stack);
      return Result.err(AuthFailure(fallbackMessage));
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
