#!/usr/bin/env bash
# check-feature-imports.sh — CI gate: no cross-feature presentation imports
#
# Features must not import another feature's presentation layer.
# This enforces one-way dependency flow and prevents feature-to-feature coupling.
#
# Allowed:
#   - Same-feature imports (features/X/ importing features/X/presentation/)
#   - Lines with // ignore: clean_architecture_exception
#
# Usage:
#   bash scripts/ci/check-feature-imports.sh
#
# Exit 0: clean
# Exit 1: violations found

set -euo pipefail
cd "$(dirname "$0")/../.."

violations=0
violation_output=""

# Scan all Dart files under app/lib/features/
while IFS= read -r file; do
  # Extract the feature name from the file path.
  # e.g. app/lib/features/workout/presentation/screens/foo.dart -> workout
  feature=$(echo "$file" | sed -n 's|^app/lib/features/\([^/]*\)/.*|\1|p')
  if [ -z "$feature" ]; then
    continue
  fi

  # Read each import line from the file
  while IFS= read -r line; do
    # Skip lines with the clean_architecture_exception ignore comment
    if echo "$line" | grep -q '// ignore: clean_architecture_exception'; then
      continue
    fi

    # Extract the imported feature name from cross-feature presentation imports.
    # Matches: import 'package:app/features/OTHER/presentation/...'
    imported_feature=$(echo "$line" | sed -n "s|.*import.*['\"]package:app/features/\([^/]*\)/presentation/.*['\"].*|\1|p")
    if [ -z "$imported_feature" ]; then
      continue
    fi

    # Same-feature imports are allowed
    if [ "$imported_feature" = "$feature" ]; then
      continue
    fi

    # This is a cross-feature presentation import — violation
    violations=$((violations + 1))
    violation_output="${violation_output}  ${file}
    ${line}
"
  done < <(grep -n "^import\|^  *import" "$file" 2>/dev/null || true)
done < <(find app/lib/features -name '*.dart' -type f 2>/dev/null)

# Also check core/ files do not import any feature presentation layer.
# Allowed exception: core/di/repository_providers.dart (wires adapters via DI).
while IFS= read -r file; do
  # Skip DI wiring and routing composition files — they legitimately import
  # feature adapters/screens to wire dependency injection and route resolution.
  case "$file" in
    app/lib/core/di/repository_providers.dart) continue ;;
    app/lib/core/routing/initial_route_screen.dart) continue ;;
    app/lib/core/routing/settings_navigation.dart) continue ;;
  esac

  while IFS= read -r line; do
    if echo "$line" | grep -q '// ignore: clean_architecture_exception'; then
      continue
    fi

    imported_feature=$(echo "$line" | sed -n "s|.*import.*['\"]package:app/features/\([^/]*\)/presentation/.*['\"].*|\1|p")
    if [ -z "$imported_feature" ]; then
      continue
    fi

    violations=$((violations + 1))
    violation_output="${violation_output}  ${file}
    ${line}
"
  done < <(grep -n "^import\|^  *import" "$file" 2>/dev/null || true)
done < <(find app/lib/core -name '*.dart' -type f 2>/dev/null)

if [ "$violations" -gt 0 ]; then
  echo "ERROR: Found ${violations} cross-feature presentation import(s):"
  echo ""
  echo "$violation_output"
  echo "Features must not import another feature's presentation layer."
  echo "Core must not depend on feature presentation (except repository_providers.dart for DI wiring)."
  echo "Move shared code to core/ or use a domain/data boundary instead."
  echo ""
  echo "To suppress a specific line, add: // ignore: clean_architecture_exception"
  exit 1
fi

echo "OK: No cross-feature presentation imports found"
exit 0
