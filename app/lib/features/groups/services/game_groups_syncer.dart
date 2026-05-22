import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `game_groups` join table. Mirrors `TeamsSyncer`; link add/remove
/// propagates as a soft-delete tombstone.
class GameGroupsSyncer extends TableSyncer {
  GameGroupsSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'game_groups';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.gameGroups,
    )..where((gg) => gg.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(_db.gameGroups)..where((gg) => gg.id.equals(row.id)))
          .write(const GameGroupsCompanion(syncState: Value(SyncState.synced)));
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
      await _db.into(_db.gameGroups).insertOnConflictUpdate(_fromJson(json));
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  Map<String, dynamic> _toJson(GameGroupRow row) => {
    'id': row.id,
    'game_id': row.gameId,
    'group_id': row.groupId,
    'team_id': row.teamId,
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  GameGroupsCompanion _fromJson(Map<String, dynamic> json) =>
      GameGroupsCompanion(
        id: Value(json['id'] as String),
        gameId: Value(json['game_id'] as String),
        groupId: Value(json['group_id'] as String),
        teamId: Value(json['team_id'] as String),
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
