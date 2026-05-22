## Folder Structure

The Dart codebase under `app/lib/` is layered, feature-first. New code MUST conform.

### Top-level

```
app/lib/
  core/         # cross-cutting infrastructure used by 2+ features
  database/     # local SQLite (Drift) — schema, DAOs, generated code
  features/     # one folder per user-facing feature
  shell/        # app-level shell (root scaffold, nav dock, sync listener)
  main.dart
```

- `database/` is the single source of truth for the local DB.
- `shell/` holds app-level concerns that don't belong to one feature.
- `features/` holds independent feature modules. Cross-feature navigation goes through `core/ports/`, never direct screen imports (CI-enforced).

### Per-feature layout

```
features/<name>/
  data/          # repos that talk to database/sync/network
  domain/        # pure models, value objects, sealed types, ports
  presentation/  # screens, widgets, controllers, state
  services/      # feature-internal logic (calculators, schedulers, bridges)
```

**Rules:**

1. **Add layers as needed.** UI-only features start with just `presentation/`. Add others when the need arises.
2. **No `.dart` files at the feature root.** Files belong in a layer.
3. **Empty layer dirs are not allowed** — they imply structure that doesn't exist.
4. **`data/`** may import `database/` and `core/services/`. Never another feature.
5. **`domain/` is pure.** No Flutter, Drift, or Supabase. Models, sealed classes, ports only.
6. **`presentation/`** may import `data/`, `domain/`, `services/`, `core/`. Never another feature's `presentation/` (use `core/ports/`).
7. **`services/`** may import `data/`, `domain/`, `core/services/`. Never `presentation/`.

### `core/services/` vs `features/<name>/services/`

The boundary is **scope**:
- **`core/services/`** — infrastructure with no single owning feature: Supabase client, sync engine, app init, deep links, profile identity, connectivity. If 2+ unrelated features call into it, it lives here.
- **`features/<name>/services/`** — feature-internal logic that bridges core infrastructure into the feature's domain (`lineup_validator`, `team_stats_aggregator`, `team_logo_uploader`).

Test: if you moved this service to `core/services/`, would another feature actually use it? No → feature-internal.

### `core/` partitioning

Partition by *kind*, not by feature:

| Subfolder | Holds |
|---|---|
| `base/` | Base classes / mixins (`BaseNotifier`, `BaseNotifierMixin`) |
| `config/` | Static configuration constants |
| `constants/` | Schema constants (RPC, table names) |
| `di/` | Riverpod providers for app-wide singletons |
| `domain/` | Cross-feature domain models / value objects (e.g. field-position codes, shared enums) |
| `error/` | Error types, error boundary widgets |
| `extensions/` | Dart/Flutter extensions used app-wide |
| `legal/` | Legal pages (privacy, ToS) |
| `ports/` | Cross-feature navigation interfaces |
| `routing/` | App routes, page route classes |
| `services/` | Singletons + infrastructure (see above) |
| `theme/` | Theme tokens, theme extensions |
| `utils/` | Pure utility functions (no state) |
| `widgets/` | Canonical UI primitives (`AppButton`, `AppDialog`) |

### Extracting a new feature

A `features/<name>/` folder represents a coherent user-facing surface. Utility-only code with no UI of its own belongs in `core/utils/` or merged into the consuming feature.

### Server-side (`app/database/`)

Partitioned by SQL artifact type, not by feature — Postgres functions/views/triggers cross feature lines:

```
app/database/
  functions/, migrations/, schemas/, triggers/, views/,
  rls_policies/, grants/, indexes/, foreign_keys/, seeds/, tests/
```

### Enforcement

- `scripts/ci/check-feature-imports.sh` enforces "no feature → other-feature/presentation" imports.
- Escape hatch: `// ignore: clean_architecture_exception`. Use sparingly — every ignore is coupling debt.
- New features that violate this layout (without justification) are rejected at review.
- This file is the source of truth — when conventions evolve, update here first.
