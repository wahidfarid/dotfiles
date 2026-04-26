Review this conversation end-to-end before the context is cleared. Your job is to surface anything worth preserving so nothing is lost between sessions.

Work through these four areas and report findings for each:

## 1. Project documentation (.agent/context.md and .agent/rules.md)

Read both files. Then review the conversation and ask:

- Is anything in context.md now stale or incomplete? (schema changes, new features, status updates, new sets added, deployment changes)
- Is anything in rules.md now stale? (new workflows discovered, patterns that worked or failed, new constraints learned)
- Is there anything we did or decided this session that a future agent would benefit from knowing?

For each gap: state what the current file says, what it should say, and propose the exact edit. Do not apply edits — list them for the user to approve.

## 2. Memory files (~/.claude/projects/.../memory/)

Read MEMORY.md and any relevant memory files. Ask:

- Did we learn anything new about the user's preferences, workflow, or feedback that isn't captured yet?
- Did any existing memory become stale?
- Is there a project or reference memory worth adding?

Propose specific memory additions or updates. Do not write them yet.

## 3. Loose ends

Review the conversation for anything that was started but not finished, explicitly deferred, or marked as a follow-up:

- TODOs or "do this later" notes
- Known bugs or edge cases that weren't fixed
- Features partially implemented
- Things that need to be verified in production (e.g. revalidate after deploy)
- Any commands the user still needs to run

List each one concisely.

## 4. Anything else worth noting

Anything that doesn't fit the above — surprising behavior discovered, non-obvious decisions made, things that would be confusing to a future agent without context.

---

After working through all four areas, ask the user which proposed changes they want applied, then apply only the approved ones.
