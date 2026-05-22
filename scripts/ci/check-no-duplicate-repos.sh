#!/usr/bin/env bash
# check-no-duplicate-repos.sh — flag `Foo` + `LocalFoo` repository pairs.
#
# After Phase 3 (offline-first consolidation) there is exactly one repository
# per concept. The `Local*Repository` prefix was a transitional pattern; if
# any reappear, we want to know before they spread.
#
# Looks for `^class Local.*Repository` declarations under app/lib/. Any hit
# is a violation — pick one canonical name (drop the `Local`).
#
# Usage:
#   bash scripts/ci/check-no-duplicate-repos.sh
#
# Exit 0: clean
# Exit 1: violations found

set -euo pipefail
cd "$(dirname "$0")/../.."

violations=$(grep -rn "^class Local[A-Z][a-zA-Z]*Repository" app/lib --include="*.dart" 2>/dev/null || true)

if [ -n "$violations" ]; then
  echo "ERROR: found Local*Repository class(es). Pick one canonical name (drop the prefix):" >&2
  echo "" >&2
  echo "$violations" | sed 's/^/  /' >&2
  echo "" >&2
  echo "Phase 3 of the roadmap consolidated Local*Repository into the canonical name." >&2
  echo "If a new offline-first repo is genuinely needed, name it without the Local prefix." >&2
  exit 1
fi

echo "OK: no Local*Repository duplications"
exit 0
