#!/usr/bin/env bash
# Enforces: No hand-rolled copyWith / operator== / hashCode in app/lib/**.
# All immutable data classes must use @freezed instead.
#
# Scope:
#   - Scans app/lib/ (NOT test/, NOT .freezed.dart, NOT .g.dart)
#   - Excludes Drift-generated row classes (app/lib/database/local/**)
#   - Excludes AppThemeExtension (Flutter ThemeExtension<T> requires hand-rolled copyWith/lerp)
#
# Usage:
#   bash scripts/ci/check-no-handrolled-copywith.sh
#
# Exit: 0 if clean; 1 if hand-rolled boilerplate found.

set -e
cd "$(dirname "$0")/../.."

# Find candidate files. Excludes:
#   - generated code (.freezed.dart, .g.dart)
#   - Drift row classes (database/local/*)
#   - FantasyThemeExtension (Flutter ThemeExtension<T> requires hand-rolled)
#   - Sealed type hierarchies (Dart 3 pattern-matching idiom; freezed-unions
#     would add boilerplate without correctness benefit). Detected by the
#     presence of `^sealed class` or `^final class .* extends ` in the file.
candidates_raw=$(find app/lib -name '*.dart' \
  ! -name '*.freezed.dart' \
  ! -name '*.g.dart' \
  ! -path 'app/lib/database/local/*' \
  ! -path '*/app_theme_extension.dart')

candidates=""
while IFS= read -r f; do
  if grep -qE '^(sealed|final)\s+class\s' "$f" 2>/dev/null \
     && grep -qE '^(sealed\s+class|final\s+class\s+\w+\s+extends\s)' "$f" 2>/dev/null; then
    continue
  fi
  candidates="${candidates}${f}"$'\n'
done <<< "$candidates_raw"

violations=""

# Check for `copyWith(` method definitions (not calls)
copywith_hits=$(echo "$candidates" | xargs grep -l -E '^\s+[A-Z][a-zA-Z0-9_]+\s+copyWith\s*\(' 2>/dev/null || true)

# Check for `bool operator ==` overrides
eq_hits=$(echo "$candidates" | xargs grep -l -E '^\s+bool operator ==' 2>/dev/null || true)

# Check for `int get hashCode` overrides
hash_hits=$(echo "$candidates" | xargs grep -l -E '^\s+int get hashCode' 2>/dev/null || true)

if [ -n "$copywith_hits" ]; then
  violations="${violations}\nHand-rolled copyWith:\n$(echo "$copywith_hits" | sed 's/^/  /')\n"
fi

if [ -n "$eq_hits" ]; then
  violations="${violations}\nHand-rolled operator ==:\n$(echo "$eq_hits" | sed 's/^/  /')\n"
fi

if [ -n "$hash_hits" ]; then
  violations="${violations}\nHand-rolled hashCode:\n$(echo "$hash_hits" | sed 's/^/  /')\n"
fi

if [ -n "$violations" ]; then
  echo "ERROR: Found hand-rolled immutability boilerplate. Use @freezed instead."
  echo -e "$violations"
  echo ""
  echo "Convert these classes to @freezed. See .claude/rules/code-quality.md#immutability"
  exit 1
fi

echo "OK: No hand-rolled copyWith / == / hashCode in app/lib/"
exit 0
