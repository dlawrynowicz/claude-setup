---
name: brainstorm
description: MUST use BEFORE any creative work — creating features, building components, adding functionality, or modifying behavior. Asks one question at a time, proposes 2-3 approaches with trade-offs, writes design to `docs/features/<feature>/design.md` before implementation, then chains into `/team-setup:plan`. Vendored from `superpowers:brainstorming` v5.1.0.
---

# brainstorm

Turn ideas into validated designs through collaborative dialogue. Save the result. Then implement — never before.

**Vendored from `superpowers:brainstorming` v5.1.0** ([source](file:///Users/broda/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/skills/brainstorming/SKILL.md)). Adapted for team-setup voice, ADR refs, and our doc workflow.

## The hard gate

Don't write code, scaffold projects, or invoke implementation skills until the design is presented AND approved. Applies to every project regardless of perceived simplicity. "Simple" projects are where unexamined assumptions cause the most wasted work.

A short design (a few sentences) is fine for truly simple work — but present it and get approval before coding.

## The other hard gate — design lives in a FILE, not inline prose

Once design sections are approved, you **MUST** invoke `/team-setup:doc-feature <name>` BEFORE writing the consolidated design content anywhere. The design's home is `docs/features/<name>/design.md` — not a conversational dump labeled "Here's my design proposal." Skipping this step violates [ADR 0003 (feature-grouped docs)](../../docs/decisions/0003-feature-grouped-docs.md).

What's allowed inline during brainstorming:
- One question at a time
- One design section at a time (with ASK+WAIT before the next)
- Approach proposals (2-3 alternatives with trade-offs)

What's NOT allowed inline:
- A full multi-section design proposal labeled "Design summary / Pattern / Components / etc." That's the FILE's job, after `/team-setup:doc-feature` scaffolds it.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone + skill ecosystem awareness.
2. Read this project's `CLAUDE.md` and `docs/glossary.md` for voice + terminology.
3. Read relevant ADRs in `docs/decisions/` — especially [ADR 0001 build-before-install](../../docs/decisions/0001-build-before-install.md) and [ADR 0003 feature-grouped-docs](../../docs/decisions/0003-feature-grouped-docs.md).
4. Run `git branch --show-current` for branch context.

## Checklist (use TodoWrite for each)

1. **Explore project context** — files, docs, recent commits
2. **Ask clarifying questions** — one at a time, multiple-choice preferred
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design sections ONE AT A TIME** — write one section, ASK "does this look right so far?", WAIT for user confirmation, then write the next. Don't dump all sections at once. Scale each to complexity.
5. **Pick the feature folder name** — kebab-case (confirm with user)
6. **MUST invoke `/team-setup:doc-feature <name>` BEFORE writing any consolidated design content** — scaffolds `docs/features/<name>/{design,plan,notes}.md` with team frontmatter. The design's home is `design.md`, NOT a conversational "Design summary" dump.
7. **Self-review the spec** — placeholders, contradictions, scope, ambiguity. Fix inline.
8. **User reviews the spec** — wait for approval before proceeding
9. **Hand off to `/team-setup:plan`** — the only skill you invoke after brainstorming

## Process

### Understanding the idea

- Check project state first: files, docs, recent commits.
- Assess scope: if the request describes multiple independent subsystems ("build a platform with chat, file storage, billing, analytics"), flag this immediately. Help decompose into sub-projects, brainstorm the first one through the normal flow.
- For appropriately-scoped projects, ask questions one at a time. Prefer multiple choice. Open-ended is fine.
- Focus on: purpose, constraints, success criteria. One question per message.

### Exploring approaches

- Propose 2-3 approaches with trade-offs.
- Lead with your recommendation and reasoning.
- Conversational, not formal — present like you're explaining to a teammate.

### Presenting the design

- Scale each section to complexity: a sentence or two for simple, up to ~250 words for nuanced.
- Ask "does this look right?" after each section.
- Cover: architecture, components, data flow, error handling, testing.
- Be ready to go back and clarify.

### Design for isolation and clarity

- Break the system into units with one clear purpose, well-defined interfaces, independent testability.
- For each unit: what does it do, how do you use it, what does it depend on?
- Smaller well-bounded units are easier for AI assistants to work with — focused files = reliable edits.

### Working in existing codebases

- Explore current structure before proposing changes. Follow existing patterns.
- Where existing code has problems affecting the work (file too large, unclear boundaries, tangled responsibilities), include targeted improvements — the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused.

## Writing the design doc

After every section has been individually approved by the user (per the per-section ASK+WAIT pattern in step 4):

1. Confirm a feature name in kebab-case with the user (e.g. `team-setup-plugin`, `deposit-alternative`).
2. **MUST invoke `/team-setup:doc-feature <name>`** to scaffold `docs/features/<name>/` with starter `design.md`, `plan.md`, `notes.md` (frontmatter pre-filled). NEVER write design content to a file directly without first scaffolding via `doc-feature`.
3. Fill in the scaffolded `design.md` with the validated design content (the consolidated version of the approved sections).
4. Self-review for placeholders, contradictions, scope, ambiguity. Fix inline. No re-review needed — just fix and move on.

## User review gate

After writing the design:

> "Design written to `docs/features/<feature-name>/design.md`. Please review before we move to the implementation plan."

Wait. If changes requested, make them and re-self-review. Proceed only on approval.

## Hand off to plan

After user approval, invoke `/team-setup:plan` to turn the design into an implementation plan. **No other skill. `plan` is the next step.**

## Key principles

- **One question at a time** — don't overwhelm.
- **Multiple choice preferred** — easier to answer than open-ended.
- **YAGNI ruthlessly** — remove unnecessary features.
- **Explore alternatives** — 2-3 approaches before settling.
- **Incremental validation** — get approval section-by-section.
- **Be flexible** — go back and clarify when something doesn't make sense.

## Don't

- Skip the design phase ("this is too simple"). Every project goes through this.
- Invoke implementation skills before user approval.
- **Write a multi-section "design proposal" inline.** Labels like "Design summary", "Pattern", "Surfaces & touch-points", "Component design" all belong in `design.md`, NOT in conversation prose. The conversation is for question-by-question discussion + per-section approval; the file is the consolidated artifact. Use `/team-setup:doc-feature` to scaffold, then fill in `design.md`.
- Dump all design sections at once. ONE section, ASK, WAIT, NEXT.
- Combine a visual-companion offer (if used) with other content. It's its own message or it's nothing.
- Propose unrelated refactoring during design.

## Visual companion (optional)

If the work involves visual content (mockups, layouts, comparisons, architecture diagrams), `superpowers:brainstorming` includes a browser-based visual companion. For visual-heavy brainstorming, invoke superpowers' version directly via `/superpowers:brainstorming`. Otherwise, terminal text suffices for most brainstorming.

We did NOT vendor the visual companion because it's optional, browser-dependent, and only relevant for visual-heavy design work. Keeping superpowers enabled as a reference plugin (per [ADR 0004](../../docs/decisions/0004-vendor-for-learning-build-for-owning.md)) means it's available when needed.
