import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `groups` table. Mirrors `TeamsSyncer`; `start_date`/`end_date` are
/// Postgres DATE columns, so they are sent/parsed as `yyyy-MM-dd`.
class GroupsSyncer extends TableSyncer {
  GroupsSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'groups';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.groups,
    )..where((g) => g.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(_db.groups)..where((g) => g.id.equals(row.id))).write(
        const GroupsCompanion(syncState: Value(SyncState.synced)),
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
      await _db.into(_db.groups).insertOnConflictUpdate(_fromJson(json));
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  /// Formats a [DateTime] as a bare `yyyy-MM-dd` date for a Postgres DATE column.
  static String? _toDate(DateTime? dt) {
    if (dt == null) return null;
    final local = dt.toUtc();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _fromDate(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String).toUtc();
  }

  Map<String, dynamic> _toJson(GroupRow row) => {
    'id': row.id,
    'team_id': row.teamId,
    'name': row.name,
    'group_type': row.groupType,
    'league_name': row.leagueName,
    'location': row.location,
    'start_date': _toDate(row.startDate),
    'end_date': _toDate(row.endDate),
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  GroupsCompanion _fromJson(Map<String, dynamic> json) => GroupsCompanion(
    id: Value(json['id'] as String),
    teamId: Value(json['team_id'] as String),
    name: Value(json['name'] as String),
    groupType: Value(json['group_type'] as String? ?? 'season'),
    leagueName: Value(json['league_name'] as String?),
    location: Value(json['location'] as String?),
    startDate: Value(_fromDate(json['start_date'])),
    endDate: Value(_fromDate(json['end_date'])),
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
