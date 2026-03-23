# Development Guidelines

## Philosophy

- **Incremental progress** — Small changes that compile and pass tests
- **Study before implementing** — Read existing patterns first, use the same libraries and conventions
- **Pragmatic over dogmatic** — Adapt to project reality
- **Clear intent over clever code** — Choose the boring, obvious solution
- **Minimal code** — Write as little as possible. When possible, remove more than you add
- **Single responsibility** — One purpose per function/class; avoid premature abstractions
- **No comments** unless the logic is genuinely non-obvious

## Handling Ambiguity

Before starting work: extract core intent, identify what's missing, and ask targeted clarifying questions. Don't make assumptions — verify with existing code. Plan the work before executing.

## Implementation Flow

1. **Understand** — Find 2-3 similar existing features; follow their patterns, tests, and utilities
2. **Test** — Write test first (red)
3. **Implement** — Minimal code to pass (green)
4. **Refactor** — Clean up with tests passing
5. **Commit** — Clear message explaining *why*, not just what

## When Stuck (3-Attempt Rule)

**Maximum 3 attempts per issue, then STOP.**

Document what failed and why, then reassess:
- Is this the right abstraction level?
- Can it be split into smaller problems?
- Remove abstraction instead of adding?
- Different library/framework feature or architectural pattern?

## Technical Standards

### Architecture

- Composition over inheritance; dependency injection over singletons
- Explicit over implicit — clear data flow and dependencies
- Test-driven when possible

### Commits

Every commit must compile, pass all existing tests, include tests for new functionality, and follow project formatting/linting. Run formatters/linters before committing.

### Error Handling

- Fail fast with descriptive messages
- Include context for debugging
- Handle errors at the appropriate level
- Never silently swallow exceptions

### Tooling

Use the project's existing build system, test framework, and formatter/linter settings. Don't introduce new tools without strong justification.

## Decision Framework

When making a plan, state confidence for each decision point on a scale of 1–5 (1 = low, 5 = high). Flag any unfounded or unproven assumptions so the user is aware before work begins.

When multiple valid approaches exist:

1. **Testability** — Can I easily test this?
2. **Readability** — Will someone understand this in 6 months?
3. **Consistency** — Does this match project patterns?
4. **Simplicity** — Is this the simplest solution that works?
5. **Reversibility** — How hard to change later?

## Hard Rules

- Never use `--no-verify` to bypass commit hooks
- Never disable tests — fix them
- Never commit code that doesn't compile
- No TODOs without issue numbers
- When fixing a bug, exhaust existing patterns before introducing new ones; remove old logic when replacing it
- Only make changes that are requested or clearly necessary and related
