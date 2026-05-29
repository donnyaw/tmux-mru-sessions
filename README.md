# toggle-switch-session

A small TPM-compatible tmux plugin that cycles through the most recently used sessions.

By default, tmux `prefix + L` runs `switch-client -l`, which only toggles between the current session and the immediately previous session. This plugin replaces that with a configurable MRU ring so the same key can cycle through the last 3, 5, or more sessions.

## Features

- True MRU session ring cycling.
- Configurable history depth.
- Configurable prefix keybinding.
- Configurable storage path.
- Uses tmux session IDs, so renaming sessions does not break history.
- Stale/killed sessions are automatically ignored.

## Installation

### TPM

Add this plugin to `~/.tmux.conf`:

```tmux
set -g @plugin 'donnyaw/toogle-switch-session-plugin'
```

Then press `prefix + I` to install with TPM.

### Local Path

For local development or direct use:

```tmux
set -g @plugin '~/.tmux/plugins/toogle-switch-session-plugin'
```

Or source the plugin directly:

```tmux
run-shell /path/to/toogle-switch-session-plugin/toggle-switch-session.tmux
```

## Configuration

```tmux
set -g @toggle-switch-session-key 'L'
set -g @toggle-switch-session-depth '3'
set -g @toggle-switch-session-storage '#{home}/.local/share/tmux/toggle-switch-session/history'
```

## Behavior

With `@toggle-switch-session-depth` set to `3`, assume your MRU ring is:

```text
S1, S2, S3
```

Current session is `S1`.

Press `prefix + L`:

```text
switch to S2
ring becomes S2, S3, S1
```

Press `prefix + L` again:

```text
switch to S3
ring becomes S3, S1, S2
```

Press `prefix + L` again:

```text
switch to S1
ring becomes S1, S2, S3
```

Manual session switches refresh the MRU ring automatically through tmux's `after-switch-client` hook.

## Notes

This plugin binds `prefix + L` by default. If you want to keep native tmux behavior, choose another key:

```tmux
set -g @toggle-switch-session-key 'B'
```
