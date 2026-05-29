#!/usr/bin/env bash

set -u

plugin_option() {
  local option="$1"
  local default_value="$2"
  local value

  value="$(tmux show-option -gqv "$option" 2>/dev/null || true)"
  if [ -z "$value" ]; then
    printf '%s' "$default_value"
  else
    printf '%s' "$value"
  fi
}

history_depth() {
  local depth
  depth="$(plugin_option '@toggle-switch-session-depth' '3')"

  case "$depth" in
    ''|*[!0-9]*) depth=3 ;;
  esac

  if [ "$depth" -lt 2 ]; then
    depth=2
  fi

  printf '%s' "$depth"
}

history_file() {
  local configured expanded
  configured="$(plugin_option '@toggle-switch-session-storage' '#{home}/.local/share/tmux/toggle-switch-session/history')"
  expanded="$(tmux display-message -p "$configured" 2>/dev/null || true)"

  if [ -z "$expanded" ]; then
    expanded="$HOME/.local/share/tmux/toggle-switch-session/history"
  fi

  case "$expanded" in
    '~/'*) expanded="$HOME/${expanded#~/}" ;;
  esac

  printf '%s' "$expanded"
}

ensure_history_dir() {
  local file
  file="$(history_file)"
  mkdir -p "$(dirname "$file")"
}

current_session_id() {
  tmux display-message -p '#{session_id}' 2>/dev/null || true
}

session_exists() {
  local session_id="$1"
  [ -n "$session_id" ] && tmux has-session -t "$session_id" 2>/dev/null
}

read_history() {
  local file seen line count depth
  file="$(history_file)"
  depth="$(history_depth)"
  count=0
  seen=" "

  [ -f "$file" ] || return 0

  while IFS= read -r line || [ -n "$line" ]; do
    [ -n "$line" ] || continue
    session_exists "$line" || continue
    case "$seen" in
      *" $line "*) continue ;;
    esac

    printf '%s\n' "$line"
    seen="$seen$line "
    count=$((count + 1))
    [ "$count" -ge "$depth" ] && break
  done < "$file"
}

write_history() {
  local file tmp line count depth seen
  file="$(history_file)"
  depth="$(history_depth)"
  tmp="${file}.$$"
  count=0
  seen=" "

  ensure_history_dir
  : > "$tmp"

  while IFS= read -r line || [ -n "$line" ]; do
    [ -n "$line" ] || continue
    session_exists "$line" || continue
    case "$seen" in
      *" $line "*) continue ;;
    esac

    printf '%s\n' "$line" >> "$tmp"
    seen="$seen$line "
    count=$((count + 1))
    [ "$count" -ge "$depth" ] && break
  done

  mv "$tmp" "$file"
}

display_session_name() {
  local session_id="$1"
  tmux display-message -p -t "$session_id" '#S' 2>/dev/null || printf '%s' "$session_id"
}
