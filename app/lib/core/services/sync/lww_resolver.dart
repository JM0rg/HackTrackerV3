/// Last-write-wins conflict policy, keyed on `updated_at`. When a pulled remote
/// row and a locally-dirty row disagree, the newer timestamp wins.
///
/// Known MVP limitation: resolution is whole-row, so two devices editing
/// different fields of the same row concurrently can drop one field. Acceptable
/// for v1 (a team's data is effectively single-writer).
abstract final class LwwResolver {
  /// True when the remote row should overwrite the local row.
  static bool remoteWins({
    required DateTime remoteUpdatedAt,
    required DateTime localUpdatedAt,
    required bool localIsDirty,
  }) {
    if (!localIsDirty) return true; // clean local always accepts remote
    return remoteUpdatedAt.isAfter(localUpdatedAt);
  }
}
