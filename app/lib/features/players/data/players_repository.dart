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
import '../domain/player.dart';

/// Drift-only persistence for roster players. Same offline-first contract as
/// teams: local write, dirty flag, sync nudge.
class PlayersRepository {
  PlayersRepository(this._db, this._sync);

  final AppDatabase _db;
  final SyncEngine _sync;

  Stream<List<Player>> watchForTeam(String teamId) {
    final query = _db.select(_db.players)
      ..where((p) => p.teamId.equals(teamId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm(expression: p.name)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<Result<void>> create({
    required String teamId,
    required String name,
    required PlayerStatus status,
    String? jerseyNumber,
    Handedness? throws,
    BattingSide? bats,
    String? gender,
    List<String> defaultPositions = const [],
    String? phone,
    String? email,
  }) {
    return _guard(() async {
      await _db
          .into(_db.players)
          .insert(
            PlayersCompanion.insert(
              id: Value(Uuid.v4()),
              teamId: teamId,
              name: name,
              status: Value(status.code),
              jerseyNumber: Value(jerseyNumber),
              throws: Value(throws?.code),
              bats: Value(bats?.code),
              gender: Value(gender),
              defaultPositions: Value(defaultPositions),
              phone: Value(phone),
              email: Value(email),
              syncState: const Value(SyncState.pendingCreate),
            ),
          );
    });
  }

  Future<Result<void>> update(
    String id, {
    required String name,
    required PlayerStatus status,
    String? jerseyNumber,
    Handedness? throws,
    BattingSide? bats,
    String? gender,
    List<String> defaultPositions = const [],
    String? phone,
    String? email,
  }) {
    return _guard(() async {
      await (_db.update(_db.players)..where((p) => p.id.equals(id))).write(
        PlayersCompanion(
          name: Value(name),
          status: Value(status.code),
          jerseyNumber: Value(jerseyNumber),
          throws: Value(throws?.code),
          bats: Value(bats?.code),
          gender: Value(gender),
          defaultPositions: Value(defaultPositions),
          phone: Value(phone),
          email: Value(email),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingUpdate),
        ),
      );
    });
  }

  Future<Result<void>> softDelete(String id) {
    return _guard(() async {
      await (_db.update(_db.players)..where((p) => p.id.equals(id))).write(
        PlayersCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingDelete),
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
      AppLogger.error('Players write failed', e, stack);
      return const Result.err(DatabaseFailure('Could not save player'));
    }
  }

  Player _toDomain(PlayerRow row) => Player(
    id: row.id,
    teamId: row.teamId,
    name: row.name,
    status: PlayerStatus.fromCode(row.status),
    defaultPositions: row.defaultPositions,
    jerseyNumber: row.jerseyNumber,
    throws: Handedness.fromCode(row.throws),
    bats: BattingSide.fromCode(row.bats),
    gender: row.gender,
    phone: row.phone,
    email: row.email,
  );
}

final playersRepositoryProvider = Provider<PlayersRepository>((ref) {
  return PlayersRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final playersForTeamProvider = StreamProvider.family<List<Player>, String>((
  ref,
  teamId,
) {
  return ref.watch(playersRepositoryProvider).watchForTeam(teamId);
});
