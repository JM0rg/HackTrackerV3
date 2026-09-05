import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Current Supabase user, or null when signed out / no backend configured.
/// Scoring never depends on this.
final authUserProvider = StreamProvider<User?>((ref) async* {
  if (!Env.hasSupabase) {
    yield null;
    return;
  }
  final client = Supabase.instance.client;
  yield client.auth.currentUser;
  await for (final data in client.auth.onAuthStateChange) {
    yield data.session?.user;
  }
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authUserProvider).valueOrNull != null;
});
