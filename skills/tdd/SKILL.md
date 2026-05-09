---
name: tdd
description: MUST use when implementing any feature or bugfix, BEFORE writing implementation code. Test first, watch it fail, write minimal code to pass — Iron Law: no production code without a failing test first. Rigid recipe; per ADR 0002, project-level TDD is SOFT-tier but invoking THIS skill commits to the strict cycle. Vendored from `superpowers:test-driven-development` v5.1.0.
---

# tdd

Write the test first. Watch it fail. Write minimal code to pass.

**Vendored from `superpowers:test-driven-development` v5.1.0** — adapted for team-setup voice + ecosystem; rigid recipe preserved.

**Core principle:** if you didn't watch the test fail, you don't know if it tests the right thing.

**Violating the letter of the rules is violating the spirit of the rules.**

## When to use

**Always:**
- New features
- Bug fixes
- Refactoring
- Behavior changes

**Exceptions (ask your human partner):**
- Throwaway prototypes
- Generated code
- Configuration files

Thinking "skip TDD just this once"? Stop. That's rationalization.

Per [ADR 0002 layered enforcement](../../docs/decisions/0002-layered-enforcement.md), TDD is SOFT-tier at the project level — the project doesn't auto-block non-TDD code. But invoking **this** skill commits you to the rigid recipe.

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone + ecosystem.
2. Read [ADR 0002 layered enforcement](../../docs/decisions/0002-layered-enforcement.md).
3. Run `git branch --show-current` for context.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete

Implement fresh from tests. Period.

## Red-Green-Refactor

```
RED (write failing test) → verify fails correctly
  → GREEN (minimal code) → verify passes (all tests green)
  → REFACTOR (clean up, stay green)
  → next test
```

### RED — write failing test

Write one minimal test showing what should happen.

**Good:**
```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };
  const result = await retryOperation(operation);
  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```
Clear name, tests real behavior, one thing.

**Bad:**
```typescript
test('retry works', async () => {
  const mock = jest.fn().mockRejectedValueOnce(new Error()).mockResolvedValueOnce('success');
  await retryOperation(mock);
  expect(mock).toHaveBeenCalledTimes(3);
});
```
Vague name, tests mock not code.

**Requirements:** one behavior · clear name · real code (no mocks unless unavoidable).

### Verify RED — watch it fail

**MANDATORY. Never skip.** Run the test. Confirm:

- Test fails (not errors)
- Failure message is expected
- Fails because feature missing (not typos)

**Test passes?** You're testing existing behavior. Fix the test.
**Test errors?** Fix the error, re-run until it fails correctly.

### GREEN — minimal code

Simplest code to pass the test. **Don't add features, refactor other code, or "improve" beyond the test.**

### Verify GREEN — watch it pass

**MANDATORY.** Run the test. Confirm:

- Test passes
- Other tests still pass
- Output pristine (no errors, warnings)

**Test fails?** Fix code, not test.
**Other tests fail?** Fix now.

### REFACTOR — clean up

After green only:
- Remove duplication
- Improve names
- Extract helpers

Keep tests green. Don't add behavior.

### Repeat

Next failing test for next feature.

## Good tests

| Quality | Good | Bad |
|---|---|---|
| Minimal | One thing. "and" in name? Split it. | `test('validates email and domain and whitespace')` |
| Clear | Name describes behavior | `test('test1')` |
| Shows intent | Demonstrates desired API | Obscures what code should do |

## Rationalization-buster

| Excuse | Reality |
|---|---|
| "I'll write tests after" | Tests passing immediately prove nothing. Might test wrong thing or implementation, not behavior. |
| "I already manually tested" | Manual = ad-hoc, no record, can't re-run. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "TDD is dogmatic, I'm pragmatic" | TDD **is** pragmatic — finds bugs before commit, prevents regressions, documents behavior, enables refactoring. |
| "Tests after = same goal" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "Test hard = design unclear" | Listen to the test. Hard to test = hard to use. |
| "Existing code has no tests" | You're improving it. Add tests for existing code. |

## Red flags — STOP and start over

- Code before test
- Test after implementation
- Test passes immediately
- Can't explain why test failed
- Tests added "later"
- Rationalizing "just this once"
- "Keep as reference" or "adapt existing code"

**All of these mean: delete code. Start over with TDD.**

## Verification checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

Can't check all boxes? You skipped TDD. Start over.

## When stuck

| Problem | Solution |
|---|---|
| Don't know how to test | Write wished-for API. Write assertion first. Ask your human partner. |
| Test too complicated | Design too complicated. Simplify interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify design. |

## Debugging integration

Bug found? Write failing test reproducing it. Follow TDD cycle. Test proves fix and prevents regression. Never fix bugs without a test.

For systematic debugging, hand off to `/team-setup:debug` after a TDD-driven fix.

## After substantial TDD work

Per [ADR 0002](../../docs/decisions/0002-layered-enforcement.md), Write/Edit ≥50 lines triggers `review-required` (HARD-tier). Run `/team-setup:discipline-check` to dispatch `team-reviewer` for a final pass — TDD coverage is one of the things it checks.

## Final rule

```
Production code → test exists and failed first
Otherwise → not TDD
```

No exceptions without your human partner's permission.

## Don't

- Skip the verify-RED step. It's the proof that the test actually tests the thing.
- Keep code "as reference" — that's testing after, with extra steps.
- Soften the Iron Law because the project's overall TDD policy is SOFT (ADR 0002). The project tolerates non-TDD work; THIS skill, when invoked, doesn't.
