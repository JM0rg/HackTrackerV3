#!/usr/bin/env bash
# ============================================================================
# check-migrations.sh — static analyzer that catches function bodies that
# reference dropped columns/tables.
#
# This is the single highest-leverage test in the project. It catches the
# class of bug that "786 unit tests passed" failed to catch.
#
# How it works:
#   1. Parse every CREATE TABLE in app/database/schemas/ → build a map of
#      table → {column1, column2, ...}.
#   2. Apply every migration in app/database/migrations/ on top of that
#      map, processing ALTER TABLE … DROP COLUMN / ADD COLUMN / DROP TABLE
#      to evolve the schema model.
#   3. For every function file in app/database/functions/, extract
#      `ws.column_name` / `tbl.column_name` references and verify each
#      referenced table.column actually exists in the final schema map.
#   4. Also flag references to tables that don't exist at all.
#
# No Docker, no Postgres, no test runner. Runs in <1s. Catches drift
# the day it appears.
#
# Invocation:
#   bash scripts/ci/check-migrations.sh
# ============================================================================

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DB_DIR="$DIR/app/database"

# Delegate to a small Python helper — bash regex is the wrong tool for SQL
# parsing. Python is on every dev machine + CI.
python3 "$DIR/scripts/ci/check_migrations.py" "$DB_DIR"
