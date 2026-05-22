import 'package:drift/drift.dart';

/// Per-table incremental-pull cursor. The sync engine pulls rows where
/// `updated_at > lastPulledAt` and advances the cursor afterward. Local-only;
/// never synced, so it does not use [SyncColumns].
class SyncMeta extends Table {
  /// The synced table this cursor tracks (e.g. 'teams').
  TextColumn get tableKey => text()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tableKey};
}
