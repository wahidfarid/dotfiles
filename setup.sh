#!/usr/bin/env bash
# Dotfiles setup script
# Run this on a new machine after cloning the repo to restore all configs.
# Usage: ./setup.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Dotfiles setup starting from: $DOTFILES_DIR"

# ── Dependencies ──────────────────────────────────────────────────────────────
echo "==> Checking dependencies..."

install_if_missing() {
  local cmd="$1"
  local pkg="$2"
  if ! command -v "$cmd" &>/dev/null; then
    echo "    Installing $pkg..."
    sudo dnf install -y "$pkg" 2>/dev/null || \
    sudo apt-get install -y "$pkg" 2>/dev/null || \
    echo "    WARNING: Could not install $pkg. Install it manually."
  else
    echo "    $cmd: OK"
  fi
}

install_if_missing inotifywait inotify-tools
install_if_missing notify-send libnotify

# ── Symlinks ──────────────────────────────────────────────────────────────────
echo "==> Creating symlinks..."

link() {
  local src="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  mkdir -p "$dest_dir"

  # Back up existing file if it's not already a symlink to our repo
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "    Backing up existing $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  ln -sf "$src" "$dest"
  echo "    $dest -> $src"
}

link "$DOTFILES_DIR/zsh/.zshrc"            "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.p10k.zsh"         "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/tmux/.tmux.conf"       "$HOME/.tmux.conf"
link "$DOTFILES_DIR/ghostty/config"        "$HOME/.config/ghostty/config"
link "$DOTFILES_DIR/git/.gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES_DIR/ssh/config"            "$HOME/.ssh/config"
link "$DOTFILES_DIR/claude/CLAUDE.md"      "$HOME/.claude/CLAUDE.md"
link "$DOTFILES_DIR/claude/settings.json"  "$HOME/.claude/settings.json"

# ── Systemd watcher service ───────────────────────────────────────────────────
echo "==> Installing dotfiles watcher service..."

SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

# Write service file with the correct dotfiles path
cat > "$SERVICE_DIR/dotfiles-watcher.service" <<EOF
[Unit]
Description=Dotfiles auto-commit and push watcher
After=network.target

[Service]
Type=simple
ExecStart=$DOTFILES_DIR/.scripts/dotfiles-watcher.sh
Restart=on-failure
RestartSec=5
Environment=DISPLAY=:0
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/%U/bus

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now dotfiles-watcher.service
echo "    Watcher service enabled and started."

# ── SSH permissions ───────────────────────────────────────────────────────────
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true

echo ""
echo "==> Setup complete!"
echo ""
echo "    Next steps:"
echo "    1. Set your git remote: cd $DOTFILES_DIR && git remote add origin <url>"
echo "    2. Push: git push -u origin main"
echo "    3. Check watcher: systemctl --user status dotfiles-watcher.service"
