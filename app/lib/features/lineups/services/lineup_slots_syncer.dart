import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `lineup_slots` table. Mirrors `TeamsSyncer`.
class LineupSlotsSyncer extends TableSyncer {
  LineupSlotsSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'lineup_slots';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.lineupSlots,
    )..where((s) => s.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(
        _db.lineupSlots,
      )..where((s) => s.id.equals(row.id))).write(
        const LineupSlotsCompanion(syncState: Value(SyncState.synced)),
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
      await _db.into(_db.lineupSlots).insertOnConflictUpdate(_fromJson(json));
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  Map<String, dynamic> _toJson(LineupSlotRow row) => {
    'id': row.id,
    'lineup_id': row.lineupId,
    'team_id': row.teamId,
    'player_id': row.playerId,
    'batting_order': row.battingOrder,
    'field_position': row.fieldPosition,
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  LineupSlotsCompanion _fromJson(Map<String, dynamic> json) =>
      LineupSlotsCompanion(
        id: Value(json['id'] as String),
        lineupId: Value(json['lineup_id'] as String),
        teamId: Value(json['team_id'] as String),
        playerId: Value(json['player_id'] as String),
        battingOrder: Value(json['batting_order'] as int),
        fieldPosition: Value(json['field_position'] as String?),
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
