import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `games` table. Mirrors `TeamsSyncer`. The server `result` column
/// is GENERATED, so it is read on pull but never pushed.
class GamesSyncer extends TableSyncer {
  GamesSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'games';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.games,
    )..where((g) => g.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(_db.games)..where((g) => g.id.equals(row.id))).write(
        const GamesCompanion(syncState: Value(SyncState.synced)),
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
      await _db.into(_db.games).insertOnConflictUpdate(_fromJson(json));
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  // `result` is intentionally omitted — it is a generated column server-side.
  Map<String, dynamic> _toJson(GameRow row) => {
    'id': row.id,
    'team_id': row.teamId,
    'opponent_name': row.opponentName,
    'park_name': row.parkName,
    'city_or_address': row.cityOrAddress,
    'start_time': row.startTime?.toUtc().toIso8601String(),
    'home_away': row.homeAway,
    'status': row.status,
    'our_score': row.ourScore,
    'opp_score': row.oppScore,
    'notes': row.notes,
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  GamesCompanion _fromJson(Map<String, dynamic> json) => GamesCompanion(
    id: Value(json['id'] as String),
    teamId: Value(json['team_id'] as String),
    opponentName: Value(json['opponent_name'] as String?),
    parkName: Value(json['park_name'] as String?),
    cityOrAddress: Value(json['city_or_address'] as String?),
    startTime: Value(
      json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String).toUtc(),
    ),
    homeAway: Value(json['home_away'] as String? ?? 'home'),
    status: Value(json['status'] as String? ?? 'scheduled'),
    ourScore: Value(json['our_score'] as int?),
    oppScore: Value(json['opp_score'] as int?),
    result: Value(json['result'] as String?),
    notes: Value(json['notes'] as String?),
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
