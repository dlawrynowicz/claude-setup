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
- Date-stamp volatile claims. When a statement could change ("X is used for Y", "the refactor isn't live", "this is the active config"), prefix it: "As of March 2026, ...". A reader years later should know whether to trust it.
- Bridge plain language to models in one move. State the requirement in product terms, then a "Technically, it means..." sentence mapping it to model names. Keeps the WHAT readable and the HOW precise.

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

### Comments and docstrings

Plain natural language, short, no robot-speak — the canonical rule lives in the global `CLAUDE.md` Voice section (no fancy words, no arrow chains, test docstrings describe behavior). The reviewer flags robotic comments.

**Most comments are redundant — delete them.** Cut any comment that restates the symbol it sits above (a header paraphrasing the function/const/type name). Never name the feature, ticket, or flag in a comment, and don't cross-reference old/replaced code ("Mirrors X", "lifted from Y"). Keep only what a reader can't infer: real domain *why*, what a cryptic field actually holds, and empty-`catch`/empty-block notes.

**Line breaks — default to one line.** Enforced by `lib/wrap_comments.py`, which the `wrap-comments` PostToolUse hook runs on each Python, TypeScript and JavaScript file written, rewrapping only comments next to lines that changed. Run it by hand with `--check` in CI. The rest of this rule is what it implements.

A single sentence stays on one line, commas and all. Break only when a comment is genuinely long: put one sentence per line, or for a single long sentence wrap at a clause boundary so each line ends in `,`/`.`/`:` — never mid-phrase, and an abbreviation's period (`e.g.`, `i.e.`, `etc.`, `vs.`) is not a boundary. Don't split a short sentence just because it contains a comma.

```
# wrong — short sentence split on its comma
# Usually the lease start date,
# unless a setting moves it.

# wrong — wrapped mid-phrase ("30-day / calendar flag")
# ignores the 30-day
# calendar flag

# wrong — broke after an abbreviation's period ("e.g.")
# paid line items (e.g.
# holding deposits) skip the sync

# right — short sentence, one line
# Usually the lease start date, unless a setting moves it.

# right — two sentences, one per line
# The 30-day calendar passes days_in_month=30.
# A 31st move-in still prorates to 1 day.
```

### House style: copy the codebase's clearest comments

The comments reviewers hold up as good share a shape. Match it. Every example below is real, from `chuck/quotes/`.

**Branching on a domain case? Lead-in line, then one bullet per case.**

```python
# Find which fees to create for the selected rental option:
# - For renewals, we only want to create the monthly fees
# - For applications and transfers, we want to create all the fees
```

The lead-in says what the code is deciding. Each bullet names the transaction type in domain words rather than the `isinstance` check, then says what happens for it. This is the single biggest difference between our clearest comments and AI-written ones, which reach for a prose paragraph where a case list belongs.

**Write "we", present tense.** "we carry-over the edited categories from previous quote", "we return an empty list", "we need to find the previous quote from the last completed transaction". Never "the system", never passive.

**Lead with the human word, put the code word in `(i.e. ...)`.**

```python
"""
Application fee is added to a transfer when adding a new roommate
(i.e. applicant role, both a new item on the rental option and a new line item).
"""
```

"roommate" first, `applicant role` in the parenthetical. A reader who knows the product follows the sentence; a reader who knows the models still gets the mapping. Leading with the model name and never mentioning the human word is an AI habit worth dropping.

**Quote a setting by its label, not its field name.** `the fee is marked as "do not increase fee for residents"` — that is the wording the agent sees on screen, so it is the wording that lets someone check the setting.

**Say when you don't know.**

```python
# The new quote is for a reconciliation, in that case we also clear the end date
# (the WHY is not clear for me)
```

An honest gap beats an invented rationale. It also tells the next person there is something real to find out. Never manufacture a reason to make a comment sound finished.

**Name the road not taken when you deliberately avoided the obvious one.**

```python
# Add the selected rental option to the quote manually using the creator,
# and not using the orchestrator, to control which fees are created.
```

This is not the defensive justification the rule above bans. Naming an alternative you considered and rejected, plus what it would have cost, is genuine *why* that the code cannot show. Narrating what the code does not do ("in one query", "avoids an N+1") is still noise.

**Take the words from the project's glossary.** Every project keeps one (chuck: `docs/glossary.md`). A comment that coins a synonym for a term the team already has is the most common way AI writing reads as foreign. When a concept has a house word, use the house word; when it does not, say the plain thing rather than inventing a noun. `/team-setup:glossary-check` scans changed files for drift.

**What this replaces.** Three habits that make AI comments hard to read: an abstract noun coined for the occasion where the codebase already has a word; a flowing paragraph where the code branches on three named cases; and narrating the mechanism the reader can already see. If a comment needs a second read, it is usually one of those.

### Naming — descriptive, never terse or vague

