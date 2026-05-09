---
name: write-tech-plan
description: Write technical plans — the engineering blueprint for HOW we build things. References product docs for WHAT, focuses on approach, trade-offs, phases, and risks. Use when proposing technical approaches, planning refactors, or designing implementation strategies.
---

# Write Tech Plan

Write tech plans that explain HOW we build what Product decided. The product doc captures WHAT and WHO confirmed it — the tech plan captures the technical approach, trade-offs, and implementation path.

If no product doc exists, flag it. Don't absorb Product requirements into the tech plan — that's what `/write-product-doc` is for.

## Inputs

- `$ARGUMENTS` — topic, feature name, or problem to write a tech plan for

## Process

1. Read shared rules: [SHARED.md](../SHARED.md) — tone, terminology, domain knowledge
2. Read relevant local docs for existing domain knowledge — **start from what's already documented**
3. Check if a product doc exists for this domain — if not, flag the gap
4. Read real examples for tone: [examples/good-tech-plans.md](examples/good-tech-plans.md)
5. Research the codebase for technical details (models, existing patterns, code paths)
6. Write the tech plan using the patterns and rules below
7. Review using the checklist at the bottom

## Document Structure

### Required core (every tech plan)

```markdown
# <Topic> — Tech Plan

{warning}No product doc exists for [domain]. Consider creating one with
/write-product-doc before proceeding.{warning}
<!-- OR -->
> Product requirements: [link to product doc or local_docs reference]

----

## Problem

What's broken, missing, or suboptimal. Concrete pain, not abstract goals.
Numbers, model names, real impact.

----

## Proposed solution

The recommended approach. What we're building and the key technical decisions.

----

## Trade-offs

Why this over alternatives.
<!-- For focused plans: inline prose. For full plans: decision matrix. -->

----

## Open questions

Always last. Unresolved decisions that need input.
```

### Optional depth sections

Include these based on complexity — not every plan needs all of them.

| Section | When to include |
|---------|----------------|
| **Current state / gap analysis** | When the problem isn't obvious — reader needs to see what exists today |
| **Alternative approaches** | When 3+ approaches were considered — use a decision matrix |
| **Implementation phases** | When work spans multiple PRs or has ordering constraints |
| **Effort estimate** | When leadership needs to approve scope — T-shirt sizes, not hours |
| **Testing strategy** | When testing is non-trivial (migrations, integrations, feature flags) |
| **Monitoring / rollback** | When the change touches production data or is risky to deploy |
| **Risks** | When there are known unknowns or dependencies on other teams |

### Section order

1. Product doc reference or gap flag
2. Problem
3. Current state / gap analysis *(optional)*
4. Proposed solution
5. Alternative approaches *(optional)*
6. Trade-offs
7. Implementation phases *(optional)*
8. Effort estimate *(optional)*
9. Testing strategy *(optional)*
10. Monitoring / rollback *(optional)*
11. Risks *(optional)*
12. Open questions *(always last)*

## Writing Patterns

### 1. Problem-solution pair (default)
State the pain, then the fix. Every tech plan has this.

### 2. Decision matrix
When 3+ approaches need comparing. Table with criteria as rows, approaches as columns. End with a bolded recommendation.

### 3. Phase breakdown
Multi-step implementation. Numbered phases with scope, dependencies, and a deliverable per phase. No "Phase 3: TBD."

### 4. Before/after comparison
Refactors or migrations. Show what the code/data looks like now vs after. Use real model names and code snippets.

### 5. Risk-mitigation pair
Each risk gets a concrete mitigation or fallback. Table format: Risk | Impact | Likelihood | Mitigation.

### 6. Real-world validation
Test the proposal against actual production data. Table showing what happens today vs what the proposal produces.

## Tone (extends SHARED.md)

- **Be opinionated** — tech plans recommend an approach. "We should use X because Y" not "We could use X or Y."
- **Lead with the recommendation** — present the preferred approach first, then alternatives. Don't bury the lede.
- **Quantify** — "affects 12,000 records", "adds ~200ms", "3 phases over 2 sprints." Vague = useless.
- **Name the models** — tech plans are for engineers. Use `RentalOptionFee`, `SROItemFee`, not "the fee record."
- **Flag unknowns as risks** — don't hide what you don't know. "We haven't confirmed if Yardi handles X" is better than silence.
- **Concrete over abstract** — "We'll migrate 12,000 records in 3 batches" beats "We'll migrate the data."

## Formatting (JIRA-friendly)

- Output should be JIRA-friendly markdown
- Use JIRA features:
  - `{expand:Title}...{expand}` for expandable sections (queries, large code blocks, production data)
  - `----` for dividers between major sections
  - `{info}`, `{warning}`, `{note}` panels for callouts
- Code snippets in expandable sections when they're supporting detail, not the main point
- Keep the main reading path clean — a reader should get the gist from headers + first sentences

## Review Checklist

After writing, check the tech plan for:
- **Problem clarity** — could someone who's never heard of this domain understand WHY after reading just the problem statement?
- **Product doc reference** — is there a link? If not, is the gap flagged?
- **Missing alternatives** — did you only present one approach? If so, why not others?
- **Vague estimates** — "this will take a while" → quantify or remove
- **Missing risks** — touches production data? Migration? External dependency? Each needs a risk + mitigation.
- **Orphan phases** — does each phase have clear scope and a deliverable? No "Phase 3: TBD"
- **Stale terminology** — check against glossary
- **Open questions placement** — unresolved decisions should be in Open Questions, not buried in prose
- **Concrete over abstract** — replace vague statements with numbers, model names, real examples

## What to Avoid

- Corporate-speak: "The system shall ensure that..."
- Absorbing Product requirements — if you're documenting WHAT Product decided, use `/write-product-doc`
- Walls of text — if you have 3+ approaches, use a decision matrix
- Missing the problem — jumping straight to solution without establishing WHY
- Hiding unknowns — flag gaps explicitly rather than leaving them out
- Vague phases — "Phase 3: finish remaining work" tells the reader nothing
