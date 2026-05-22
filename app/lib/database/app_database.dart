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
}
