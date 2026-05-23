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
import '../domain/team.dart';

/// Drift-only persistence for teams. Writes set the dirty [SyncState] and an
/// upbumped `updated_at`, then nudge the [SyncEngine] — they never await the
/// network, so they succeed offline.
class TeamsRepository {
  TeamsRepository(this._db, this._sync);

  final AppDatabase _db;
  final SyncEngine _sync;

  Stream<List<Team>> watchAll() {
    final query = _db.select(_db.teams)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<Team?> watchOne(String id) {
    final query = _db.select(_db.teams)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map(
      (r) => r == null ? null : _toDomain(r),
    );
  }

  Future<Result<String>> create({
    required String name,
    required TeamType teamType,
    required String ownerId,
    String? primaryColor,
    String? secondaryColor,
  }) async {
    return _guard(() async {
      final id = Uuid.v4();
      await _db
          .into(_db.teams)
          .insert(
            TeamsCompanion.insert(
              id: Value(id),
              name: name,
              teamType: Value(teamType.code),
              ownerId: ownerId,
              primaryColor: Value(primaryColor),
              secondaryColor: Value(secondaryColor),
              syncState: const Value(SyncState.pendingCreate),
            ),
          );
      return id;
    });
  }

  Future<Result<void>> update(
    String id, {
    required String name,
    required TeamType teamType,
    String? primaryColor,
    String? secondaryColor,
  }) async {
    return _guard(() async {
      await (_db.update(_db.teams)..where((t) => t.id.equals(id))).write(
        TeamsCompanion(
          name: Value(name),
          teamType: Value(teamType.code),
          primaryColor: Value(primaryColor),
          secondaryColor: Value(secondaryColor),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingUpdate),
        ),
      );
    });
  }

  Future<Result<void>> softDelete(String id) async {
    return _guard(() async {
      await (_db.update(_db.teams)..where((t) => t.id.equals(id))).write(
        TeamsCompanion(
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
      AppLogger.error('Teams write failed', e, stack);
      return const Result.err(DatabaseFailure('Could not save team'));
    }
  }

  Team _toDomain(TeamRow row) => Team(
    id: row.id,
    name: row.name,
    teamType: TeamType.fromCode(row.teamType),
    logoPath: row.logoPath,
    primaryColor: row.primaryColor,
    secondaryColor: row.secondaryColor,
  );
}

final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  return TeamsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final teamsStreamProvider = StreamProvider<List<Team>>((ref) {
  return ref.watch(teamsRepositoryProvider).watchAll();
});

final teamStreamProvider = StreamProvider.family<Team?, String>((ref, id) {
  return ref.watch(teamsRepositoryProvider).watchOne(id);
});

/// User's explicit team selection from the team dropdown. Null means "pick
/// the first one for me." In-memory; resets to first team on app restart.
class TeamSelectionController extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String teamId) => state = teamId;
}

final teamSelectionProvider =
    NotifierProvider<TeamSelectionController, String?>(
      TeamSelectionController.new,
    );

/// The id of the currently active team — the user's explicit pick if it
/// still exists, otherwise the first team in the list, otherwise null.
final currentTeamIdProvider = Provider<String?>((ref) {
  final teams = ref.watch(teamsStreamProvider).value;
  if (teams == null || teams.isEmpty) return null;
  final selected = ref.watch(teamSelectionProvider);
  if (selected != null && teams.any((t) => t.id == selected)) return selected;
  return teams.first.id;
});

/// The currently active [Team] object, or null when none is selected.
final currentTeamProvider = Provider<Team?>((ref) {
  final id = ref.watch(currentTeamIdProvider);
  if (id == null) return null;
  final teams = ref.watch(teamsStreamProvider).value;
  return teams?.where((t) => t.id == id).firstOrNull;
});
