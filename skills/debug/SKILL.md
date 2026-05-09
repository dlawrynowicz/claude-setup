---
name: debug
description: MUST use when encountering any bug, test failure, or unexpected behavior, BEFORE proposing fixes. Four-phase rigid recipe: root-cause investigation → pattern analysis → hypothesis testing → implementation. Iron Law: no fixes without root cause. Chains into `/team-setup:tdd` for failing test (Phase 4) + `/team-setup:discipline-check` after substantial fixes. Vendored from `superpowers:systematic-debugging` v5.1.0.
---

# debug

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Vendored from `superpowers:systematic-debugging` v5.1.0** — adapted for team-setup voice + ecosystem; rigid recipe preserved.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone + ecosystem.
2. Read [ADR 0002 layered enforcement](../../docs/decisions/0002-layered-enforcement.md).
3. Run `git branch --show-current` for context.

## When to use

Any technical issue: test failures, bugs in production, unexpected behavior, performance problems, build failures, integration issues.

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

## The four phases

You **must** complete each phase before proceeding to the next.

### Phase 1: Root cause investigation

**BEFORE attempting ANY fix:**

1. **Read error messages carefully** — don't skip past errors or warnings. They often contain the exact solution. Read stack traces completely. Note line numbers, file paths, error codes.

2. **Reproduce consistently** — can you trigger it reliably? What are the exact steps? If not reproducible → gather more data, don't guess.

3. **Check recent changes** — git diff, recent commits. New dependencies, config changes. Environmental differences.

4. **Gather evidence in multi-component systems** — when the system has multiple components (CI → build → signing, API → service → database), BEFORE proposing fixes, add diagnostic instrumentation:

   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

5. **Trace data flow** — when error is deep in call stack:
   - Where does bad value originate?
   - What called this with bad value?
   - Keep tracing up until you find the source
   - Fix at source, not at symptom

### Phase 2: Pattern analysis

**Find the pattern before fixing:**

1. **Find working examples** — locate similar working code in the same codebase. What works that's similar to what's broken?
2. **Compare against references** — if implementing a pattern, read reference implementation COMPLETELY. Don't skim. Understand fully.
3. **Identify differences** — list every difference between working and broken, however small. Don't assume "that can't matter."
4. **Understand dependencies** — what other components does this need? What settings, config, environment? What assumptions does it make?

### Phase 3: Hypothesis and testing

**Scientific method:**

1. **Form single hypothesis** — state clearly: "I think X is the root cause because Y." Be specific, not vague.
2. **Test minimally** — make the SMALLEST possible change to test hypothesis. One variable at a time. Don't fix multiple things at once.
3. **Verify before continuing** — did it work? Yes → Phase 4. No → form NEW hypothesis. Don't add more fixes on top.
4. **When you don't know** — say "I don't understand X." Don't pretend. Ask for help. Research more.

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create failing test case** — simplest possible reproduction. Automated test if possible. **Use `/team-setup:tdd`** for the test-first cycle.
2. **Implement single fix** — address the root cause identified. ONE change at a time. No "while I'm here" improvements. No bundled refactoring.
3. **Verify fix** — test passes now? No other tests broken? Issue actually resolved?
4. **If fix doesn't work** — STOP. Count attempts. If < 3: return to Phase 1, re-analyze with new information. **If ≥ 3: STOP and question architecture** (step 5). Don't attempt Fix #4 without architectural discussion.
5. **If 3+ fixes failed: question architecture**
   - Each fix reveals new shared state/coupling/problem in different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **Pattern indicates architectural problem.** Discuss with your human partner before attempting more fixes. This is NOT a failed hypothesis — this is a wrong architecture.

## Red flags — STOP and follow process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- Proposing solutions before tracing data flow
- **"One more fix attempt"** (when already tried 2+)
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 1.**

If 3+ fixes failed: question the architecture (Phase 4 step 5).

## User signals you're doing it wrong

Watch for these redirections:
- "Is that not happening?" — you assumed without verifying
- "Will it show us...?" — you should have added evidence gathering
- "Stop guessing" — you're proposing fixes without understanding
- "Ultrathink this" — question fundamentals, not just symptoms
- "We're stuck?" (frustrated) — your approach isn't working

When you see these: STOP. Return to Phase 1.

## Rationalization-buster

| Excuse | Reality |
|---|---|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Quick reference

| Phase | Key activities | Success criteria |
|---|---|---|
| 1. Root cause | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| 2. Pattern | Find working examples, compare | Identify differences |
| 3. Hypothesis | Form theory, test minimally | Confirmed or new hypothesis |
| 4. Implementation | Create test (`/team-setup:tdd`), fix, verify | Bug resolved, tests pass |

## When process reveals "no root cause"

If systematic investigation reveals the issue is truly environmental, timing-dependent, or external:

1. You've completed the process.
2. Document what you investigated.
3. Implement appropriate handling (retry, timeout, error message).
4. Add monitoring/logging for future investigation.

**But:** 95% of "no root cause" cases are incomplete investigation.

## After substantial debug work

Per [ADR 0002](../../docs/decisions/0002-layered-enforcement.md), Write/Edit ≥50 lines triggers `review-required` (HARD-tier). Run `/team-setup:discipline-check` to dispatch `team-reviewer` for a final pass — ensures the fix addresses root cause, not symptom.

If the bug fix produced an ADR-worthy decision (e.g., "we now always retry on transient API failures"), capture via `/team-setup:doc-adr`.

## Don't

- Propose fixes before completing Phase 1.
- Skip the failing test in Phase 4.
- Bundle multiple fixes — one variable at a time.
- Continue past 3 failed fix attempts without architectural discussion.
