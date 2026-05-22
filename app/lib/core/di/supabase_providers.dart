import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The initialized Supabase client. `Supabase.initialize` runs in `main`
/// before the app is built, so this is safe to read eagerly.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Current auth user id (Supabase `auth.uid()`), or null when signed out.
/// The sync engine stamps this as `owner_id` on locally-created rows.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser?.id;
});
