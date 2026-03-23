# dotfiles

Personal config files with auto-commit and push on every save.

## What's tracked

| File | Location |
|---|---|
| `.zshrc` | `~/.zshrc` |
| `.p10k.zsh` | `~/.p10k.zsh` |
| `.tmux.conf` | `~/.tmux.conf` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `.gitconfig` | `~/.gitconfig` |
| `ssh/config` | `~/.ssh/config` |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/settings.json` | `~/.claude/settings.json` |

## Prerequisites

- zsh + [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- tmux
- [Ghostty](https://ghostty.org/)
- [Claude Code](https://claude.ai/code)
- `inotify-tools` (for the watcher)
- `libnotify` (for desktop notifications)

## Quick start on a new machine

```bash
git clone git@github.com:<you>/dotfiles.git ~/Development/dotfiles
cd ~/Development/dotfiles
./setup.sh
```

`setup.sh` will:
1. Install missing dependencies (`inotify-tools`, `libnotify`)
2. Create symlinks from all config files to their expected locations (backing up any existing files as `.bak`)
3. Install and start the auto-commit watcher as a systemd user service

## How the auto-commit watcher works

A background service (`dotfiles-watcher.service`) watches this repo using `inotifywait`. When any tracked file is saved:

1. Waits 3 seconds for any follow-up saves (debounce)
2. Stages all changes
3. Commits with a message like `auto: update zsh/.zshrc`
4. Pushes to origin
5. Sends a desktop notification confirming the push (or warning if push failed)

The watcher starts automatically on login via systemd.

### Watcher commands

```bash
# Check status
systemctl --user status dotfiles-watcher.service

# View logs
journalctl --user -u dotfiles-watcher.service -f

# Restart
systemctl --user restart dotfiles-watcher.service

# Stop
systemctl --user stop dotfiles-watcher.service
```

## Adding a new file to track

1. Move the file into the appropriate subdirectory (or create a new one):
   ```bash
   mv ~/.someconfig ~/Development/dotfiles/subdir/.someconfig
   ```
2. Create a symlink back:
   ```bash
   ln -s ~/Development/dotfiles/subdir/.someconfig ~/.someconfig
   ```
3. Add the new `link` line to `setup.sh` so it works on fresh machines.

The watcher picks up new files automatically — no restart needed.
