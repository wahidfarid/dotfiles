---
description: Generate a commit message from staged changes and copy to clipboard
---

Generate a commit message based on the currently staged changes in this repo and copy it to the system clipboard.

## Steps

1. Run `git diff --cached --stat` to see which files are staged. If nothing is staged, tell the user "no staged changes" and stop.
2. Run `git diff --cached` to read the actual change content.
3. Run `git log --author="$(git config user.email)" -40 --format="%s" | grep -v '^auto:'` to sample the user's recent commit subjects (skipping auto-watcher noise). Use these as the style reference.
4. Compose a commit message that matches the sampled style. Rules:
   - Lowercase first letter, imperative present tense ("add X", "fix Y", "replace Z"), no trailing period.
   - Terse. One line unless the change genuinely warrants a body.
   - If a body is needed: one blank line after the subject, then short wrapped prose. Still no trailing period on the last line.
   - No em-dashes (—). Use commas, colons, parentheses, or separate sentences.
   - No attribution lines (no `Co-Authored-By`, no `Generated with Claude Code`, no signatures).
   - No ticket or issue references (no `TC-123:`, no `Fixes #42`, no `[PROJ-1]`).
   - No markdown fences, no leading/trailing whitespace, no indentation on any line.
5. If `$ARGUMENTS` is non-empty, treat it as extra instructions from the user (for example "include ticket TC-123", "add a body explaining why", "use a specific prefix"). Honor those, overriding the defaults above only where they conflict.
6. Write the final message to a tempfile with `mktemp`, so special characters in the message do not collide with shell quoting. Example:
   ```sh
   msg=$(mktemp)
   cat > "$msg" <<'COMMIT_MSG_EOF'
   <the composed message>
   COMMIT_MSG_EOF
   ```
7. Pipe the tempfile into whichever clipboard tool exists on this machine:
   ```sh
   if command -v pbcopy >/dev/null 2>&1; then pbcopy < "$msg"
   elif command -v wl-copy >/dev/null 2>&1; then wl-copy < "$msg"
   elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard < "$msg"
   elif command -v xsel >/dev/null 2>&1; then xsel --clipboard --input < "$msg"
   elif command -v clip.exe >/dev/null 2>&1; then clip.exe < "$msg"
   else echo "no clipboard tool found" >&2; rm -f "$msg"; exit 1
   fi
   rm -f "$msg"
   ```
8. Print the exact message back to the user so they can see what is now on the clipboard.

## Arguments

`$ARGUMENTS`
