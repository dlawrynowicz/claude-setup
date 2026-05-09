---
name: write-e2e-test-plan
description: Generate E2E test plans for features — what to test, why, and what data you need. Use when completing a feature, preparing for QA, or planning manual/automated testing.
---

# Write E2E Test Plan

Generate test plans that answer: what do we need to test to be confident this feature works? Covers happy paths, edge cases, and regressions — written so QA, PM, or another engineer can execute them.

## Inputs

- `$ARGUMENTS` — feature name, ticket reference, or product doc reference

## Process

1. Read shared rules: [SHARED.md](../SHARED.md) — tone, terminology, domain knowledge
2. Read the relevant product doc or ticket for requirements and acceptance tests
3. Read the implementation to understand what actually changed (git diff, modified files)
4. Identify test scenarios beyond what acceptance tests cover — edge cases, regressions, integration points
5. Write the test plan using the structure below
6. Review using the checklist at the bottom

## Structure

```markdown
# E2E Test Plan: <Feature Name>

## What changed

One paragraph summary of the feature — what it does, who it affects, where it shows up.

## Test data setup

What needs to exist before testing:
- Communities, units, rental options, lease profiles, etc.
- Specific configurations that enable the feature
- Existing transactions in specific states

## Test scenarios

### <Area 1> (e.g., "Quote creation", "Start Application modal")

#### Scenario 1: <descriptive title>

**Why:** <one line — what risk does this test mitigate?>

**Given** ...
**When** ...
**Then** ...

---

#### Scenario 2: ...

### <Area 2> (e.g., "Lease profile change mid-application")

...

## Regression risks

Things that might break because of this change:
- <Area> — <why it might be affected>
- <Area> — <why it might be affected>

## Not in scope

What this test plan does NOT cover and why.
```

## Writing Rules

### Scenario Organization
- Group by user-facing area (where in the UI), not by code path
- Order within group: happy path first, then edge cases, then error cases
- Each scenario gets a "Why" line — if you can't explain why it matters, drop it

### Scenario Quality
- Every scenario must test something the acceptance tests DON'T already cover
- Don't duplicate acceptance tests — reference them ("Covered by ticket Test 1-4")
- Focus on integration points — where different parts of the feature meet
- Focus on state transitions — what happens when you go from state A to B
- Focus on regressions — what existing behavior could this change break

### What to Test and Why
- **Happy paths** — does the feature work as designed? (acceptance tests usually cover this)
- **Edge cases** — what about empty states, max values, concurrent actions?
- **Cross-feature interactions** — does this feature play nicely with related features?
- **Role/permission variations** — does it work for all relevant user types?
- **Data migration** — what about existing data created before this feature?
- **Regressions** — what existing flows touch the same code we changed?

### What NOT to Include
- Unit test scenarios — those belong in code, not a test plan
- Technical implementation details — no function names, model fields, code paths
- Scenarios that are already acceptance tests in the ticket — just reference them
- Unrealistic scenarios that can't happen in production

### Format
- Use `#### Scenario N:` headers (same as ticket acceptance tests)
- Bold `**Given**`/`**When**`/`**Then**`/`**And**` keywords
- `---` separators between scenarios
- Concrete data (names, amounts, dates) — not abstract descriptions
- "Why" line explains the risk, not the requirement

### Tone
- Write for someone who will execute these tests — be specific enough to follow
- Don't over-specify UI steps ("click the dropdown, select...") — describe the action at the right level ("select the Corporate lease profile")
- Include expected visual outcomes where relevant ("the fee should appear in the pricing breakdown")

## Review Checklist

After writing, check:
- Does every scenario have a "Why" that justifies its existence?
- Are acceptance tests referenced, not duplicated?
- Are regression risks specific (not generic "might break something")?
- Would a QA engineer know exactly what to do from reading this?
- Are cross-feature interactions covered?
- Is existing data / migration considered?
