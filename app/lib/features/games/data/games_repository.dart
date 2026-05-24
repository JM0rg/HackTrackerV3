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
import '../domain/game.dart';
import '../domain/game_result.dart';

/// Drift-only persistence for games. Same offline-first contract as teams:
/// local write, dirty flag, sync nudge. The W/L/T [result] is computed locally
/// on every write (the server stores it as a generated column).
class GamesRepository {
  GamesRepository(this._db, this._sync);

  final AppDatabase _db;
  final SyncEngine _sync;

  Stream<List<Game>> watchAll() {
    final query = _db.select(_db.games)
      ..where((g) => g.deletedAt.isNull())
      ..orderBy([
        (g) => OrderingTerm(expression: g.startTime, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<List<Game>> watchForTeam(String teamId) {
    final query = _db.select(_db.games)
      ..where((g) => g.teamId.equals(teamId) & g.deletedAt.isNull())
      ..orderBy([
        (g) => OrderingTerm(expression: g.startTime, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<Game?> watchOne(String id) {
    final query = _db.select(_db.games)..where((g) => g.id.equals(id));
    return query.watchSingleOrNull().map(
      (r) => r == null ? null : _toDomain(r),
    );
  }

  Future<Result<String>> create({
    required String teamId,
    required HomeAway homeAway,
    required GameStatus status,
    String? opponentName,
    String? parkName,
    String? cityOrAddress,
    DateTime? startTime,
    int? ourScore,
    int? oppScore,
    String? notes,
  }) async {
    return _guard(() async {
      final id = Uuid.v4();
      await _db
          .into(_db.games)
          .insert(
            GamesCompanion.insert(
              id: Value(id),
              teamId: teamId,
              opponentName: Value(opponentName),
              parkName: Value(parkName),
              cityOrAddress: Value(cityOrAddress),
              startTime: Value(startTime),
              homeAway: Value(homeAway.code),
              status: Value(status.code),
              ourScore: Value(ourScore),
              oppScore: Value(oppScore),
              result: Value(
                computeGameResult(
                  status: status,
                  ourScore: ourScore,
                  oppScore: oppScore,
                ),
              ),
              notes: Value(notes),
              syncState: const Value(SyncState.pendingCreate),
            ),
          );
      return id;
    });
  }

  Future<Result<void>> update(
    String id, {
    required HomeAway homeAway,
    required GameStatus status,
    String? opponentName,
    String? parkName,
    String? cityOrAddress,
    DateTime? startTime,
    int? ourScore,
    int? oppScore,
    String? notes,
  }) async {
    return _guard(() async {
      await (_db.update(_db.games)..where((g) => g.id.equals(id))).write(
        GamesCompanion(
          opponentName: Value(opponentName),
          parkName: Value(parkName),
          cityOrAddress: Value(cityOrAddress),
          startTime: Value(startTime),
          homeAway: Value(homeAway.code),
          status: Value(status.code),
          ourScore: Value(ourScore),
          oppScore: Value(oppScore),
          result: Value(
            computeGameResult(
              status: status,
              ourScore: ourScore,
              oppScore: oppScore,
            ),
          ),
          notes: Value(notes),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingUpdate),
        ),
      );
    });
  }

  Future<Result<void>> softDelete(String id) async {
    return _guard(() async {
      await (_db.update(_db.games)..where((g) => g.id.equals(id))).write(
        GamesCompanion(
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
      AppLogger.error('Games write failed', e, stack);
      return const Result.err(DatabaseFailure('Could not save game'));
    }
  }

  Game _toDomain(GameRow row) => Game(
    id: row.id,
    teamId: row.teamId,
    homeAway: HomeAway.fromCode(row.homeAway),
    status: GameStatus.fromCode(row.status),
    opponentName: row.opponentName,
    parkName: row.parkName,
    cityOrAddress: row.cityOrAddress,
    startTime: row.startTime,
    ourScore: row.ourScore,
    oppScore: row.oppScore,
    result: row.result,
    notes: row.notes,
  );
}

final gamesRepositoryProvider = Provider<GamesRepository>((ref) {
  return GamesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final gamesStreamProvider = StreamProvider<List<Game>>((ref) {
  return ref.watch(gamesRepositoryProvider).watchAll();
});

final gamesForTeamProvider = StreamProvider.family<List<Game>, String>((
  ref,
  teamId,
) {
  return ref.watch(gamesRepositoryProvider).watchForTeam(teamId);
});

final gameStreamProvider = StreamProvider.family<Game?, String>((ref, id) {
  return ref.watch(gamesRepositoryProvider).watchOne(id);
});
