import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Runs the native Google sign-in flow (v7 singleton API) and exchanges the ID
/// token for a Supabase session. `GoogleSignIn.instance.initialize(...)` must
/// have run during app bootstrap.
class GoogleAuthService {
  GoogleAuthService(this._client);

  final SupabaseClient _client;

  Future<void> signIn() async {
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('Google did not return an ID token');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }
}