Vague names are the thing that gets corrected in review most. Get them right the first time — code Claude writes should not need a naming-correction round-trip. Language-specific bits (Python `is_`/`create_` verbs and the creator/orchestrator prefixes; TS typed domain models) live in the per-language clean-code skills; these apply everywhere:

- **Functions are verbs, spelled out.** Name a function for the work it does. No terse or abbreviated verbs — a `to*` prefix or an `*Ops`/`*Cfg` suffix says too little (`toOperation`, `toStagedHistoricalOps`, `toSettings`, `categoryEditOps` are all vague about source and result). Use `build<Noun>` / `<verb><Noun>`: `buildStagedHistoricalOperations`, `buildAddOperationsForDraft`, `buildSettingsBlock`. Keep ONE verb prefix across a file — don't mix `to*` and `build*`.
- **Locals and params are domain names too.** Avoid generic `row`/`data`/`item`/`obj`/`result` when the thing has a name. **No single-letter lambda params** — `r`/`li`/`b`/`f`/`i`/`x` say nothing; name what they hold (`row`, `waiveFlag`, `quotedFee`). The only truly-generic pass is a `reduce` accumulator like `total`.
- **Name a variable for what it holds, not the role it plays in one check.** Mirror the source property (`firstLeaseStartDate = quote.first_lease_start_date`, not `floor`); name a map for what it keys and holds (`initialAmountByChangelogId`, not `before`). Role/metaphor names (`floor`, `threshold`, `bound`) and adjective-as-noun names (`tooEarly`, `others`) hide the domain thing.
- **Reuse the codebase's existing word** — grep first, match the established local name for a type, don't coin a synonym or churn.
- **No magic strings for a closed set.** A value from a fixed vocabulary (an action/kind discriminator, a status, a mode) gets ONE symbolic source and every use references a member, never the bare literal. Mechanics per language: Python `str` Enum + `Literal[Enum.MEMBER]`; TS `as const` object + `typeof OBJ.KEY`.

### Abstraction & DRY — share the rule, don't over-engineer

- **One class per case beats a switch ladder repeated everywhere.** When the same fixed set of kinds gets branched on in more than one place — validate, execute, and permissions each doing `if kind == add … elif kind == edit …`, or a pile of parallel private methods (`_add_standard`, `_edit_historical`, `_remove_standard`, …) — that repeated parallel structure is the smell. Give each case its own small class that owns its own validate + execute; the caller loops and never branches on kind. A 700-line service with an isinstance ladder becomes a thin loop plus one readable file per case. Adding a case is a new file, not another arm in three switches.
- **Make a shared guard unskippable.** When a base class runs a guard then hands off to subclasses, settle the entry method IN the base and have it call a hook the subclass fills — don't leave each subclass to remember `super().check()`. A forgotten `super()` silently drops the guard and no test catches it.
- **A context object owns the shared lookups — don't staple state onto a domain model.** When several steps share cached lookups (the addable set, a resolved row), put them on a small context/request object passed to each step, not as attributes monkeypatched onto a model (`quote._addable = …`). The model stays clean and the cache has one owner.
- **DRY the rule, not the mechanics.** A domain rule used by both validation and display (e.g. "is this fee removable") gets ONE definition so the two can't drift. Put an entity's predicate on the entity (a read-only model method), not a standalone module.
- **Don't trade duplication for indirection.** A dispatch table / registry of callables is NOT automatically cleaner than an explicit `if/elif` for a small, fixed set — prefer the explicit version when it reads plainly top-to-bottom. If you'd flag it as over-engineered in review, don't build it.
- **Judge a constant by its call sites, not its definition.** A symbolic map whose value equals its key (`OP_ACTION = { ADD: 'ADD' }`) looks like dead indirection but earns its keep — it names the concept and gives every call site one edit point, so a wire-value change touches one line, not twenty. Don't delete it for scattered literals. Conversely, an export / `__all__` entry / type alias nothing outside the module imports IS dead — delete it.
- **A contract written on both sides is the real duplication.** When an enum lives in the backend and is retyped in the frontend, that's the DRY concern — not the surface spelling. Changing casing or formatting doesn't fix it; a shared source (exported constants / codegen) does. Absent that, keep the two in sync deliberately and don't pretend a cosmetic tweak dedupes them.
- **One caller is not a smell.** A query method or a mutation helper with a single caller is fine when it's idiomatic encapsulation — don't inline it just to cut a method.
- **No silent guards in a shared method.** If callers already validate the input, the shared method assumes a valid input — don't add a guard that swallows bad input (`if x is None: return None`). Keep any back-compat guard local to the one caller that needs it.
- **Don't refactor legacy to reuse new code.** When new code (behind a flag) sits beside a legacy path that's deleted when the flag retires, keep legacy byte-for-byte — new↔legacy duplication is intentional and temporary.

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
