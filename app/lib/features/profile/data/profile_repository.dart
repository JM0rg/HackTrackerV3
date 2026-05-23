import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/database_providers.dart';
import '../../../core/di/supabase_providers.dart';
import '../../../core/di/sync_providers.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/sync/sync_engine.dart';
import '../../../core/services/sync/sync_state.dart';
import '../../../database/app_database.dart';
import '../domain/profile.dart';

/// Drift-only persistence for the user's [Profile]. The canonical row is
/// created server-side by the `handle_new_user` trigger on signup and pulled
/// down by the sync engine; this repo handles offline writes to display name
/// and (later) avatar via the same dirty-flag contract as every other table.
class ProfilesRepository {
  ProfilesRepository(this._db, this._sync);

  final AppDatabase _db;
  final SyncEngine _sync;

  Stream<Profile?> _watchById(String id) {
    final query = _db.select(_db.profiles)..where((p) => p.id.equals(id));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toDomain(row),
    );
  }

  /// Inserts or updates the local row for [id] with the given display name.
  /// Uses upsert so a brand-new sign-in (where the server-created row hasn't
  /// synced down yet) doesn't fail.
  Future<Result<void>> setDisplayName({
    required String id,
    required String displayName,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty) {
      return const Result.err(ValidationFailure('Please enter a name'));
    }
    return _guard(() async {
      final now = DateTime.now().toUtc();
      await _db
          .into(_db.profiles)
          .insertOnConflictUpdate(
            ProfilesCompanion(
              id: Value(id),
              displayName: Value(name),
              updatedAt: Value(now),
              syncState: const Value(SyncState.pendingUpdate),
            ),
          );
    });
  }

  Future<Result<void>> _guard(Future<void> Function() action) async {
    try {
      await action();
      unawaited(_sync.requestSync());
      return const Result.ok(null);
    } catch (e, stack) {
      AppLogger.error('Profile write failed', e, stack);
      return const Result.err(DatabaseFailure('Could not save profile'));
    }
  }

  Profile _toDomain(ProfileRow row) => Profile(
    id: row.id,
    displayName: row.displayName,
    avatarPath: row.avatarPath,
  );
}

final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  return ProfilesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

/// The signed-in user's profile, or null when signed out or not yet synced.
final myProfileProvider = StreamProvider<Profile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);
  return ref.watch(profilesRepositoryProvider)._watchById(userId);
});
