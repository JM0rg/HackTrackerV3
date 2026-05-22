#!/usr/bin/env bash
# Enforces: app/database/** is generated output. PRs that change app/database/*
# must also change app/database/migrations/* (migrations are the source of truth).
#
# Usage:
#   bash scripts/ci/check-database-source-of-truth.sh
#
# In CI, set BASE_REF (e.g. origin/main) to compare against. Default: origin/main.

set -e
cd "$(dirname "$0")/../.."

BASE_REF="${BASE_REF:-origin/main}"

# Check if we're in a git repo and base ref exists
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repo, skipping database source-of-truth check"
  exit 0
fi

if ! git rev-parse "$BASE_REF" >/dev/null 2>&1; then
  echo "Base ref $BASE_REF not found, skipping check"
  exit 0
fi

# Files changed between base and HEAD (exclude seed and migrations from trigger set)
all_db_changed=$(git diff --name-only "$BASE_REF"...HEAD -- app/database/ 2>/dev/null || true)
db_changed=$(echo "$all_db_changed" | grep -v '^app/database/seed\.sql$' | grep -v '^app/database/migrations/' || true)
migrations_changed=$(git diff --name-only "$BASE_REF"...HEAD -- app/database/migrations/ 2>/dev/null || true)

if [ -z "$db_changed" ]; then
  echo "No app/database changes; check passed"
  exit 0
fi

if [ -z "$migrations_changed" ]; then
  echo "ERROR: app/database/** was modified without a corresponding migration."
  echo "Migrations are the source of truth. Do not edit app/database/* directly."
  echo "Instead: add a migration under app/database/migrations/, apply it, then run npm run fetch-all."
  echo ""
  echo "Changed app/database files:"
  echo "$db_changed"
  exit 1
fi

echo "app/database changes accompanied by migrations; check passed"
exit 0
