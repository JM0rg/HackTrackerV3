/// Local-only dirty flag tracking a row's pending sync work. `synced` means
/// the row matches (or is reconciled with) the server; the others mark work
/// the push phase must propagate.
enum SyncState { synced, pendingCreate, pendingUpdate, pendingDelete }
