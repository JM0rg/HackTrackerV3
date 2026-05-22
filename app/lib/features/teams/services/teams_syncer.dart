import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `teams` table. This is the reference implementation every other
/// [TableSyncer] mirrors: push dirty rows as upserts (soft-delete included),
/// then pull rows changed since the cursor and upsert them locally as clean.
class TeamsSyncer extends TableSyncer {
  TeamsSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'teams';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.teams,
    )..where((t) => t.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(_db.teams)..where((t) => t.id.equals(row.id))).write(
        const TeamsCompanion(syncState: Value(SyncState.synced)),
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
      final companion = _fromJson(json);
      await _db.into(_db.teams).insertOnConflictUpdate(companion);
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  Map<String, dynamic> _toJson(TeamRow row) => {
    'id': row.id,
    'name': row.name,
    'team_type': row.teamType,
    'logo_path': row.logoPath,
    'primary_color': row.primaryColor,
    'secondary_color': row.secondaryColor,
    'owner_id': row.ownerId,
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  TeamsCompanion _fromJson(Map<String, dynamic> json) => TeamsCompanion(
    id: Value(json['id'] as String),
    name: Value(json['name'] as String),
    teamType: Value(json['team_type'] as String? ?? 'coed'),
    logoPath: Value(json['logo_path'] as String?),
    primaryColor: Value(json['primary_color'] as String?),
    secondaryColor: Value(json['secondary_color'] as String?),
    ownerId: Value(json['owner_id'] as String),
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
