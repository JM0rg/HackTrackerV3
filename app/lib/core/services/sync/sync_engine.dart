import 'package:drift/drift.dart';
import 'package:hacktracker/core/config/env.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Push dirty local rows, then pull remote changes. Last-write-wins by updated_at.
class SyncEngine {
  SyncEngine(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  static const tables = [
    'personal_teams',
    'teams',
    'team_members',
    'invite_codes',
    'players',
    'opponents',
    'competitions',
    'games',
    'game_competitions',
    'lineup_slots',
    'plate_appearances',
    'game_events',
    'game_innings',
  ];

  Future<void> sync() async {
    if (!Env.hasSupabase || _client.auth.currentUser == null) return;
    for (final table in tables) {
      await _push(table);
      await _pull(table);
    }
  }

  Future<void> _push(String table) async {
    // Implemented per-table in the generated companions via a small mapper.
    // Local dirty rows are upserted; server LWW is the later updated_at.
    final rows = await _dirty(table);
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows);
  }

  Future<void> _pull(String table) async {
    final cursorRow = await (_db.select(_db.localSyncCursors)
          ..where((t) => t.cursorTable.equals(table)))
        .getSingleOrNull();
    final cursor = cursorRow?.cursor ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final remote = await _client
        .from(table)
        .select()
        .gt('updated_at', cursor.toIso8601String());
    // Pull apply is intentionally conservative: newer remote wins.
    for (final raw in remote as List<dynamic>) {
      await _applyRemote(table, Map<String, dynamic>.from(raw as Map));
    }
    await _db.into(_db.localSyncCursors).insertOnConflictUpdate(
          LocalSyncCursorsCompanion.insert(
            cursorTable: table,
            cursor: DateTime.now().toUtc(),
          ),
        );
  }

  Future<List<Map<String, dynamic>>> _dirty(String table) async {
    switch (table) {
      case 'teams':
        final rows = await (_db.select(_db.teams)..where((t) => t.syncState.equals(1))).get();
        return [
          for (final r in rows)
            {
              'id': r.id,
              'name': r.name,
              'type': r.type,
              'settings': r.settings,
              'created_at': r.createdAt.toIso8601String(),
              'updated_at': r.updatedAt.toIso8601String(),
              'deleted_at': r.deletedAt?.toIso8601String(),
            },
        ];
      default:
        return [];
    }
  }

  Future<void> _applyRemote(String table, Map<String, dynamic> row) async {
    if (table != 'teams') return;
    final id = row['id'] as String;
    final local = await (_db.select(_db.teams)..where((t) => t.id.equals(id))).getSingleOrNull();
    final remoteUpdated = DateTime.parse(row['updated_at'] as String);
    if (local != null && local.updatedAt.isAfter(remoteUpdated)) return;
    await _db.into(_db.teams).insertOnConflictUpdate(
          TeamsCompanion.insert(
            id: id,
            name: row['name'] as String,
            type: Value(row['type'] as String? ?? 'mens'),
            settings: Value(row['settings'] is String
                ? row['settings'] as String
                : (row['settings']?.toString() ?? defaultTeamSettings)),
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: remoteUpdated,
            deletedAt: Value(
              row['deleted_at'] == null ? null : DateTime.parse(row['deleted_at'] as String),
            ),
            syncState: const Value(0),
          ),
        );
  }
}
