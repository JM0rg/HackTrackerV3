import 'dart:async';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../database/app_database.dart';
import '../app_logger.dart';
import 'sync_status.dart';
import 'table_syncer.dart';

/// Reconciles the local Drift database with Supabase. Push (local→remote) runs
/// across all tables in FK order, then pull (remote→local) per table using an
/// incremental `updated_at` cursor persisted in `sync_meta`.
///
/// [requestSync] is debounced and single-flighted: overlapping triggers
/// (connectivity, foreground, post-write, pull-to-refresh) collapse into one
/// in-flight cycle, with at most one more queued behind it.
class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required SupabaseClient remote,
    required List<TableSyncer> syncers,
    required void Function(SyncStatus status) onStatus,
  }) : _db = db,
       _remote = remote,
       _syncers = syncers,
       _onStatus = onStatus;

  final AppDatabase _db;
  final SupabaseClient _remote;
  final List<TableSyncer> _syncers;
  final void Function(SyncStatus status) _onStatus;

  Future<void>? _inFlight;
  bool _rerunRequested = false;

  /// Schedule a sync cycle. Returns when the relevant cycle completes.
  Future<void> requestSync() {
    if (_inFlight != null) {
      _rerunRequested = true;
      return _inFlight!;
    }
    final future = _runLoop();
    _inFlight = future;
    return future;
  }

  Future<void> _runLoop() async {
    try {
      do {
        _rerunRequested = false;
        await _runCycle();
      } while (_rerunRequested);
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _runCycle() async {
    if (_remote.auth.currentUser == null) {
      _onStatus(SyncStatus.idle);
      return;
    }
    _onStatus(SyncStatus.syncing);
    try {
      for (final syncer in _syncers) {
        await syncer.push(_remote);
      }
      for (final syncer in _syncers) {
        final since = await _readCursor(syncer.table);
        final newest = await syncer.pull(_remote, since);
        if (newest != null) await _writeCursor(syncer.table, newest);
      }
      _onStatus(SyncStatus.idle);
    } catch (error, stack) {
      AppLogger.error('Sync cycle failed', error, stack);
      _onStatus(SyncStatus.error);
    }
  }

  Future<DateTime?> _readCursor(String table) async {
    final row = await (_db.select(
      _db.syncMeta,
    )..where((t) => t.tableKey.equals(table))).getSingleOrNull();
    return row?.lastPulledAt;
  }

  Future<void> _writeCursor(String table, DateTime value) {
    return _db
        .into(_db.syncMeta)
        .insertOnConflictUpdate(
          SyncMetaCompanion.insert(tableKey: table, lastPulledAt: Value(value)),
        );
  }
}
