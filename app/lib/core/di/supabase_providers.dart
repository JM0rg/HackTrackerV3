import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The initialized Supabase client. `Supabase.initialize` runs in `main`
/// before the app is built, so this is safe to read eagerly.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Current auth user id (Supabase `auth.uid()`), or null when signed out.
/// The sync engine stamps this as `owner_id` on locally-created rows.
///
/// Subscribes to `onAuthStateChange` and invalidates itself on every event so
/// the cached id never goes stale — without this, a first-time sign-in leaves
/// downstream providers (myProfileProvider, the onboarding gate) holding the
/// pre-sign-in `null` until the next app launch.
final currentUserIdProvider = Provider<String?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final subscription = client.auth.onAuthStateChange.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);
  return client.auth.currentUser?.id;
});
