## UI Verification

HackTracker is iOS-first. Any change that modifies rendered UI MUST be visually verified on the iOS Simulator before being declared done. The acceptance artifact is a screenshot — not a clean analyze, not a "looks right" diff.

### Pre-flight

Before touching any UI file:
1. `claude mcp list` — `dart` and `ios-simulator` both connected.
2. `xcrun simctl list devices booted` — at least one iPhone "Booted".
3. A `flutter run` session is live and attached.

If any check fails, **stop and ask the user**. Don't launch `flutter run` yourself — it owns their terminal session.

### Verification loop

Every UI edit follows this sequence:

1. Read the file(s) before editing.
2. Edit.
3. `mcp__dart__dart_format`.
4. `mcp__dart__hot_reload` (only `hot_restart` if state/providers must reset).
5. `mcp__ios-simulator__screenshot`, then `sips -Z 1800 path.png --out path_small.png`, then Read the small one.
6. `mcp__dart__get_runtime_errors` — must be empty.
7. `mcp__dart__get_widget_tree` when layout behavior is unclear (don't speculate about constraints).
8. Iterate 2–7 until the screenshot matches intent.
9. Verify the quality bar (below).
10. `mcp__dart__analyze_files` — zero errors, zero warnings.

### Screenshot rules

- **Always downscale to ≤1800px** via `sips -Z 1800` before Reading. Sim-native resolution (e.g. iPhone 15 Pro = 1179×2556) trips the 2000px multi-image cap.
- **Don't re-Read old screenshots** in the same session — the budget is per-request across all images.
- **For layout/state checks**, prefer `get_widget_tree` / `ui_describe_all` over a screenshot.
- **For flows behind a tap/swipe**: `ui_tap` → `get_widget_tree` to confirm the target screen → `screenshot`. Never screenshot the wrong screen and call it done.
- **For animations**: `record_video` / `stop_recording`. A single frame is insufficient.

### Quality bar (every UI screenshot must pass)

1. **Contrast.** Text legible against background. `secondaryText` is the floor for muted text on dark; never go below. Low-alpha on already-muted is banned.
2. **Safe areas.** Top notch, bottom indicator, keyboard inset all respected. `SafeArea` or explicit `MediaQuery.paddingOf(context)` padding.
3. **Spacing rhythm.** All padding/gaps from `context.themeSpacing.*`. Adjacent elements share rhythm.
4. **Touch targets.** ≥ 44×44 pt per Apple HIG.
5. **Text truncation.** Long strings use `overflow: TextOverflow.ellipsis` with `maxLines`. Test with deliberately long values.
6. **Empty / loading / error states.** Every data-fetching screen has a deliberate skeleton + a deliberate error state. Screenshot both.
7. **No overflow exceptions.** `get_runtime_errors` empty. Yellow/black overflow stripe = not done.
8. **Hero animation integrity.** `Hero` tags stable across source/destination. `useRootNavigator: false` for dialog destinations. Record a video for any hero transition.
9. **Theme coherence.** Render in the active theme. Theme-aware changes verified in both `light` and `dark`.
10. **Accessibility identifiers.** Interactive elements get `Key('descriptive_name')` or `Semantics(identifier: '...')`. Add as you touch.

(Design language rules — canonical primitives, theme tokens, spring physics — live in `code-quality.md` → "UI primitives".)

### Non-negotiables

- **No screenshot, not done.** "I'm confident" / "the diff looks right" are not acceptance evidence.
- **Runtime errors block completion.** Overflow / constraint exceptions = not done, regardless of how the screenshot looks.
- **Hot reload over rebuild.** `hot_restart` only when state/providers must reset.
- **Widget tree over eyeballing.** Read the tree when debugging layout — don't speculate.
- **Don't launch `flutter run`.** The user owns it.

### When this rule does NOT apply

- Pure business-logic changes (services, repos, data) with no widget diff.
- Schema migrations, SQL functions, RPC contracts.
- Sync outbox / reconciliation internals.
- Tests that exercise logic, not UI.

For these: `dart analyze` clean + targeted unit/integration tests. No screenshot required.
