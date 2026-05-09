---
name: execute
description: MUST use when executing a written implementation plan from `docs/features/<feature>/plan.md`. Loads plan, reviews critically, executes tasks task-by-task with TodoWrite tracking, stops at blockers, then chains into `/team-setup:discipline-check` after substantial work. Vendored from `superpowers:executing-plans` v5.1.0.
---

# execute

Load plan, review critically, execute all tasks, report when complete.

**Vendored from `superpowers:executing-plans` v5.1.0** — adapted for team-setup voice, ADR refs, hooks integration.

**Announce at start:** "I'm using `/team-setup:execute` to implement the plan."

**Note:** team-setup works best on platforms with subagent support (Claude Code, Codex). If subagents are available, prefer dispatching fresh subagents per task; this skill executes inline with checkpoints.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone + ecosystem.
2. Read the plan: `docs/features/<feature>/plan.md`.
3. Read the design: `docs/features/<feature>/design.md`.
4. Read [ADR 0002 layered enforcement](../../docs/decisions/0002-layered-enforcement.md) — know which hooks fire (`capture-nudge` on Write/Edit ≥10 lines, `review-required` on Write/Edit ≥50 lines).
5. Run `git branch --show-current` for branch context.

## The process

### Step 1: Load and review plan

1. Read the plan file.
2. Review critically — identify any questions or concerns.
3. If concerns: raise them with the user BEFORE starting. Don't grind through.
4. If clear: create TodoWrite with one task per `### Task N` section in the plan.

### Step 2: Execute tasks

For each task:

1. Mark as in_progress in TodoWrite.
2. Follow each step exactly (plan has bite-sized steps).
3. Run verifications as specified (test commands, expected output).
4. Mark as completed.

The PostToolUse hooks fire automatically:
- `capture-nudge` (≥10 lines Write/Edit) — suggests `/team-setup:doc-capture` for capturing what changed
- `review-required` (≥50 lines Write/Edit) — blocks the next turn until review evidence

Honor these. The block isn't a bug — it's the HARD-tier enforcement per ADR 0002.

### Step 3: Complete development

After all tasks complete and verified:

1. Run `/team-setup:discipline-check` to dispatch `team-reviewer` for a final check (TDD/DRY/SOLID/no-shortcuts).
2. Address any violations the reviewer surfaces.
3. Suggest next-step skills based on what shipped:
   - Code shipped → `/team-setup:write-pr-description` for the PR
   - Domain knowledge discovered → `/team-setup:update-docs` to capture it
   - Major decision made along the way → `/team-setup:doc-adr` to record it

## When to stop and ask for help

Stop executing immediately when:

- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.** Don't force through blockers.

## When to revisit earlier steps

Return to step 1 (load and review) when:

- User updates the plan based on your feedback
- Fundamental approach needs rethinking

If the design itself is wrong, go back to `/team-setup:brainstorm`. Don't try to patch a broken design via plan edits.

## Remember

- Review plan critically first.
- Follow plan steps exactly.
- Don't skip verifications.
- Reference skills when plan says to.
- Stop when blocked, don't guess.
- Never start implementation on main/master without explicit user consent.
- Honor the HARD-tier hooks — they prevent rushed merges.

## Integration with other skills

| skill | when |
|---|---|
| `/team-setup:doc-capture` | after substantial work, capture session learnings |
| `/team-setup:doc-adr` | record decisions made during execution |
| `/team-setup:discipline-check` | final review before declaring done |
| `/team-setup:write-pr-description` | when ready to ship |
| `/team-setup:update-docs` | when domain knowledge changed |

## Don't

- Skip the critical review of the plan in step 1.
- Force tasks past failed verifications.
- Bypass the PostToolUse hooks — they're load-bearing per ADR 0002.
- Start work on main/master without consent.
