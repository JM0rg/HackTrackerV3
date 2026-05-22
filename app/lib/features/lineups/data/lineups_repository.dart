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
import '../domain/lineup.dart';

/// Drift-only persistence for lineups and their batting slots. Same
/// offline-first contract as teams: local write, dirty flag, sync nudge.
class LineupsRepository {
  LineupsRepository(this._db, this._sync);

  final AppDatabase _db;
  final SyncEngine _sync;

  /// Returns the existing lineup id for [gameId], creating one if none exists.
  Future<String> ensureLineupForGame({
    required String gameId,
    required String teamId,
  }) async {
    final existing =
        await (_db.select(_db.lineups)
              ..where((l) => l.gameId.equals(gameId) & l.deletedAt.isNull()))
            .getSingleOrNull();
    if (existing != null) return existing.id;

    final id = Uuid.v4();
    await _db
        .into(_db.lineups)
        .insert(
          LineupsCompanion.insert(
            id: Value(id),
            gameId: gameId,
            teamId: teamId,
            syncState: const Value(SyncState.pendingCreate),
          ),
        );
    unawaited(_sync.requestSync());
    return id;
  }

  Stream<List<LineupSlot>> watchSlots(String lineupId) {
    final query = _db.select(_db.lineupSlots)
      ..where((s) => s.lineupId.equals(lineupId) & s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm(expression: s.battingOrder)]);
    return query.watch().map((rows) => rows.map(_toSlotDomain).toList());
  }

  Future<Result<void>> addSlot({
    required String lineupId,
    required String teamId,
    required String playerId,
    required int battingOrder,
    String? fieldPosition,
  }) {
    return _guard(() async {
      await _db
          .into(_db.lineupSlots)
          .insert(
            LineupSlotsCompanion.insert(
              id: Value(Uuid.v4()),
              lineupId: lineupId,
              teamId: teamId,
              playerId: playerId,
              battingOrder: battingOrder,
              fieldPosition: Value(fieldPosition),
              syncState: const Value(SyncState.pendingCreate),
            ),
          );
    });
  }

  Future<Result<void>> updateSlotPosition(
    String slotId,
    String? fieldPosition,
  ) {
    return _guard(() async {
      await (_db.update(
        _db.lineupSlots,
      )..where((s) => s.id.equals(slotId))).write(
        LineupSlotsCompanion(
          fieldPosition: Value(fieldPosition),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingUpdate),
        ),
      );
    });
  }

  Future<Result<void>> setBattingOrder(String slotId, int order) {
    return _guard(() async {
      await (_db.update(
        _db.lineupSlots,
      )..where((s) => s.id.equals(slotId))).write(
        LineupSlotsCompanion(
          battingOrder: Value(order),
          updatedAt: Value(DateTime.now().toUtc()),
          syncState: const Value(SyncState.pendingUpdate),
        ),
      );
    });
  }

  Future<Result<void>> removeSlot(String slotId) {
    return _guard(() async {
      await (_db.update(
        _db.lineupSlots,
      )..where((s) => s.id.equals(slotId))).write(
        LineupSlotsCompanion(
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
      AppLogger.error('Lineups write failed', e, stack);
      return const Result.err(DatabaseFailure('Could not save lineup'));
    }
  }

  LineupSlot _toSlotDomain(LineupSlotRow row) => LineupSlot(
    id: row.id,
    lineupId: row.lineupId,
    teamId: row.teamId,
    playerId: row.playerId,
    battingOrder: row.battingOrder,
    fieldPosition: row.fieldPosition,
  );
}

final lineupsRepositoryProvider = Provider<LineupsRepository>((ref) {
  return LineupsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  );
});

final lineupSlotsProvider = StreamProvider.family<List<LineupSlot>, String>((
  ref,
  lineupId,
) {
  return ref.watch(lineupsRepositoryProvider).watchSlots(lineupId);
});
