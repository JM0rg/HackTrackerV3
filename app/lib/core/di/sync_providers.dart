import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync/sync_engine.dart';
import '../services/sync/sync_status.dart';
import '../services/sync/table_syncer.dart';
import 'database_providers.dart';
import 'supabase_providers.dart';

/// The registered per-table syncers, in FK-dependency order. Defaults to empty
/// and is overridden in `main.dart` (the composition root) with the concrete
/// feature syncers — this keeps `core/` from importing `features/`.
final syncersProvider = Provider<List<TableSyncer>>((ref) => const []);

/// Current sync lifecycle. Drives the offline banner + status indicator.
final syncStatusProvider = NotifierProvider<SyncStatusController, SyncStatus>(
  SyncStatusController.new,
);

class SyncStatusController extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => SyncStatus.idle;

  void set(SyncStatus status) => state = status;
}

/// The app-wide sync engine. Feature repositories read this to request a sync
/// after a local write.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    db: ref.watch(appDatabaseProvider),
    remote: ref.watch(supabaseClientProvider),
    syncers: ref.watch(syncersProvider),
    onStatus: (status) => ref.read(syncStatusProvider.notifier).set(status),
  );
});
