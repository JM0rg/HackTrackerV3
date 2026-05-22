#!/usr/bin/env bash
# check-codegen-stale.sh — soft warn when a codegen source looks newer
# than its generated output (i.e. someone edited a @freezed/@riverpod/
# drift source and pushed without `dart run build_runner`).
#
# SOFT signal only — ALWAYS exits 0, never blocks the gate. mtime is a
# heuristic: fresh clones, checkouts, and rebases scramble timestamps so
# this can false-positive/negative. The authoritative check is running
# build_runner; this just catches the common live-dev footgun cheaply.
#
# Usage: bash scripts/ci/check-codegen-stale.sh
# Exit: always 0.

set -uo pipefail
cd "$(dirname "$0")/../.."

stale=""
count=0
while IFS= read -r gen; do
  # foo.g.dart  → foo.dart ;  foo.freezed.dart → foo.dart
  src="${gen%.g.dart}"
  src="${src%.freezed.dart}"
  src="${src}.dart"
  [ -f "$src" ] || continue
  if [ "$src" -nt "$gen" ]; then
    stale="${stale}  ${src}  →  $(basename "$gen")\n"
    count=$((count + 1))
  fi
done < <(find app/lib \( -name '*.g.dart' -o -name '*.freezed.dart' \) -type f | sort)

if [ "$count" -gt 0 ]; then
  echo "Note: ${count} generated file(s) older than their source — codegen may be stale:" >&2
  printf "$stale" >&2
  echo "  Fix: cd app && dart run build_runner build --delete-conflicting-outputs" >&2
  echo "  (advisory — not failing the gate)" >&2
fi

echo "OK: codegen staleness check complete (advisory${count:+, $count flagged})"
exit 0
