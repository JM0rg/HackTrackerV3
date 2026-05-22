## Post-Change Cycle

After every significant change, run this cycle. Stop when one pass produces no edits in steps 2–3 and zero failures in step 4.

### The cycle

1. **Implement** — smallest scope that achieves the goal.

2. **Review** — re-read your *diff* (not whole files). Flag:
   - Unnecessary loops, allocations, or DB round-trips; two queries → one batch.
   - User input or network without validation at a boundary. (Trust internal code.)
   - Logic that duplicates an existing helper — call it.
   - Copy-pasted blocks with **2+ real uses** (never speculative) — factor out.

3. **Simplify** — scoped to the area you touched. Look for: leftover scaffolding, debug prints, dead branches, stray `TODO`s, unused imports, stale names. **Re-read, don't rewrite** — anything not traceable to step 1's goal stays.

4. **Verify** — all must pass:
   - `bash scripts/ci/check-all.sh` (full pre-push gate: formatter, analyzer, migration drift scanner, dead-public-api scanner, file-size cap, etc.). This is the source of truth.
   - Pure-function + wire-parity tests for the touched area (`flutter test path/to/test.dart` or `mcp__dart__run_tests`).
   - For SQL/migration work: `bash scripts/ci/check-migrations.sh` — catches function bodies that reference dropped columns. Non-negotiable for any change under `app/database/`.
   - For sync/mapper work: `flutter test test/wire_parity/` — catches server JSON keys the mapper silently drops.
   - Do NOT write new tests just to "increase coverage." See `testing-discipline.md` — every new test must explain in its docstring what failure mode it catches that no existing test does.

### Cycling rule

- Steps 2 or 3 produce edits → restart at step 1.
- Step 4 fails (test or analyzer error) → fix, restart.
- **Formatter-only step-4 edits do not trigger a restart** — re-running on formatted code finds nothing new.
- **Cap at 3 cycles.** If pass 4 still finds things, the original change was too big — split it.

### Scope by change size

- **Small fix (≤20 LOC, single file)**: one pass, diff-only re-read.
- **Multi-file feature/refactor**: full cycle, per-touched-region review. Re-read only what your diff changed, never end-to-end across 10 files.

### Significant vs skip

**Run the cycle**: function/method/widget/controller change; file, import, or dependency add or remove; rename or restructure across 2+ sites; root-cause bug fix.

**Skip**: typo-only edits in comments/docs, single-edit reverts, single-line tweaks already covered by the previous cycle.
