#!/usr/bin/env bash
# Enforces: No file under app/ may import flutter_riverpod/legacy.dart.
# Riverpod 3 uses Notifier/AsyncNotifier + code gen; StateNotifier is deprecated.
#
# Usage:
#   bash scripts/ci/check-riverpod-no-legacy.sh
#
# Exit: 0 if no legacy imports; 1 if any found.

set -e
cd "$(dirname "$0")/../.."

matches=$(grep -r -l "import.*flutter_riverpod/legacy" app/ 2>/dev/null || true)
if [ -n "$matches" ]; then
  echo "ERROR: The following files import flutter_riverpod/legacy.dart (deprecated):"
  echo "$matches" | sed 's/^/  /'
  echo ""
  echo "Migrate to @Riverpod + Notifier + BaseNotifierMixin. See app/lib/core/di/RIVERPOD_ARCHITECTURE.md"
  exit 1
fi

echo "OK: No legacy Riverpod imports found"
exit 0
