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
6. Generate a fresh tempfile path with Bash: `mktemp -u /tmp/claude-commit-msg.XXXXXX`. The `-u` flag prints the path without creating the file, so the Write tool can create it cleanly without a prior Read. This form works on both GNU mktemp (Linux) and BSD mktemp (macOS). Capture the printed path for the next two steps.
7. Use the Write tool to write the composed message to that path. The content must be exactly the commit message with no trailing newline. Do NOT use a Bash heredoc — heredocs containing prose trip the Bash command classifier with `undefined node type: string` and force a manual permission prompt every run.
8. Run one trivial Bash pipeline to copy the file to the clipboard and remove it. Pick the first clipboard tool present on this machine and emit exactly one command of the form `<tool> < <path> && rm <path>`. Candidates in order: `pbcopy`, `wl-copy`, `xclip -selection clipboard`, `xsel --clipboard --input`, `clip.exe`. If none exist, delete the file and tell the user no clipboard tool was found.
9. Print the exact message back to the user so they can see what is now on the clipboard.

## Arguments

`$ARGUMENTS`
