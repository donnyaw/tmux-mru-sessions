#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
. "$SCRIPT_DIR/common.sh"

current="$(current_session_id)"
if ! session_exists "$current"; then
  tmux display-message 'tmux-mru-sessions: no current session'
  exit 0
fi

history=()
while IFS= read -r entry; do
  [ -n "$entry" ] && history+=("$entry")
done < <(read_history)

if [ "${#history[@]}" -eq 0 ] || [ "${history[0]}" != "$current" ]; then
  new_history=("$current")
  for entry in "${history[@]}"; do
    [ "$entry" = "$current" ] && continue
    new_history+=("$entry")
  done
  history=("${new_history[@]}")
fi

if [ "${#history[@]}" -lt 2 ]; then
  tmux display-message 'tmux-mru-sessions: no previous session in history'
  printf '%s\n' "${history[@]}" | write_history
  exit 0
fi

target="${history[1]}"

if ! session_exists "$target"; then
  tmux display-message 'tmux-mru-sessions: target session no longer exists'
  printf '%s\n' "${history[@]}" | write_history
  exit 0
fi

rotated=()
for ((i = 1; i < ${#history[@]}; i++)); do
  rotated+=("${history[$i]}")
done
rotated+=("${history[0]}")

printf '%s\n' "${rotated[@]}" | write_history

target_name="$(display_session_name "$target")"
tmux switch-client -t "$target"
tmux display-message "tmux-mru-sessions: switched to $target_name"
