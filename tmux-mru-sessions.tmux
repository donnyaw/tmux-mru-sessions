#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local value

  value="$(tmux show-option -gqv "$option")"
  if [ -z "$value" ]; then
    printf '%s' "$default_value"
  else
    printf '%s' "$value"
  fi
}

key="$(get_tmux_option '@mru-sessions-key' 'L')"
root_keys="$(get_tmux_option '@mru-sessions-root-key' 'M-L')"

tmux set-hook -g after-switch-client "run-shell -b '$CURRENT_DIR/scripts/record_session.sh \"#{session_id}\"'"
tmux bind-key "$key" run-shell -b "$CURRENT_DIR/scripts/switch_session.sh"

for root_key in $root_keys; do
  tmux bind-key -n "$root_key" run-shell -b "$CURRENT_DIR/scripts/switch_session.sh"
done

"$CURRENT_DIR/scripts/record_session.sh" "$(tmux display-message -p '#{session_id}' 2>/dev/null)" >/dev/null 2>&1 || true
