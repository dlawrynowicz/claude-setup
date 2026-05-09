---
name: doc-feature
description: Scaffold a new feature folder under `docs/features/<feature-name>/` with starter `design.md`, `plan.md`, `notes.md` files. Pre-fills frontmatter (feature name, status, date, current branch). Idempotent — refuses to overwrite existing files. Use before starting work on a new feature.
---

# doc-feature

Scaffold a new feature folder. Idempotent — never overwrites.

## Required preparation

1. Confirm the feature name with the user. Use kebab-case (e.g. `deposit-alternative`, `team-setup-plugin`).
2. Run `git branch --show-current` to record the branch.
3. Today's date as `YYYY-MM-DD`.

## What to create

```
docs/features/<feature-name>/
├── design.md
├── plan.md
└── notes.md
```

## Starter content — `design.md`

```markdown
---
feature: <feature-name>
type: design
status: design
date: <YYYY-MM-DD>
branch: <git-branch>
---

# <feature-name> — design

## Purpose

(what this feature does, who it's for, why it matters — 2-3 sentences)

## Principles

(2-4 architectural principles, link ADRs where applicable)

## Open questions

(things to resolve before implementation)
```

## Starter content — `plan.md`

```markdown
---
feature: <feature-name>
type: plan
status: in-progress
date: <YYYY-MM-DD>
branch: <git-branch>
references: ./design.md
---

# <feature-name> — implementation plan

## Build sequence

| # | step | output | testable how |
|---|---|---|---|
| 0 | (first step) | (deliverable) | (test) |

## Acceptance criteria

- [ ] (criterion)

## Plan revisions

(append-only)

- **v1 (<YYYY-MM-DD>)**: initial plan.
```

## Starter content — `notes.md`

```markdown
---
feature: <feature-name>
type: note
date: <YYYY-MM-DD>
branch: <git-branch>
---

# <feature-name> — notes

(scratch, observations, links — append as you work)
```

## Idempotency

- If `docs/features/<feature-name>/` already exists: stop. Report what's there. Do **not** overwrite.
- If only some files exist: ask before adding the missing ones.

## After scaffolding

- Report the paths created.
- Optionally seed initial content from the current conversation if the user provides context.
- Suggest invoking `/team-setup:doc-capture` when ready to fill in real content.
