# Tmux Keymaps

Prefix key: `Ctrl+A`

## Session

| Key | Action |
|---|---|
| `Prefix + d` | Detach from session |
| `Prefix + S` | Choose session from list |
| `Prefix + *` | List connected clients |
| `Prefix + o` | Open SessionX (fuzzy session picker) |

## Windows

| Key | Action |
|---|---|
| `Prefix + W` | New window |
| `Prefix + Ctrl+C` | New window (in $HOME) |
| `Prefix + H` | Previous window |
| `Prefix + L` | Next window |
| `Prefix + Ctrl+A` | Last (most recent) window |
| `Prefix + w` | List windows |
| `Prefix + "` | Choose window |
| `Prefix + r` | Rename current window |

## Panes

| Key | Action |
|---|---|
| `Prefix + s` | Split vertically (top/bottom) |
| `Prefix + v` | Split horizontally (left/right) |
| `Prefix + h` | Select pane left |
| `Prefix + j` | Select pane down |
| `Prefix + k` | Select pane up |
| `Prefix + l` | Select pane right |
| `Prefix + z` | Toggle pane zoom (fullscreen) |
| `Prefix + c` | Kill current pane |
| `Prefix + x` | Swap pane down |
| `Prefix + P` | Toggle pane border status |
| `Prefix + *` | Synchronize panes (type in all at once) |

## Pane Resizing

| Key | Action |
|---|---|
| `Prefix + ,` | Resize pane left (20 cells) |
| `Prefix + .` | Resize pane right (20 cells) |
| `Prefix + -` | Resize pane down (7 cells) |
| `Prefix + =` | Resize pane up (7 cells) |

## Copy Mode (vi)

Enter copy mode with `Prefix + [`

| Key | Action |
|---|---|
| `v` | Begin selection |
| `y` | Yank selection (copies to system clipboard via tmux-yank) |
| `h/j/k/l` | Navigate |
| `q` | Exit copy mode |

## Plugins

### Floax (Floating Panes)

| Key | Action |
|---|---|
| `Prefix + f` | Toggle floating pane |

### SessionX

| Key | Action |
|---|---|
| `Prefix + o` | Open session picker |
| `Ctrl+y` | Open zoxide result in new window |

### tmux-fzf

| Key | Action |
|---|---|
| `Prefix + F` | Open fzf menu (sessions, windows, panes, commands) |

### tmux-thumbs

| Key | Action |
|---|---|
| `Prefix + Space` | Show thumbs hints (copy URLs, paths, hashes) |

### tmux-fzf-url

| Key | Action |
|---|---|
| `Prefix + u` | Pick and open a URL from current pane |

## Utility

| Key | Action |
|---|---|
| `Prefix + R` | Reload tmux config |
| `Prefix + K` | Clear terminal |
| `Prefix + Ctrl+L` | Refresh client |
| `Prefix + Ctrl+X` | Lock server |
| `Prefix + :` | Command prompt |
| `Prefix + I` | Install plugins (TPM) |
| `Prefix + U` | Update plugins (TPM) |
