#!/usr/bin/env bash
# Watches the dotfiles repo for changes and auto-commits + pushes to remote.
# Sends a desktop notification after each push.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEBOUNCE=3  # seconds to wait after last change before committing

cd "$DOTFILES_DIR" || exit 1

echo "Dotfiles watcher started, watching: $DOTFILES_DIR"

inotifywait -m -r \
  --exclude '\.git/' \
  -e modify,create,delete,move \
  --format '%w%f' \
  "$DOTFILES_DIR" 2>/dev/null | \
while read -r CHANGED_FILE; do
  # Reset debounce timer by draining any queued events for DEBOUNCE seconds
  while read -r -t "$DEBOUNCE" _; do :; done

  # Get list of changed files for commit message
  CHANGED=$(git -C "$DOTFILES_DIR" diff --name-only && git -C "$DOTFILES_DIR" ls-files --others --exclude-standard)

  if [ -z "$CHANGED" ]; then
    continue
  fi

  # Build commit message from changed files
  FILE_LIST=$(echo "$CHANGED" | tr '\n' ' ' | sed 's/ $//')
  COMMIT_MSG="auto: update $FILE_LIST"

  git -C "$DOTFILES_DIR" add -A

  if git -C "$DOTFILES_DIR" commit -m "$COMMIT_MSG" --quiet; then
    if git -C "$DOTFILES_DIR" push --quiet 2>/dev/null; then
      notify-send \
        --app-name="Dotfiles" \
        --icon=emblem-synchronizing \
        "Dotfiles synced" \
        "$FILE_LIST"
    else
      notify-send \
        --app-name="Dotfiles" \
        --icon=dialog-warning \
        "Dotfiles: push failed" \
        "Committed locally but could not push. Check remote."
    fi
  fi
done
