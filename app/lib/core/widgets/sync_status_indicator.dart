import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/sync_providers.dart';
import '../services/sync/sync_status.dart';
import '../theme/theme_context_extensions.dart';

/// Compact sync-state glyph, intended for an app-bar action. Informational —
/// tapping requests a sync but the UI never blocks on it.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final colors = context.colors;

    final (icon, color) = switch (status) {
      SyncStatus.idle => (Icons.cloud_done_outlined, colors.secondaryText),
      SyncStatus.syncing => (Icons.cloud_sync_outlined, colors.primary),
      SyncStatus.offline => (Icons.cloud_off_outlined, colors.secondaryText),
      SyncStatus.error => (Icons.cloud_off_outlined, colors.danger),
    };

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: 'Sync: ${status.name}',
      onPressed: () => ref.read(syncEngineProvider).requestSync(),
    );
  }
}
