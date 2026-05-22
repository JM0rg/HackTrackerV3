## Testing Discipline

**Less but better.** A green suite is worthless if it doesn't catch real
failures — a wall of widget-smoke and round-trip tests proves the code
generator works, not that the app does. Strict rules about what's testable.

### The four categories that earn their keep

1. **Pure-function tests** — `test/*.dart` files testing math, validation,
   parsing, formatting. No DB, no IO, no widgets. Catch real bugs at
   <1s/test. Examples: `batting_average_test.dart`, `lineup_validator_test.dart`,
   `game_result_test.dart`, `lww_resolver_test.dart`.

2. **Lint-style structural tests** — e.g. `test/core/constants/schema_usage_contract_test.dart`,
   `test/database/local_schema_test.dart`. Single-shot assertions about
   codebase shape (no raw `.from()`, Drift schema opens cleanly). Each
   catches a specific drift class.

3. **Wire-shape parity** — `test/wire_parity/`. Asserts mappers consume
   every key in a server JSON fixture. Catches sync drift the day it
   happens.

4. **End-to-end happy paths** — `test/e2e/`. Real Supabase, real DB, full
   RPC roundtrip. Guarded behind env vars; runs only when creds are set
   (CI / explicit local). One test per critical user flow, no more.

### What NEVER gets a test

- **Widget smoke tests** that "render without crashing" with empty data.
  They prove the constructor doesn't throw. So does `dart analyze`.
- **In-memory Drift tests** that don't exercise the actual production
  query paths. They prove SQLite can parse a SELECT.
- **SQL contract tests that grep `.sql` files for substrings.** They prove
  text exists. They cannot prove the SQL runs.
- **Controller "state shape" tests** that assert `state.copyWith(x: 1)`
  produces a state with `x = 1`. You're testing freezed, not your code.
- **Json round-trip tests** for freezed-generated `toJson`/`fromJson`.
  You're testing the code generator.
- **Tests that exist because "feature X needs a test."**

### The new-test bar

Every new test file must answer in its docstring:

> "What failure mode does this catch that no existing test does?"

If the answer is anything like "regression coverage for the feature I
just built" or "asserts the controller behaves correctly," it's not
specific enough. Specific answers look like:

- "Catches server JSON keys the mapper silently drops."
- "Catches function bodies that reference dropped columns."
- "Regression for [specific bug fixed in commit X]: [one-line root cause]."

If you can't write the docstring, you can't write the test.

### Required CI gates

These four scripts run in `scripts/ci/check-all.sh` and must all pass:

- `scripts/ci/check-migrations.sh` — static analyzer for SQL dead refs in
  `app/database/functions/`. Catches column drift the day it happens.
- `scripts/ci/check-dead-public-api.sh` — flags public Dart APIs with
  zero callers. Has an allowlist for legacy debt (`dead-public-api-allowlist.txt`)
  that shrinks, never grows.
- `flutter test` — pure-function tests + wire-parity tests. Must be
  fast (<60s) and deterministic.
- `bash scripts/ci/check-all.sh` — full preflight gate.

E2E (`flutter test test/e2e/`) runs separately, only when creds present.

### When you fix a bug

Write **one** test that reproduces it before fixing. The test docstring
quotes the root cause in one sentence. The test goes in the most
specific category that fits — pure-function if possible, then
wire-parity, then E2E. **Never** add a widget smoke test "just to have
coverage."

### Working with the allowlists

- `scripts/ci/dead-public-api-allowlist.txt` should shrink over time.
  When touching a file that has allowlisted entries, consider deleting
  the dead method as part of the change.
- `scripts/ci/file-size-allowlist.txt` (separate concern) — same rule:
  remove entries when files drop under the cap.
- New allowlist entries require a comment explaining why.
