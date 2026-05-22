#!/usr/bin/env bash
# ============================================================================
# check-dead-public-api.sh — flag public Dart methods / top-level constants
# that have zero callers in the codebase.
#
# Catches the failure class where a method gets orphaned by a refactor and
# nobody notices because the test suite doesn't cover it. (See:
# getMostRecentExerciseIdForSkill, which lingered for a full migration
# cycle returning wrong data.)
#
# Invocation:
#   bash scripts/ci/check-dead-public-api.sh
# ============================================================================

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

python3 "$DIR/scripts/ci/check_dead_public_api.py" "$DIR/app/lib"
