import 'package:drift/drift.dart';

import '../core/services/sync/sync_state.dart';
import '../core/utils/uuid.dart';
import 'connection/connection.dart';
import 'local/converters/string_list_converter.dart';
import 'local/tables/core_tables.dart';
import 'local/tables/lineup_tables.dart';
import 'local/tables/roster_schedule_tables.dart';
import 'local/tables/sync_meta_table.dart';

part 'app_database.g.dart';

/// The local SQLite database — the on-device source of truth. Feature
/// repositories read/write through Drift's manager API; the sync engine
/// reconciles these tables with Supabase in the background.
@DriftDatabase(
  tables: [
    Profiles,
    Teams,
    TeamMembers,
    Players,
    Groups,
    Games,
    GameGroups,
    Lineups,
    LineupSlots,
    SyncMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  /// Clears all user-scoped local data and resets the sync cursors. Called on
  /// sign-out so stale rows from a previous account never bleed into a fresh
  /// sign-in on the same device. Drift's `.watch()` streams react and the UI
  /// reactively empties.
  Future<void> wipeUserData() => transaction(() async {
    await delete(lineupSlots).go();
    await delete(lineups).go();
    await delete(gameGroups).go();
    await delete(games).go();
    await delete(groups).go();
    await delete(players).go();
    await delete(teamMembers).go();
    await delete(teams).go();
    await delete(profiles).go();
    await delete(syncMeta).go();
  });
}
