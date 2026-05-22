/// Coarse sync lifecycle surfaced to the UI (banner + indicator). The UI never
/// blocks on these — they are informational only.
enum SyncStatus { idle, syncing, offline, error }
