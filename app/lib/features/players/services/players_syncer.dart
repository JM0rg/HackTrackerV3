import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `players` table. Mirrors `TeamsSyncer`; the only differences are
/// the column set and the `text[]` default-positions field.
class PlayersSyncer extends TableSyncer {
  PlayersSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'players';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.players,
    )..where((p) => p.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(_db.players)..where((p) => p.id.equals(row.id))).write(
        const PlayersCompanion(syncState: Value(SyncState.synced)),
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
      await _db.into(_db.players).insertOnConflictUpdate(_fromJson(json));
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  Map<String, dynamic> _toJson(PlayerRow row) => {
    'id': row.id,
    'team_id': row.teamId,
    'name': row.name,
    'jersey_number': row.jerseyNumber,
    'throws': row.throws,
    'bats': row.bats,
    'gender': row.gender,
    'status': row.status,
    'default_positions': row.defaultPositions,
    'phone': row.phone,
    'email': row.email,
    'linked_user_id': row.linkedUserId,
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  PlayersCompanion _fromJson(Map<String, dynamic> json) => PlayersCompanion(
    id: Value(json['id'] as String),
    teamId: Value(json['team_id'] as String),
    name: Value(json['name'] as String),
    jerseyNumber: Value(json['jersey_number'] as String?),
    throws: Value(json['throws'] as String?),
    bats: Value(json['bats'] as String?),
    gender: Value(json['gender'] as String?),
    status: Value(json['status'] as String? ?? 'full_time'),
    defaultPositions: Value(
      (json['default_positions'] as List<dynamic>? ?? const []).cast<String>(),
    ),
    phone: Value(json['phone'] as String?),
    email: Value(json['email'] as String?),
    linkedUserId: Value(json['linked_user_id'] as String?),
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
