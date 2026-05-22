// Catches: the conflict policy silently flipping — a clean local row must
// always accept remote, and a dirty local row must only yield to a strictly
// newer remote (otherwise local edits get clobbered or stale remotes win).
import 'package:app/core/services/sync/lww_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final older = DateTime.utc(2026, 5, 1);
  final newer = DateTime.utc(2026, 5, 2);

  test('clean local always accepts the remote row', () {
    expect(
      LwwResolver.remoteWins(
        remoteUpdatedAt: older,
        localUpdatedAt: newer,
        localIsDirty: false,
      ),
      isTrue,
    );
  });

  test('dirty local yields only to a strictly newer remote', () {
    expect(
      LwwResolver.remoteWins(
        remoteUpdatedAt: newer,
        localUpdatedAt: older,
        localIsDirty: true,
      ),
      isTrue,
    );
    expect(
      LwwResolver.remoteWins(
        remoteUpdatedAt: older,
        localUpdatedAt: newer,
        localIsDirty: true,
      ),
      isFalse,
    );
    expect(
      LwwResolver.remoteWins(
        remoteUpdatedAt: older,
        localUpdatedAt: older,
        localIsDirty: true,
      ),
      isFalse,
    );
  });
}
