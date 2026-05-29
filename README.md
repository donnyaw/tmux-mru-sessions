# tmux-mru-sessions

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
set -g @plugin 'donnyaw/tmux-mru-sessions'
```

Then press `prefix + I` to install with TPM.

### Local Path

For local development or direct use:

```tmux
set -g @plugin '~/.tmux/plugins/tmux-mru-sessions'
```

Or source the plugin directly:

```tmux
run-shell /path/to/tmux-mru-sessions/tmux-mru-sessions.tmux
```

## Configuration

```tmux
set -g @mru-sessions-key 'L'
set -g @mru-sessions-depth '3'
set -g @mru-sessions-storage '#{home}/.local/share/tmux/mru-sessions/history'
```

## Behavior

With `@mru-sessions-depth` set to `3`, assume your MRU ring is:

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
set -g @mru-sessions-key 'B'
```
