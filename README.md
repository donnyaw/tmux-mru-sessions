# tmux-mru-sessions

A small TPM-compatible tmux plugin that cycles through the most recently used tmux sessions.

By default, tmux `prefix + L` runs `switch-client -l`, which only toggles between the current session and the immediately previous session. This plugin replaces that with a configurable MRU ring so the same key can cycle through the last 3 sessions by default, or any other number you choose.

## Terms

**tmux**

tmux is a terminal multiplexer. It lets you keep multiple terminal workspaces running inside one terminal connection.

**Session**

A tmux session is a top-level workspace. For example, you may have sessions named `practice`, `server`, and `notes`. Each session can contain many windows.

**Window**

A tmux window is like a tab inside a session. This plugin works at the session level, not the window level.

**Prefix**

The tmux prefix is the key sequence you press before most tmux commands. The tmux default is `Ctrl+b`, but your config may use something else. If your prefix is `Ctrl+Space`, then `prefix + L` means press `Ctrl+Space`, release it, then press uppercase `L`.

**TPM**

TPM means Tmux Plugin Manager. It installs and loads tmux plugins from GitHub or local paths. With TPM, you add a `set -g @plugin ...` line to `~/.tmux.conf`, then press `prefix + I` to install plugins.

**MRU**

MRU means Most Recently Used. In this plugin, the MRU list is the recent session order. If you moved through `S1 -> S2 -> S3`, the plugin remembers those sessions and lets you rotate through them with one key.

**MRU Ring**

A ring is a circular list. When the plugin reaches the end of the remembered sessions, it wraps back to the beginning. With depth `3`, the cycle can behave like `S1 -> S2 -> S3 -> S1`.

**History Depth**

History depth is how many sessions the plugin remembers. The default is `3`. You can set it to `5`, `10`, or another number with `@mru-sessions-depth`.

**Hook**

A tmux hook is an automatic action that runs after a tmux event. This plugin uses the `after-switch-client` hook to update the MRU ring whenever you switch sessions.

**Storage File**

The storage file is where the plugin saves the remembered session IDs. The default path is `~/.local/share/tmux/mru-sessions/history`.

**Session ID**

A tmux session ID is an internal stable identifier such as `$1` or `$2`. This plugin stores session IDs instead of session names, so renaming a session does not break the MRU history.

## Features

- True MRU session ring cycling.
- Configurable history depth.
- Configurable prefix keybinding.
- Configurable storage path.
- Uses tmux session IDs, so renaming sessions does not break history.
- Stale or killed sessions are automatically ignored.

## Installation

### Install With TPM

Use this method if you already use [TPM](https://github.com/tmux-plugins/tpm), the Tmux Plugin Manager.

Step 1: Add the plugin to `~/.tmux.conf`.


```tmux
set -g @plugin 'donnyaw/tmux-mru-sessions'
```

Step 2: Reload your tmux config.

From inside tmux, run:

```tmux
prefix + :
source-file ~/.tmux.conf
```

Or from a normal shell:

```sh
tmux source-file ~/.tmux.conf
```

Step 3: Install the plugin with TPM.

From inside tmux, press:

```text
prefix + I
```

TPM should clone the plugin and load it automatically.

### Install From Local Path

Use this method if you cloned the repository yourself.

Step 1: Clone the repository.

```sh
git clone https://github.com/donnyaw/tmux-mru-sessions ~/.tmux/plugins/tmux-mru-sessions
```

Step 2: Add the local plugin path to `~/.tmux.conf`.


```tmux
set -g @plugin '~/.tmux/plugins/tmux-mru-sessions'
```

Step 3: Reload tmux and install with TPM:

```sh
tmux source-file ~/.tmux.conf
```

Then press:

```text
prefix + I
```

### Install Without TPM

Use this method if you do not use TPM.

Step 1: Clone the repository.

```sh
git clone https://github.com/donnyaw/tmux-mru-sessions ~/.tmux/plugins/tmux-mru-sessions
```

Step 2: Add this line to `~/.tmux.conf`.


```tmux
run-shell ~/.tmux/plugins/tmux-mru-sessions/tmux-mru-sessions.tmux
```

Step 3: Reload tmux.

```sh
tmux source-file ~/.tmux.conf
```

## Configuration

Default configuration:

```tmux
set -g @mru-sessions-key 'L'
set -g @mru-sessions-depth '3'
set -g @mru-sessions-storage '#{home}/.local/share/tmux/mru-sessions/history'
```

Configuration options:

| Option | Default | Meaning |
|--------|---------|---------|
| `@mru-sessions-key` | `L` | Prefix key used to cycle MRU sessions. `L` means `prefix + L`. |
| `@mru-sessions-depth` | `3` | Number of sessions to remember and cycle through. Minimum effective value is `2`. |
| `@mru-sessions-storage` | `#{home}/.local/share/tmux/mru-sessions/history` | File path used to store the MRU session ring. |

Example: remember 5 sessions instead of 3:

```tmux
set -g @mru-sessions-depth '5'
```

Example: use `prefix + B` instead of `prefix + L`:

```tmux
set -g @mru-sessions-key 'B'
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

## Usage Guide

### Basic Usage

After installation, use the configured keybinding to cycle through recent sessions.

Default keybinding:

```text
prefix + L
```

Example workflow:

1. Create or switch between several tmux sessions, such as `practice`, `server`, and `notes`.
2. Move among them normally with `prefix + s`, `prefix + (`, `prefix + )`, or your own bindings.
3. Press `prefix + L` to cycle through the remembered MRU session ring.

### Change The Number Of Remembered Sessions

Default depth is `3`:

```tmux
set -g @mru-sessions-depth '3'
```

To cycle through the last 5 sessions:

```tmux
set -g @mru-sessions-depth '5'
```

Reload tmux after changing the setting:

```sh
tmux source-file ~/.tmux.conf
```

### Change The Keybinding

By default, this plugin binds uppercase `L` after your prefix:

```tmux
set -g @mru-sessions-key 'L'
```

To use `prefix + B` instead:

```tmux
set -g @mru-sessions-key 'B'
```

Reload tmux after changing the setting.

### Test The Plugin

You can test with three sessions:

```sh
tmux new-session -d -s practice
tmux new-session -d -s server
tmux new-session -d -s notes
tmux attach -t practice
```

Inside tmux:

1. Switch to `server`.
2. Switch to `notes`.
3. Press `prefix + L` repeatedly.

Expected behavior with default depth `3`:

```text
practice -> server -> notes -> practice -> server -> notes
```

The exact starting point depends on the order in which the plugin observed your session switches.

### Check The Stored MRU History

The default history file is:

```text
~/.local/share/tmux/mru-sessions/history
```

It stores tmux session IDs, not session names. This is expected.

### Reset The MRU History

To clear the remembered session ring:

```sh
rm ~/.local/share/tmux/mru-sessions/history
```

The plugin will recreate the file as you switch sessions.

## Comparison With Native tmux

Native tmux behavior:

```text
prefix + L -> switch-client -l -> toggles between last 2 sessions only
```

Plugin behavior:

```text
prefix + L -> tmux-mru-sessions -> cycles through remembered MRU sessions
```

## Notes

This plugin binds `prefix + L` by default. If you want to keep native tmux behavior, choose another key with `@mru-sessions-key`.

If the MRU ring contains a session that was killed, the plugin skips it automatically.

If you set the depth to `5` but only have 3 sessions, the plugin cycles through the 3 existing tracked sessions.
