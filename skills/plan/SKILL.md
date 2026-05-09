---
name: plan
description: MUST use when you have a spec or requirements for a multi-step task, BEFORE touching code. Writes a comprehensive task-by-task implementation plan with bite-sized steps (2-5 min each), TDD-shaped where applicable, no placeholders, to `docs/features/<feature>/plan.md`. Chains forward to `/team-setup:execute`. Vendored from `superpowers:writing-plans` v5.1.0; runs in a forked subagent (`team-setup:planner`) so plan generation doesn't bloat main-thread context.
context: fork
agent: planner
---

# plan

Write implementation plans that assume the engineer has zero context for our codebase and questionable taste. Each step is a bite-sized action (2-5 min). DRY. YAGNI. TDD where applicable. Frequent commits.

**Vendored from `superpowers:writing-plans` v5.1.0** — adapted for team-setup voice, ADR refs, and feature-grouped layout.

**Announce at start:** "I'm using `/team-setup:plan` to create the implementation plan."

## Required preparation

1. Read [`../SHARED.md`](../SHARED.md) for tone + ecosystem.
2. Read the feature's design: `docs/features/<feature>/design.md` (produced by `/team-setup:brainstorm`).
3. Read [ADR 0002 layered enforcement](../../docs/decisions/0002-layered-enforcement.md) and [ADR 0003 feature-grouped docs](../../docs/decisions/0003-feature-grouped-docs.md).
4. Run `git branch --show-current` for branch context.

## Save plans to

`docs/features/<feature>/plan.md` (per ADR 0003). The folder was scaffolded by `/team-setup:doc-feature` during brainstorming — `plan.md` already exists with starter frontmatter; replace the body with your plan.

## Scope check

If the design covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File structure

Before defining tasks, map out which files will be created or modified and what each is responsible for. Decomposition decisions get locked in here.

- Design units with clear boundaries and well-defined interfaces. One responsibility per file.
- Smaller focused files = more reliable AI edits (Claude reasons better about code held in context at once).
- Files that change together should live together. Split by responsibility, not technical layer.
- In existing codebases, follow established patterns. If a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

## Bite-sized task granularity

Each step is one action (2-5 minutes):

- "Write the failing test" — step
- "Run it to make sure it fails" — step
- "Implement the minimal code to make the test pass" — step
- "Run the tests and make sure they pass" — step
- "Commit" — step

## Plan document header

Every plan must start with this header (after the frontmatter scaffolded by `/team-setup:doc-feature`):

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `/team-setup:execute` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## TDD note (per ADR 0002)

TDD is SOFT-tier discipline: recommended, not blocked. For most plans, structure tasks around the test-first cycle. For non-testable changes (config, docs, refactor with full coverage), skip the test step but mark it explicitly: `# (no test — refactor preserves behavior; existing tests cover)`.

## No placeholders

Every step must contain the actual content an engineer needs. These are plan failures — never write them:

- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may read tasks out of order)
- Steps that describe WHAT to do without showing HOW (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember

- Exact file paths always.
- Complete code in every step — if a step changes code, show the code.
- Exact commands with expected output.
- DRY, YAGNI, TDD-where-applicable, frequent commits.

## Self-review

After writing the complete plan, check it against the design with fresh eyes. Run yourself — not a subagent dispatch.

1. **Spec coverage:** skim each section of `design.md`. Can you point to a task that implements it? List any gaps.
2. **Placeholder scan:** search your plan for red flags from "No placeholders" above. Fix them.
3. **Type consistency:** do types, method signatures, property names match across tasks? `clearLayers()` in Task 3 vs `clearFullLayers()` in Task 7 is a bug.
4. **Branch awareness:** if on a feature branch, file paths should reflect the branch's structure (not main's).

Fix issues inline. No re-review — just fix and move on.

## Execution handoff

After saving the plan:

> "Plan saved to `docs/features/<feature>/plan.md`. Run `/team-setup:execute` to implement task-by-task with checkpoint reviews. On platforms with subagent support, execute can dispatch fresh subagents per task."

## Don't

- Skip the design phase ("brainstorming was enough"). Plan is its own artifact.
- Write plans without exact file paths or complete code blocks.
- Force tasks past blockers — if the design has gaps, go back to `/team-setup:brainstorm`.
