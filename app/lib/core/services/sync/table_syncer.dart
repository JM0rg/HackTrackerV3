import 'package:supabase_flutter/supabase_flutter.dart';

/// One table's sync strategy. Concrete syncers live with their feature
/// (`features/<x>/services/`) and own the JSON⇄Drift mapping for that table.
///
/// The engine drives all syncers: first [push] (local→remote) across every
/// table in FK-dependency order, then [pull] (remote→local) per table using an
/// incremental `updated_at` cursor.
abstract class TableSyncer {
  /// Supabase table name; also the [SyncMeta] cursor key.
  String get table;

  /// Upsert locally-dirty rows to Supabase and clear their dirty flags.
  Future<void> push(SupabaseClient remote);

  /// Pull rows changed since [since] (inclusive of soft-deleted tombstones),
  /// upsert them locally, and return the newest `updated_at` observed (or
  /// [since] when nothing changed) so the engine can advance the cursor.
  Future<DateTime?> pull(SupabaseClient remote, DateTime? since);
}
