---
name: doc-adr
description: Scaffold a new ADR (Architecture Decision Record) with auto-numbering. Picks system-wide (`docs/decisions/`) or feature-scoped (`docs/features/<feature>/decisions/`) location. Numbers are zero-padded 4-digit; separate counters per scope. Frontmatter pre-filled with current branch and date. Use when the user wants to record a decision with rationale.
---

# doc-adr

Scaffold a new ADR. Captures the choice + rationale + consequences.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone.
2. Run `git branch --show-current` for branch.
3. Today's date as `YYYY-MM-DD`.

## Decide scope

Ask the user: is this decision **system-wide** (affects multiple features or the whole project) or **feature-scoped** (one feature)?

| scope | location | numbering |
|---|---|---|
| system-wide | `docs/decisions/` | global counter |
| feature-scoped | `docs/features/<feature>/decisions/` | per-feature counter |

## Number assignment

1. List existing ADRs in the target dir.
2. Find the highest number. Add 1. Zero-pad to 4 digits.
3. Title in kebab-case (e.g. `0007-use-postgres-for-rentals.md`).

## Frontmatter shape

```yaml
---
number: NNNN
title: <Human-readable title>
status: Accepted | Proposed | Deprecated | Superseded
date: <YYYY-MM-DD>
scope: system-wide | feature
branch: <git-branch>
supersedes: NNNN-other-adr.md   # optional, when this replaces an older ADR
---
```

## Body shape

```markdown
# NNNN. <Human-readable title>

## Context

(what's the situation? what problem are we solving? what constraints apply?)

## Decision

(what did we decide? be concrete and explicit. include the rule + reasoning.)

## Consequences

(what changes as a result? what now becomes easier or harder?)
```

Keep all three sections tight. ADRs are read by future-you and teammates — extreme short, conversational, "we" voice.

## After writing

- Report the path.
- If this ADR supersedes another: suggest updating the old one's status to `Superseded` with a pointer to the new ADR.
- Don't auto-link from CLAUDE.md unless asked.

## When to write an ADR vs a note

- **ADR:** a decision worth referencing later. Has rationale + consequences. Numbered.
- **Note:** an observation, scratch, or in-progress thinking. Append-only in `notes.md`.

If unsure, default to a note — promotion to ADR is cheap; demoting an ADR is awkward.
