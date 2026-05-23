import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/sync/sync_state.dart';
import '../../../core/services/sync/table_syncer.dart';
import '../../../database/app_database.dart';

/// Syncs the `profiles` table. Mirrors the teams/players syncer pattern.
class ProfilesSyncer extends TableSyncer {
  ProfilesSyncer(this._db);

  final AppDatabase _db;

  @override
  String get table => 'profiles';

  @override
  Future<void> push(SupabaseClient remote) async {
    final dirty = await (_db.select(
      _db.profiles,
    )..where((p) => p.syncState.equalsValue(SyncState.synced).not())).get();

    for (final row in dirty) {
      await remote.from(table).upsert(_toJson(row));
      await (_db.update(_db.profiles)..where((p) => p.id.equals(row.id))).write(
        const ProfilesCompanion(syncState: Value(SyncState.synced)),
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
      await _db.into(_db.profiles).insertOnConflictUpdate(_fromJson(json));
      final updatedAt = DateTime.parse(json['updated_at'] as String).toUtc();
      if (newest == null || updatedAt.isAfter(newest)) newest = updatedAt;
    }
    return newest;
  }

  Map<String, dynamic> _toJson(ProfileRow row) => {
    'id': row.id,
    'display_name': row.displayName,
    'avatar_path': row.avatarPath,
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
  };

  ProfilesCompanion _fromJson(Map<String, dynamic> json) => ProfilesCompanion(
    id: Value(json['id'] as String),
    displayName: Value(json['display_name'] as String?),
    avatarPath: Value(json['avatar_path'] as String?),
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
