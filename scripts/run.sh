#!/usr/bin/env bash
# Run the Flutter app with public Supabase dart-defines only.
# Never passes SUPABASE_SECRET_API_KEY.
#
# Do not `source` .env — secrets often contain `$`, which bash expands
# (and `set -u` then fails with "unbound variable").
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

env_get() {
  local key="$1"
  local line value
  [[ -f "$ENV_FILE" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    [[ "$line" == export[[:space:]]* ]] && line="${line#export }"
    if [[ "$line" == "$key="* ]]; then
      value="${line#*=}"
      if [[ "$value" == \"*\" ]]; then
        value="${value:1:${#value}-2}"
      elif [[ "$value" == \'*\' ]]; then
        value="${value:1:${#value}-2}"
      fi
      printf '%s' "$value"
      return 0
    fi
  done < "$ENV_FILE"
}

SUPABASE_URL="$(env_get SUPABASE_URL)"
SUPABASE_ANON_KEY="$(env_get SUPABASE_ANON_KEY)"

DEFINES=()
if [[ -n "$SUPABASE_URL" ]]; then
  DEFINES+=(--dart-define=SUPABASE_URL="$SUPABASE_URL")
fi
if [[ -n "$SUPABASE_ANON_KEY" ]]; then
  DEFINES+=(--dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY")
fi

cd "$REPO_ROOT/app"
exec flutter run "${DEFINES[@]}" "$@"
