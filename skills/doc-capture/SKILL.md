---
name: doc-capture
description: Capture current session's work into the right doc location. Auto-detects type (design / plan / decision / note / handoff) and writes to `docs/features/<feature>/` or cross-cutting `docs/{decisions,handoffs}/`. Branch-aware — records current git branch in frontmatter so feature docs travel with feature branches. Use when the user asks to capture / document / save what we just did.
---

# doc-capture

Capture session work into the right doc location with the right frontmatter. Don't skip steps.

## Why

Session work goes stale 20 minutes after "I should write this down." This skill captures while context is fresh, picks the right location automatically, and applies the project's conventions.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone + terminology.
2. Run `git branch --show-current` — remember as `branch:`.
3. Read the project's `CLAUDE.md` and `docs/glossary.md` for voice.
4. Re-read the conversation: what got decided, designed, or built?

## Decide type

| signal | type | location |
|---|---|---|
| Architectural choice, design discussion | **design** | `docs/features/<feature>/design.md` (flat). Promote to `designs/YYYY-MM-DD-name.md` when 2+ versions accumulate. |
| Step-by-step build, tasks, acceptance | **plan** | `docs/features/<feature>/plan.md` (or `plans/YYYY-MM-DD-name.md` if multiple) |
| Choice with rationale + consequences | **decision (ADR)** | system-wide → `docs/decisions/NNNN-title.md`; feature-scoped → `docs/features/<feature>/decisions/NNNN-title.md` (own counter). For ADRs, delegate to `/team-setup:doc-adr` — it handles numbering. |
| Short note, scratch, observation | **note** | `docs/features/<feature>/notes.md` (append) |
| Session-end summary, resume point | **handoff** | `docs/handoffs/YYYY-MM-DD-session.md` |

If unsure which type, ask the user.

## Decide scope

Feature-scoped → use the feature folder. Cross-cutting → cross-cutting location.

If the feature folder doesn't exist, run `/team-setup:doc-feature <name>` first to scaffold it.

## Frontmatter shape

```yaml
---
feature: <name>           # for feature-scoped; omit for cross-cutting
type: design | plan | decision | note | handoff
status: design | in-progress | accepted | deprecated
date: YYYY-MM-DD
branch: <git-branch>
references:               # optional, paths to related docs
  - ../decisions/NNNN-x.md
---
```

## Write the body

- Extreme short, "we" voice, matrix format for complex content.
- Lead with the substance; no preambles.
- Keep frontmatter and body distinct.

## After writing

- Report the path written.
- Suggest cross-references if relevant ("this references the design at `docs/features/X/design.md` — link from there?").
- Don't update CLAUDE.md path lists unless the user asks — that's separate cleanup.

## Don't use this skill for

- Pure code changes (use the project's PR workflow).
- Glossary updates (direct edit to `docs/glossary.md`).
- Chat scratch you don't want preserved.
