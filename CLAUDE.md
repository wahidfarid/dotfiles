# Dotfiles Repo

This repo manages personal dotfiles using **symlinks** — files live here and are linked into their expected system locations. A systemd watcher service auto-commits and pushes changes whenever files in the repo are modified.

## Structure

```
dotfiles/
├── claude/
│   ├── CLAUDE.md                        -> ~/.claude/CLAUDE.md
│   ├── settings.json                    -> ~/.claude/settings.json
│   └── hooks/peon-ping/config.json      -> ~/.claude/hooks/peon-ping/config.json
├── ghostty/
│   └── config                           -> ~/.config/ghostty/config
├── git/
│   └── .gitconfig                       -> ~/.gitconfig
├── tmux/
│   └── .tmux.conf                       -> ~/.tmux.conf
├── zsh/
│   ├── .zshrc                           -> ~/.zshrc
│   └── .p10k.zsh                        -> ~/.p10k.zsh
├── .scripts/
│   └── dotfiles-watcher.sh              # inotifywait loop: auto-commit + push on change
└── setup.sh                             # Run once on a new machine to create all symlinks
```

## How It Works

- `setup.sh` creates all symlinks and installs the systemd watcher service
- `dotfiles-watcher.sh` uses `inotifywait` to watch the repo dir, debounces changes, then auto-commits and pushes with a message like `auto: update <file>`
- Adding a new tracked file means: copy/move it into the repo, add a `link` call in `setup.sh`, and symlink the live path to the repo file

## Adding a New File

1. Copy the file into the appropriate subdirectory in this repo
2. Add a `link "$DOTFILES_DIR/..."  "$HOME/..."` line to `setup.sh`
3. Run `ln -sf <repo-path> <live-path>` to activate the symlink immediately
