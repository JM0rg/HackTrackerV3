import 'package:drift/drift.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/utils/uuid.dart';

/// Columns every synced table shares. Drift composes these into each table via
/// `with SyncColumns`. Mirrors the Supabase sync contract: client-generatable
/// [id], server-authoritative [updatedAt], soft-delete [deletedAt], plus the
/// local-only [syncState] dirty flag (never sent to the server).
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(Uuid.v4)();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  IntColumn get syncState =>
      intEnum<SyncState>().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
