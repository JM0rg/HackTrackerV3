#!/usr/bin/env bash
# check-all.sh — run every static-analysis + structural gate.
#
# Wired to `git push` via `scripts/git-hooks/pre-push`. Run manually anytime:
#   bash scripts/ci/check-all.sh
#
# Skip with: git push --no-verify  (use sparingly).
#
# Runs ALL checks even if an early one fails (keep-going), then reports
# every failure at the end — one fix/run loop instead of N.
#
# What runs:
#   1. dart format --set-exit-if-changed   (formatting must be canonical)
#   2. dart analyze lib test               (no errors; warnings non-fatal)
#   3. check-feature-imports.sh            (no cross-feature presentation imports)
#   4. check-no-handrolled-copywith.sh     (immutability via @freezed only)
#   5. check-no-duplicate-repos.sh         (no Local*Repository duplications)
#   6. check-file-size.sh                  (600-LOC cap + allowlist)
#   7. check-database-source-of-truth.sh   (DB schema drift)
#   8. validate-rpc-grants.js              (every app fn has grants; no dup privs)
#   9. check-riverpod-no-legacy.sh         (Riverpod 3 conventions)
#  10. check-migrations.sh                 (SQL drift: function bodies vs schema)
#  11. check-dead-public-api.sh            (orphaned public Dart APIs)
#  12. check-codegen-stale.sh              (ADVISORY — never fails the gate)
#
# Prod/test sync is handled by Supabase Branches (GitHub integration auto-
# applies migrations to staging on PR and prod on merge). Nothing to check
# here — the platform enforces it.
#
# What we deliberately do NOT run:
#   - flutter test       — too slow for every push (~40s, ~800 tests). Run
#                          before opening a PR: `flutter test`.
#   - dart run build_runner — costs 30s+; only matters when you've edited
#                          @freezed/@riverpod/drift sources. Step 10 is a
#                          cheap mtime heuristic that nudges when it's stale.
#
# Exit 0: all gating checks clean. Exit 1: one or more failed (all listed).

set -uo pipefail
cd "$(dirname "$0")/../.."

START_TIME=$SECONDS
RED='\033[0;31m'
GREEN='\033[0;32m'
DIM='\033[2m'
NC='\033[0m'

FAILED=()

run_step() {
  local label="$1"
  shift
  echo -e "${DIM}→ ${label}${NC}"
  if "$@"; then
    return 0
  else
    echo -e "${RED}✗ ${label} failed${NC}" >&2
    FAILED+=("$label")
    return 1
  fi
}

# 1. dart format — check-only (--output=none does NOT modify files)
run_step "dart format (check-only)" \
  dart format --output=none --set-exit-if-changed app/lib app/test || true

# 2. dart analyze — error-fatal only.
# Pre-existing warnings (unused imports in P4 WIP files, dead code in widgets
# under refactor) are tolerated. The code-quality bar of "zero warnings"
# remains the manual review standard; the gate just prevents new errors.
run_step "dart analyze (errors only)" bash -c '
  cd app && dart analyze lib test --no-fatal-warnings
' || true

# 3-9. Structural / convention gates (fatal)
run_step "no cross-feature presentation imports" \
  bash scripts/ci/check-feature-imports.sh || true

run_step "no hand-rolled copyWith / == / hashCode" \
  bash scripts/ci/check-no-handrolled-copywith.sh || true

run_step "no Local*Repository duplications" \
  bash scripts/ci/check-no-duplicate-repos.sh || true

run_step "file-size cap (600 LOC + allowlist)" \
  bash scripts/ci/check-file-size.sh || true

run_step "database source-of-truth integrity" \
  bash scripts/ci/check-database-source-of-truth.sh || true

run_step "RPC grant integrity (no ungranted fns / dup privs)" \
  node scripts/ci/validate-rpc-grants.js || true

run_step "Riverpod 3 — no legacy patterns" \
  bash scripts/ci/check-riverpod-no-legacy.sh || true

# 10. Migration / SQL drift scanner — catches function bodies that reference
# dropped columns. THE single highest-leverage check in CI; see
# .claude/rules/testing-discipline.md.
run_step "migrations / SQL dead-ref scanner" \
  bash scripts/ci/check-migrations.sh || true

# 11. Dead public API scanner — orphaned Dart methods/getters/top-level
# fns with zero callers. Grandfathered legacy lives in
# scripts/ci/dead-public-api-allowlist.txt and should shrink over time.
run_step "dead public Dart APIs" \
  bash scripts/ci/check-dead-public-api.sh || true

# 12. Codegen staleness — ADVISORY. The script always exits 0; it only
# prints a note if generated files look older than their source.
run_step "codegen staleness (advisory)" \
  bash scripts/ci/check-codegen-stale.sh || true

ELAPSED=$((SECONDS - START_TIME))

if [ "${#FAILED[@]}" -gt 0 ]; then
  echo "" >&2
  echo -e "${RED}✗ ${#FAILED[@]} check(s) failed${NC} (${ELAPSED}s):" >&2
  for f in "${FAILED[@]}"; do
    echo -e "  ${RED}•${NC} ${f}" >&2
  done
  exit 1
fi

echo -e "${GREEN}✓ all checks passed${NC} (${ELAPSED}s)"
