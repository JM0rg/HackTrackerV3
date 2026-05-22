import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `lineups` table. Mirrors `TeamsSyncer`.
class LineupsSyncer extends TableSyncer {
  LineupsSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'lineups';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.lineups,
    )..where((l) => l.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(_db.lineups)..where((l) => l.id.equals(row.id))).write(
        const LineupsCompanion(syncState: Value(SyncState.synced)),
      );
    }
  }

  @override
  Future<DateTime?> pull(SupabaseClient remote, DateTime? since) async {
    var query = remote.from(table).select();
    if (since != null) {
      query = query.gt('updated_at', since.toIso8601String());
    }
    final rows = await query;

    var newest = since;
    for (final json in rows) {
      await _db.into(_db.lineups).insertOnConflictUpdate(_fromJson(json));
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  Map<String, dynamic> _toJson(LineupRow row) => {
    'id': row.id,
    'game_id': row.gameId,
    'team_id': row.teamId,
    'name': row.name,
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  LineupsCompanion _fromJson(Map<String, dynamic> json) => LineupsCompanion(
    id: Value(json['id'] as String),
    gameId: Value(json['game_id'] as String),
    teamId: Value(json['team_id'] as String),
    name: Value(json['name'] as String?),
    createdAt: Value(DateTime.parse(json['created_at'] as String).toUtc()),
    updatedAt: Value(DateTime.parse(json['updated_at'] as String).toUtc()),
    deletedAt: Value(
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String).toUtc(),
    ),
    syncState: const Value(SyncState.synced),
  );
}
