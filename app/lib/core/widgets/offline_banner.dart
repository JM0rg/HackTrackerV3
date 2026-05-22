import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/sync_providers.dart';
import '../services/connectivity_service.dart';
import '../services/sync/sync_status.dart';
import '../theme/theme_context_extensions.dart';

/// Thin banner shown when the device is offline or the last sync errored. Place
/// it above scaffolded content; it collapses to nothing when all is well.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).value ?? true;
    final status = ref.watch(syncStatusProvider);
    final colors = context.colors;
    final spacing = context.themeSpacing;

    final (visible, message, color) = !online
        ? (
            true,
            'Offline — changes save locally and sync later',
            colors.secondaryText,
          )
        : status == SyncStatus.error
        ? (true, 'Sync failed — will retry', colors.danger)
        : (false, '', colors.secondaryText);

    if (!visible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.12),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: context.text.caption.copyWith(color: color),
      ),
    );
  }
}
