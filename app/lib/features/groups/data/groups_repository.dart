import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/database_providers.dart';
import '../../../core/di/sync_providers.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/services/app_logger.dart';
import '../../../core/services/sync/sync_engine.dart';
import '../../../core/services/sync/sync_state.dart';
import '../../../core/utils/uuid.dart';
import '../../../database/app_database.dart';
import '../domain/group.dart';

/// Drift-only persistence for groups (seasons/tournaments) plus the
/// game↔group many-to-many link table. Same offline-first contract as teams.
class GroupsRepository {
  GroupsRepository(this._db, this._sync);

  final AppDatabase _db;
  final SyncEngine _sync;

  Stream<List<Group>> watchAll() {
    final query = _db.select(_db.groups)
      ..where((g) => g.deletedAt.isNull())
      ..orderBy([(g) => OrderingTerm(expression: g.name)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<List<Group>> watchForTeam(String teamId) {
    final query = _db.select(_db.groups)
      ..where((g) => g.teamId.equals(teamId) & g.deletedAt.isNull())
      ..orderBy([(g) => OrderingTerm(expression: g.name)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<Group?> watchOne(String id) {
    final query = _db.select(_db.groups)..where((g) => g.id.equals(id));
    return query.watchSingleOrNull().map(
      (r) => r == null ? null : _toDomain(r),
    );
  }

  /// The set of game ids currently linked to [groupId] (excludes tombstones).
  Stream<Set<String>> watchGameIdsForGroup(String groupId) {
    final query = _db.select(_db.gameGroups)
      ..where((gg) => gg.groupId.equals(groupId) & gg.deletedAt.isNull());
    return query.watch().map((rows) => rows.map((r) => r.gameId).toSet());
  }

  Future<Result<String>> create({
    required String teamId,
    required String name,
    required GroupType groupType,
    String? leagueName,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _guard(() async {
      final id = Uuid.v4();
      await _db
          .into(_db.groups)
          .insert(
            GroupsCompanion.insert(
              id: Value(id),
              teamId: teamId,
              name: name,
              groupType: groupType.code,
              leagueName: Value(leagueName),
              location: Value(location),
              startDate: Value(startDate),
              endDate: Value(endDate),
              syncState: const Value(SyncState.pendingCreate),
            ),
          );
      return id;
    });
  }

  Future<Result<void>> update(
    String id, {
    required String name,
    required GroupType groupType,
    String? leagueName,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _guard(() async {
      await (_db.update(_db.groups)..where((g) => g.id.equals(id))).write(
        GroupsCompanion(
          name: Value(name),
          groupType: Value(groupType.code),
          leagueName: Value(leagueName),
          location: Value(location),
          startDate: Value(startDate),
          endDate: Value(endDate),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingUpdate),
        ),
      );
    });
  }

  Future<Result<void>> softDelete(String id) async {
    return _guard(() async {
      await (_db.update(_db.groups)..where((g) => g.id.equals(id))).write(
        GroupsCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingDelete),
        ),
      );
    });
  }

  Future<Result<void>> linkGame({
    required String gameId,
    required String groupId,
    required String teamId,
  }) async {
    return _guard(() async {
      await _db
          .into(_db.gameGroups)
          .insert(
            GameGroupsCompanion.insert(
              id: Value(Uuid.v4()),
              gameId: gameId,
              groupId: groupId,
              teamId: teamId,
              syncState: const Value(SyncState.pendingCreate),
            ),
          );
    });
  }

  Future<Result<void>> unlinkGame({
    required String gameId,
    required String groupId,
  }) async {
    return _guard(() async {
      await (_db.update(_db.gameGroups)..where(
            (gg) =>
                gg.gameId.equals(gameId) &
                gg.groupId.equals(groupId) &
                gg.deletedAt.isNull(),
          ))
          .write(
            GameGroupsCompanion(
              deletedAt: Value(DateTime.now().toUtc()),
              updatedAt: Value(DateTime.now().toUtc()),
              syncState: const Value(SyncState.pendingDelete),
            ),
          );
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      final value = await action();
      unawaited(_sync.requestSync());
      return Result.ok(value);
    } catch (e, stack) {
      AppLogger.error('Groups write failed', e, stack);
      return const Result.err(DatabaseFailure('Could not save group'));
    }
  }

  Group _toDomain(GroupRow row) => Group(
    id: row.id,
    teamId: row.teamId,
    name: row.name,
    groupType: GroupType.fromCode(row.groupType),
    leagueName: row.leagueName,
    location: row.location,
    startDate: row.startDate,
    endDate: row.endDate,
  );
}

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final groupsStreamProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(groupsRepositoryProvider).watchAll();
});

final groupsForTeamProvider = StreamProvider.family<List<Group>, String>((
  ref,
  teamId,
) {
  return ref.watch(groupsRepositoryProvider).watchForTeam(teamId);
});

final groupStreamProvider = StreamProvider.family<Group?, String>((ref, id) {
  return ref.watch(groupsRepositoryProvider).watchOne(id);
});

final groupGameIdsProvider = StreamProvider.family<Set<String>, String>((
  ref,
  groupId,
) {
  return ref.watch(groupsRepositoryProvider).watchGameIdsForGroup(groupId);
});
