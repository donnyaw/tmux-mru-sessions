#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

session_id="${1:-}"
if [ -z "$session_id" ]; then
  session_id="$(current_session_id)"
fi

if ! session_exists "$session_id"; then
  exit 0
fi

{
  printf '%s\n' "$session_id"
  read_history | while IFS= read -r existing; do
    [ "$existing" = "$session_id" ] && continue
    printf '%s\n' "$existing"
  done
} | write_history
