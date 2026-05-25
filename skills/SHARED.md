# Shared Rules — Funnel Skills

All Funnel-specific skills MUST read this file first. It defines the shared language, terminology, and domain knowledge that every skill uses.

## Before You Start

1. If it exists, read the glossary: `docs/glossary.md` (in chuck: `/Users/broda/work/funnel/chuck/docs/glossary.md`)
2. Read any relevant docs in the current project's `docs/` directory for existing domain knowledge — **start from what's already documented, only research the codebase for what's missing**
3. Check if the topic already has documentation. If it does, build on it — don't duplicate.

## Tone

- Write like you're explaining to a teammate who just joined the team
- Use "we" language: "we should add", "we already have", "we carry over the SRO"
- Describe current behavior as fact, gaps as gaps
- Short sentences. No filler. No corporate-speak. No robot-speak ("The system shall ensure...")
- Don't hedge — if it's confirmed, state it. If it's uncertain, flag it explicitly.

### Display copy: let punctuation set the line breaks

For presentation/display text — slide copy, hero lines, big callouts (not flowing markdown prose) — break each line at sentence and clause boundaries (`.` and `,`), one clause per line. It reads with spoken rhythm instead of a robotic wall of text.

- Place the breaks yourself (`<br>`, or a new line); let the punctuation decide where.
- Don't lean on a narrow container to wrap — it splits clauses at random ("talk / about."). Widen the container so each clause stays whole on its line.

## Quality Bar: Pass Technical Review

Our output is reviewed by senior engineers who are skeptical of AI-generated work. Every artifact must read like a senior engineer wrote it — not like AI generated it. Reviewers will flag:
- **Vague language** that shows you didn't read the code — be precise, name specific behaviors
- **Over-explanation** of obvious things — if a senior dev knows it, skip it
- **Missing edge cases** that only someone who read the code would catch — show deep understanding
- **Formulaic structure** that screams template — vary structure based on content, don't force every section
- **Wrong or superficial technical claims** — verify before writing, or don't write it
- **Hedging when you should decide** — "we might want to consider" is weak, "we should" is strong

Make non-obvious decisions. Show you understand WHY, not just WHAT. If you cite a behavior, know where it lives in the codebase. The goal is that a reviewer cannot tell whether a human or AI wrote it.

## Terminology

- ALWAYS use glossary terms consistently
- If a glossary exists, read it before writing — if a term exists there, use it
- Use model names when they clarify, but don't over-specify — "the SROItemFee" is fine after first mention
- If you need a term that's not in the glossary, flag it — it might need adding
- Never use: "catalog values" (say "RO defaults"), "suppression" (say "deposit alternative"), "digital application" (say "Woodhouse")

## Domain Knowledge

Domain docs live in chuck (`/Users/broda/work/funnel/chuck/docs/`). Key references:

- `glossary.md` — standard terms
- `rental_options.md` — three-tier model, scheduled pricing, validation rules
- `transactions.md` — all 6 transaction types, behavioral matrices
- `carry_over.md` — carry-over lifecycle, transition matrix
- `fees_breakdown.md` — fees breakdown system, proration rules
- `integrations.md` — OL↔PMS push flows, Yardi batch system
- `cdo_architecture.md` — Creator/Deleter/Orchestrator pattern
- `scheduled_price_changes.md` — scheduled price update rules, behavioral matrix

Not all docs exist yet — read what's available, skip what's missing.

## Skill Workflow

Product doc first, tech plan second. When starting a new domain:
1. `/write-product-doc` — captures WHAT Product decided, with sources
2. `/write-tech-plan` — captures HOW we build it, references the product doc
3. `/write-ticket` — converts into implementation tickets

If no product doc exists when writing a tech plan, flag the gap.

After completing feature work:
4. `/update-docs` — captures domain knowledge discovered during the feature

## Living Documents

Domain knowledge gets discovered across different feature branches, tickets, standups, and grooming sessions. Local docs are the single place where it all gets aggregated — regardless of which branch or sprint it came from. When you learn something new about a domain while working on a feature, update the relevant doc.

