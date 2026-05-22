#!/usr/bin/env bash
# check-file-size.sh — fail when any non-allowlisted .dart file exceeds 600 LOC.
#
# Excludes generated code (*.g.dart, *.freezed.dart) and test/.
# Allowlist of intentional exceptions lives at scripts/ci/file-size-allowlist.txt.
#
# Usage:
#   bash scripts/ci/check-file-size.sh
#
# Exit 0: clean
# Exit 1: violations found

set -euo pipefail
cd "$(dirname "$0")/../.."

MAX=600
ALLOWLIST_FILE="scripts/ci/file-size-allowlist.txt"

# Build allowlist: strip comments + blanks, normalize. `|| true` keeps an
# all-comments (empty) allowlist from tripping `set -o pipefail`.
allowlisted=$(grep -vE '^\s*(#|$)' "$ALLOWLIST_FILE" 2>/dev/null | tr -d ' \t' | sort -u || true)

violations=""
violation_count=0

while IFS= read -r path; do
  loc=$(wc -l < "$path" | tr -d ' ')
  if [ "$loc" -le "$MAX" ]; then
    continue
  fi
  if echo "$allowlisted" | grep -qxF "$path"; then
    continue
  fi
  violations="${violations}  ${loc}\t${path}\n"
  violation_count=$((violation_count + 1))
done < <(find app/lib -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' -type f | sort)

if [ "$violation_count" -gt 0 ]; then
  echo "ERROR: ${violation_count} file(s) exceed ${MAX} LOC and are not in the allowlist:" >&2
  echo "" >&2
  printf "$violations" >&2
  echo "" >&2
  echo "Either split the file (preferred) or add it to ${ALLOWLIST_FILE} with justification." >&2
  exit 1
fi

# Bonus: warn if an allowlisted file has shrunk below the cap (free win — clean it up).
shrunk=""
while IFS= read -r path; do
  if [ ! -f "$path" ]; then continue; fi
  loc=$(wc -l < "$path" | tr -d ' ')
  if [ "$loc" -le "$MAX" ]; then
    shrunk="${shrunk}  ${path} (${loc} LOC)\n"
  fi
done < <(echo "$allowlisted")

if [ -n "$shrunk" ]; then
  echo "Note: allowlisted files now under ${MAX} LOC — remove from allowlist:" >&2
  printf "$shrunk" >&2
  # Soft signal — don't fail the push for this.
fi

echo "OK: file-size cap clean (${MAX} LOC, $(echo "$allowlisted" | wc -l | tr -d ' ') allowlisted)"
exit 0
