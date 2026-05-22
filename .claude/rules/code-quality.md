## Code Quality

### Formatting
Dart 3.11+ Tall Style. `dart format` is the source of truth — never hand-tune line breaks, trailing commas, or indentation. Don't commit unformatted code.

### Analysis
`dart analyze` must report zero errors and zero warnings. Run after every edit session. Info-level hints are acceptable but address them when touching the file.

### Dead code
Delete unused imports, variables, functions, and classes immediately. No commented-out code, no `// TODO: remove`, no backward-compat shims. If it's not called, it doesn't exist.

### Naming
- `lowerCamelCase` — variables, functions, constants
- `UpperCamelCase` — types
- `lowercase_with_underscores` — files, libraries

### Type safety
- Explicit types on public APIs.
- `final` for locals that aren't reassigned.
- No `dynamic` — use `Object` with checks or generics.
- Sealed classes + exhaustive pattern matching for closed hierarchies.

### Immutability
- Domain models and Riverpod state classes use `@freezed`. **Never hand-roll `copyWith`, `==`, or `hashCode`.**
- Controller state classes that need `isLoading`/`isSaving`/`errorMessage` plumbing for `BaseNotifierMixin` `implements BaseNotifierState` (in `core/base/base_notifier.dart`).
- Never mutate state in place — always emit a new instance.
- Use `const factory` constructors where possible.
- Exceptions: classes holding non-value types (`TextEditingController`, `Listenable`), Drift-generated rows, sealed exception hierarchies, `AppThemeExtension` (`ThemeExtension` requires hand-rolled `copyWith`/`lerp`).

### Widget composition
- `build()` methods under ~80 lines. Extract `_buildHeader`, `_buildBody`, etc.
- Compose, don't inherit.
- No business logic in `build()`. Read providers, delegate mutations to notifiers.
- Use `const` aggressively to minimize rebuilds.

### UI primitives (canonical only)
- **Theme tokens are the only style source.** `context.colors.*`, `context.text.*`, `context.themeSpacing.*`, `context.themeRadii.*`. Never hardcode colors, spacing, or font sizes.
- **Use the canonical primitives.** `AppButton`, `AppTextField`, `AppCard`, `AppDialog`, `ConfirmationDialog`, `SkeletonLoader`, `EmptyState`, `AppScaffold`, `OfflineBanner`, `SyncStatusIndicator`. Full list in `CLAUDE.md` → UI System. Build a new primitive (don't inline a bespoke widget) when a pattern recurs.
- **No loading spinners.** Only `SkeletonLoader` and friends.
- **No `showDialog` / `showGeneralDialog`.** Only `AppDialog.show<T>(...)`.
- **No bespoke confirms.** Only `ConfirmationDialog.show(...)` (supports `isDestructive`).
- **Spring physics, not easing curves.** `SpringConfig.snappy/smooth/bouncy/fast` from `core/utils/spring_animations.dart`. Never `CurvedAnimation` with `Curves.ease*`.

### Provider design
- One provider, one responsibility.
- `select()` to watch only fields a widget needs.
- `ref.listen` for side effects (navigation, snackbars, logging). `ref.watch` for rebuilds.
- No `ref.read` inside `build()` for state that should rebuild — use `ref.watch`.
- Dispose via `ref.onDispose`, not widget `dispose()`.

### Error handling
- Catch at boundaries (network, DB, platform channels), not in pure domain logic.
- Typed failures over generic exceptions. `Result<T>` or sealed errors over `try/catch` spaghetti.
- Never swallow exceptions silently — log via `AppLogger`. Surface user errors via state, not throws.
- Fail fast in debug, gracefully in release.

### Performance
- No unnecessary allocations in hot paths (build, animation ticks, list builders). Reuse, prefer `const`.
- `RepaintBoundary` for independently animating subtrees.
- `ListView.builder` over `Column` with children for unbounded content. `itemExtent` when uniform.
- Precache critical images. `ResizeImage` for oversized assets.
- No `addPostFrameCallback` chains — they signal missing reactive bindings.

### Testing
- Test behavior, not implementation. Assert on outputs and side effects.
- Independent and deterministic — no shared mutable state, network, clock, or randomness without explicit control.
- Name as contracts: `"a lineup cannot place two players in the same batting slot"`, not `"test lineup"`.
- Narrow focused assertions over multi-assert integration tests.

### Dependency direction
- One-way: `shell → features → core`. No feature imports another feature's `presentation/`.
- Cross-feature navigation through `core/ports/`, never direct screen imports.
- Shared services live in `core/services/`. If 2+ features use it, it's not feature-specific.
- CI-enforced by `check-feature-imports.sh`.