## Code writing conventions

### Implementation before imports

Write the body that USES imports BEFORE adding the import statements at the top of a file. Format-on-save tools (TypeScript `organizeImports`, ESLint `no-unused-vars` autofix, ruff, etc.) strip imports they see as unused — if the body using them isn't there yet, save deletes them and the next compile fails.

Workarounds:
- Body and imports in a single Write/Edit so the linter sees both at the same time.
- For TDD RED phase (test imports a function that doesn't exist yet), implement the export stub first — even just `export const foo = () => { throw new Error('unimplemented') }` — then write the test that imports it.
- Disable format-on-save during scaffolding when project tooling fights you.

Applies to `tdd`, `execute`, `brainstorm` (when generating example code), and any skill that produces code.

## Skill authoring

Every new skill (vendored or original) must:

1. **Reference our docs** — `CLAUDE.md`, `docs/glossary.md`, relevant ADRs ([0001](../../docs/decisions/0001-build-before-install.md) build-before-install, [0002](../../docs/decisions/0002-layered-enforcement.md) layered enforcement, [0003](../../docs/decisions/0003-feature-grouped-docs.md) feature-grouped docs, [0004](../../docs/decisions/0004-vendor-for-learning-build-for-owning.md) vendor for learning).
2. **Follow our voice** — terse, "we" voice, matrix format, no formal phrasing.
3. **Understand the ecosystem** — know what hooks fire (`capture-nudge` on Write/Edit ≥10 lines, `review-required` on Write/Edit ≥50 lines, `session-start` doc-audit), what companion skills exist (chain into them), what agents are available (`team-setup:team-reviewer`, plus generics).
4. **Integrate, don't relabel** — a new skill that doesn't fit our ecosystem is a missed opportunity. The point of a custom skill is *team integration*, not relabeling existing patterns.
5. **Descriptions are trigger surfaces, not metadata storage.** Lead with imperative phrasing ("MUST use when X" / "MUST use BEFORE Y"). Capture the trigger keywords up front (the user's likely vocabulary). Operational details and vendoring sources go AFTER the trigger description — never before. Soft descriptions = quiet skills = no auto-trigger. We learned this when vendored skills failed to fire because we softened upstream's aggressive "MUST use" framing to descriptive "Use when".

For vendored skills specifically, see [ADR 0004 §"Vendoring requirements"](../../docs/decisions/0004-vendor-for-learning-build-for-owning.md) — additional rules on stripping, source documentation, and discipline inheritance.

**Note on the meta-skill** — `using-team-setup` is the always-on meta-skill that forces invocation of other team-setup skills via imperative framing. It's what makes the rest fire instead of Claude defaulting to "explore first." Vendored from `superpowers:using-superpowers`. If individual skills aren't auto-firing despite aggressive descriptions, check that `using-team-setup` is loaded (its description must include "MUST use when starting any conversation").

## Agent Dispatch

When a skill dispatches an agent (`feature-dev:code-architect`, `feature-dev:code-explorer`, `team-setup:team-reviewer`, etc.), include this in the prompt:

> *"Apply our team discipline — see `./CLAUDE.md` and `./docs/decisions/`. Specifically: TDD, DRY (3+ repeats abstract), SOLID, no shortcuts on security or architecture."*

Three layers of discipline:
- **L1 (agent system prompt):** specialized agents bake the rules in (e.g., `team-setup:team-reviewer`). Use only when the agent's primary output IS a verdict against rules.
- **L2 (dispatch prompt):** generic agents get the rules forwarded by the orchestrator. Use for design / planning agents whose output flows back through Claude.
- **L3 (Claude main context):** value-neutral agents (e.g., `code-explorer`) operate fine without team awareness. Claude applies discipline post-hoc to their findings.

Don't fork every plugin's agent. Specialize where it earns its keep; pass discipline forward elsewhere.
