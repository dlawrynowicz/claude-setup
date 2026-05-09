---
name: discipline-check
description: Apply team discipline (TDD, DRY, SOLID, no-shortcuts on security/architecture) to current code by dispatching the `team-reviewer` agent. Returns findings summarized in main context. Use after substantial code changes (the PostToolUse `review-required` hook nudges this); also resolves the HARD-layer review block from ADR 0002.
---

# discipline-check

Dispatch the `team-reviewer` agent against current code/changes; summarize findings.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone.
2. Identify what to review:
   - **From PostToolUse review-required block:** the file just written/edited (look at recent tool calls).
   - **From manual invocation:** ask the user "what should I review?" Default to current branch's `git diff` vs main.

## Dispatch the agent

Use the `Agent` tool to spawn `team-reviewer` (defined in this plugin's `agents/team-reviewer.md`):

- **Prompt the agent with:**
  - the specific file path / diff range / code area
  - the user's intent if known ("checking before commit", "post-implementation review", etc.)
  - reference to relevant ADRs (esp. ADR 0002 for layered enforcement)
- Wait for the agent's report.

The agent runs in isolated context — its grep / read calls don't pollute main context.

## Summarize for the user

The agent returns findings in a structured format. Restate them as:

```
DISCIPLINE-CHECK — <what was reviewed>

✓ Passes:
  - <list>

⚠ Concerns:
  - <file>:<line> — <concern> (severity)

✗ Violations:
  - <file>:<line> — <violation> (severity)

Recommendation: (1-2 sentences on highest priority)
```

## After

- **If invoked from review-required block:** confirm the discipline check ran. Tell the user they can proceed; the block resolves once they continue. Don't auto-acknowledge or auto-fix.
- **If invoked manually:** leave findings open for the user to address. Don't auto-fix; never write to files.

## Don't

- Don't auto-fix violations. The user decides.
- Don't dispatch the agent for trivial changes (1-3 lines). Use judgment.
- Don't bypass review-required by claiming the check ran without actually dispatching.
