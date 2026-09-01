# Shared Rules

Every skill in this plugin MUST read this file first. It defines the shared voice, conventions and code-quality rules the other skills build on.

Examples throughout use a subscription-billing domain (plans, subscriptions, invoices, line items) purely to stay concrete. Substitute your own domain's nouns; the rules are what carry over.

## Before You Start

1. If the project keeps a glossary (usually `docs/glossary.md`), read it
2. Read any relevant docs in the current project's `docs/` directory for existing domain knowledge - **start from what's already documented, only research the codebase for what's missing**
3. Check if the topic already has documentation. If it does, build on it - don't duplicate.

## Tone

- Write like you're explaining to a teammate who just joined the team
- Use "we" language: "we should add", "we already have", "we carry the add-on over"
- Describe current behavior as fact, gaps as gaps
- Short sentences. No filler. No corporate-speak. No robot-speak ("The system shall ensure...")
- **Hyphens, never em-dashes.** Write `-` (with spaces around it when it joins clauses), never `—` or `–`. Applies to prose, comments, docstrings, docs, tickets and PR text. An em-dash is the clearest tell of AI-written text.
- Don't hedge - if it's confirmed, state it. If it's uncertain, flag it explicitly.
- Date-stamp volatile claims. When a statement could change ("X is used for Y", "the refactor isn't live", "this is the active config"), prefix it: "As of March 2026, ...". A reader years later should know whether to trust it.
- Bridge plain language to models in one move. State the requirement in product terms, then a "Technically, it means..." sentence mapping it to model names. Keeps the WHAT readable and the HOW precise.

### Display copy: let punctuation set the line breaks

For presentation/display text - slide copy, hero lines, big callouts (not flowing markdown prose) - break each line at sentence and clause boundaries (`.` and `,`), one clause per line. It reads with spoken rhythm instead of a robotic wall of text.

- Place the breaks yourself (`<br>`, or a new line); let the punctuation decide where.
- Don't lean on a narrow container to wrap - it splits clauses at random ("talk / about."). Widen the container so each clause stays whole on its line.

## Documentation voice

A doc describes what the system does. Most of what makes docs read as AI-written is everything else that creeps in.

- **Describe, don't instruct.** Cut reader-directed lines - "pick the right one", "handle both", "use X if you need Y". State the behavior; the reader decides what to do with it. Headings name their content: "Two shapes", not "Two shapes - pick the right one".
- **No questions about behavior we verified.** "Worth confirming that's intended", "should we…", "we may want to check" is conversation, not documentation. If we read the code, state what it does and take the open question to the team. An unconfirmed *requirement* is different - it still gets an explicit TODO with attribution.
- **Document our system, not someone else's.** Describe what we store, publish, and fire. Don't write what another team's integration has to change - give them our behavior and let them decide. "What Online Leasing publishes" beats "Do we need to change NSI?".
- **No meta-narration.** "Five steps.", "Read this first", "That was the point", "Nothing here was built specially for X". The content is the content.
- **Bullets, not run-ons.** Three or more items strung through a sentence with `·` or `/` is a list. Multi-attribute comparisons are tables.
- **Say what's important, then stop.** Length is not thoroughness. A reader who finds the answer in the first screen trusts the rest.

### Explaining a flow

When a doc explains how something works end to end, walk the real path in order - each step naming the function or file that does the work, and what it decides. A numbered walkthrough of the actual call path beats a summary of the outcome: it survives the next refactor because a reader can check it against the code.

## Quality Bar: Pass Technical Review

Our output is reviewed by senior engineers who are skeptical of AI-generated work. Every artifact must read like a senior engineer wrote it - not like AI generated it. Reviewers will flag:
- **Vague language** that shows you didn't read the code - be precise, name specific behaviors
- **Over-explanation** of obvious things - if a senior dev knows it, skip it
- **Missing edge cases** that only someone who read the code would catch - show deep understanding
- **Formulaic structure** that screams template - vary structure based on content, don't force every section
- **Wrong or superficial technical claims** - verify before writing, or don't write it
- **Hedging when you should decide** - "we might want to consider" is weak, "we should" is strong

Make non-obvious decisions. Show you understand WHY, not just WHAT. If you cite a behavior, know where it lives in the codebase. The goal is that a reviewer cannot tell whether a human or AI wrote it.

## Terminology

- ALWAYS use glossary terms consistently
- If a glossary exists, read it before writing - if a term exists there, use it
- Use model names when they clarify, but don't over-specify - the class name is fine after first mention
- If you need a term that's not in the glossary, flag it - it might need adding
- Keep the project's list of banned synonyms in its glossary, and follow it. Every team has words it has already rejected; reaching for a fresh one is the most common way writing reads as foreign.

## Domain Knowledge

Domain knowledge lives in the project, not in this plugin. Before researching the codebase, read what the project already documents - typically `docs/`, starting with the glossary, plus any `docs/features/<feature>/` folder for the area you are touching.

Read what exists, skip what doesn't, and add to it when you learn something the docs don't say.

## Skill Workflow

Product doc first, tech plan second. When starting a new domain:
1. `/write-product-doc` - captures WHAT Product decided, with sources
2. `/write-tech-plan` - captures HOW we build it, references the product doc
3. `/write-ticket` - converts into implementation tickets

If no product doc exists when writing a tech plan, flag the gap.

After completing feature work:
4. `/update-docs` - captures domain knowledge discovered during the feature

## Living Documents

Domain knowledge gets discovered across different feature branches, tickets, standups, and grooming sessions. Local docs are the single place where it all gets aggregated - regardless of which branch or sprint it came from. When you learn something new about a domain while working on a feature, update the relevant doc.

## Code writing conventions

### Check the data before you design

When a design turns on how data actually looks - "the unused option has no row", "imports always set this field", "this column distinguishes X from Y" - verify it against real data before building on it. The dev snapshot is a subsample and will mislead you: a scenario that appears twice locally can be 116 rows at production scale, and a field that looks unused locally can be set on 98% of real rows.

- **Query staging (full-scale) when the local answer would change the design.** Read-only aggregates: `count`, `values(...).annotate(Count(...))`. State the N in your write-up so the reader can judge it.
- **A single record is not a pattern.** Before generalising from one row, count how many rows share that shape. "I found one" and "this is how it works" are different claims.
- **Any count you report, produce with a command.** "Three callers", "two places do this", "nothing else uses it" - run the grep and paste the number you got, in the same message. A count recalled from earlier in the session is stale the moment you edit anything; a reviewer found a fourth caller of a hook reported as having three.
- **Name the discriminator and prove it discriminates.** If you claim field F separates real data from scaffolding, find a case where the two differ on F. If they don't, F is not the signal - keep looking. A field that never differs between the two cases is not a discriminator, however plausible its name.
- **When a check contradicts your earlier conclusion, say so plainly and re-derive.** Don't defend the first answer.

### Add nothing without a producer and a reader

Before adding a field, column, parameter, or flag: name the code that sets it to something other than its default, and the code that reads it. If either is "nothing yet", don't add it - a column plus a data migration to store one constant is pure cost, and it is cheap to add later when a caller exists.

The same test retires code: an export, type alias, or parameter nothing outside the module uses is dead. Delete it.

### A wide ripple is a question, not a chore

When one small change forces edits in many unrelated files - a pile of snapshots, every caller of a helper, a column added to a dozen fixtures - stop and ask whether the change is right, before doing the work. The size of the blast radius is evidence about the change itself.

The usual finding is that a default was carrying the ripple. Making an inert default real is not a small change: it applies to every existing caller at once. Fixing a shared modal so its test id reached the DOM churned 14 snapshots, because the component defaulted that id to a constant - one identical id stamped on every modal in the app, which would have collapsed analytics click-buckets and guaranteed ambiguous test selectors. Dropping the default instead fixed the real bug, touched two snapshots, and left every existing caller exactly as it was.

- **Ask what the old value was doing.** A default that never took effect has no users to protect - removing it is safer than propagating it.
- **Prefer the change that shrinks the diff** when both fix the bug. Fewer touched files is usually the more correct change, not the lazier one.
- **Updating N generated files by hand is the signal**, whether they are snapshots, fixtures or golden files.

### One write site

When two branches need the same field written, write it once. An extracted helper that duplicates the write (`obj.amount = x; obj.flag = y; obj.save()` in both the helper and the caller) is worse than one branch with a shared tail - the copies drift. Reach for a flag threaded through the function only if collapsing genuinely costs behaviour; usually the "extra" work on the other path is a no-op you can just run.

### Extract at the second caller

Refining "extract when reused": **one caller → inline it; two callers → extract.** Recheck the count after later edits in the same change - a helper that was correctly inlined at one caller should come back out when a second caller appears, and vice versa.

### The same rule for locals

A variable is a name you are asking the reader to hold. **A local used once, whose name adds nothing the expression doesn't already say, should be inlined.**

```python
# ✗ the expression already reads as "deposit or fee"
is_unit_security = self._unit_security_deposit_q() | self._unit_security_fee_q()
qs = qs.exclude(~is_unit_security, ...)

# ✓
qs = qs.exclude(~(self._unit_security_deposit_q() | self._unit_security_fee_q()), ...)
```

A single-use local earns its place when it does one of these - otherwise inline it:

- **It names something the expression doesn't.** `first_lease_start_date = quote.first_lease_start_date` is noise; `grace_period_ends = lease.start + timedelta(days=5)` is not.
- **It's assigned in a branch** and read after the branches rejoin.
- **It short-circuits expensive work.** Keeping a cheap check in its own name so a DB-touching property or an API call runs only when needed is a real reason - say so in the code's shape, by ordering the checks, not in a comment.
- **It breaks a genuinely unreadable expression** - but prefer restructuring (early returns) over naming the pieces.

Reordering to remove a local is only safe when the checks are equally cheap. Leading with a check that hits the database to avoid one variable trades a name for a query per row.

### Review feedback is a claim, not an instruction

A reviewer, a bot, or another agent telling you the code is wrong is evidence, not a verdict. Reproduce before you comply, and reproduce before you argue.

- **Apply the suggestion and run it.** The fastest way to settle a review comment about behaviour is to make the suggested change and watch the tests. A review bot claiming a change broke a lookup was settled in one command: its own patch produced the exact failure it warned about, while the branch passed.
- **A confident reviewer can be exactly backwards.** Check the library source for the mechanism before accepting a claim about it - the prop that "everyone relies on" turned out never to have rendered at all.
- **Separate the true half from the wrong conclusion.** The same comment noted a real artifact (an undefined prop in a snapshot) and drew the wrong inference from it. Answer both parts.
- **When it turns out the reviewer is right, say so plainly and fix it** - no defending the first answer.
- **Reply with the command and its output**, not with reasoning alone. It ends the thread.

### Implementing from a ticket: ask before you restrict

A ticket describes a target state in product prose. Turning that prose into code involves guesses, and the expensive guesses are always the ones that *take something away*. Two rules, both learned from getting them wrong:

**A sentence that forbids something is ambiguous - ask which kind it is.** "The expectation is that they CAN NOT make any other changes when doing this action" can mean the system rejects the combination, or that agents are trained not to do it. Those produce completely different code: one is a validation error and a rollback, the other is nothing at all. Tells that it is a process expectation, not a constraint: it is addressed to a person ("@Katy please help me communicate this"), it says "expectation" rather than naming an error, or it describes what agents *should* do rather than what the system does. When it is genuinely unclear, ask - the cost of asking is one message, the cost of guessing is a feature nobody wanted.

**Never narrow behavior that already shipped without asking.** The ticket says what should be true; it is not a diff against the branch you are on. When the ticket implies a restriction the code doesn't have, the honest reading is usually "the ticket describes this area loosely", not "we must go and remove what we built last week". Read the branch first, and when the ticket appears to contradict shipped behavior, say so and ask which wins.

**Before implementing any restriction, name what breaks.** Write down which existing flow stops working and which role loses an ability. If you can't name one, the restriction is probably unnecessary; if you can, that is the sentence to take to the user before writing the code.

### Implementation before imports

Write the body that USES imports BEFORE adding the import statements at the top of a file. Format-on-save tools (TypeScript `organizeImports`, ESLint `no-unused-vars` autofix, ruff, etc.) strip imports they see as unused - if the body using them isn't there yet, save deletes them and the next compile fails.

Workarounds:
- Body and imports in a single Write/Edit so the linter sees both at the same time.
- For TDD RED phase (test imports a function that doesn't exist yet), implement the export stub first - even just `export const foo = () => { throw new Error('unimplemented') }` - then write the test that imports it.
- Disable format-on-save during scaffolding when project tooling fights you.

Applies to `tdd`, `execute`, `brainstorm` (when generating example code), and any skill that produces code.

### Comments and docstrings

Plain natural language, short, no robot-speak - the canonical rule lives in the global `CLAUDE.md` Voice section (no fancy words, no arrow chains, test docstrings describe behavior). The reviewer flags robotic comments.

**Write the code with no comments, then add back only what you can justify.** The prohibition list below has existed for a long time and still gets broken, because a list of things to cut is applied at edit time, after the sentence is already written and feels earned. An allowlist is applied at write time. Three kinds of comment survive:

1. **Domain why** a reader cannot get from the code - `# warning_closed counts as a won dispute`.
2. **What a cryptic field actually holds** - `# Stripe event code, e.g. 'charge.captured'`.
3. **Why an empty block is empty**, so it doesn't read as a bug.

If the comment you want isn't one of those three, delete it and move on. Don't reword it.

**Naming something is documenting it.** A comment above a named predicate, constant or helper is the name a second time. That is the single most common redundant comment, and the one to catch before writing: if you just named `canCorrectUnitSecurityOption` and now want a sentence above it explaining when an agent may correct the option, the name already said it. When a name genuinely needs a paragraph, the name is wrong - rename it. `lib/wrap_comments.py --redundant` flags the mechanical case (a multi-line header over a one-expression predicate) and the `wrap-comments` hook reports it on every write.

**The other prohibitions still hold.** Never name the feature, ticket, or flag in a comment, and don't cross-reference old/replaced code ("Mirrors X", "lifted from Y").

**If it needs explaining, fix the code instead.** A comment is maintenance you have taken on, and it rots silently - the code changes, the sentence doesn't. Prefer a clearer name, a smaller branch, or a named predicate over a sentence explaining the tangle. The reliable tells that a comment should be deleted rather than written:

- **It argues for the design.** "rather than making another", "so the toggle doesn't…", "because that would double-charge". The code shows the choice; the test pins it.
- **It points at another module as the oracle.** "Mirrors `SelectedRentalOptionFee.type`" - the reader has this file, not that one, and the two drift.
- **It makes a claim about callers.** "Callers prefetch `x` to stay query-free" was false - the only caller didn't. Statements about code you don't control go stale the moment someone adds a caller.
- **It restates a constant or tuple in prose** right above the definition.

**Line breaks - default to one line.** Enforced by `lib/wrap_comments.py`, which the `wrap-comments` PostToolUse hook runs on each Python, TypeScript and JavaScript file written, rewrapping only comments next to lines that changed. Run it by hand with `--check` in CI. The rest of this rule is what it implements.

A single sentence stays on one line, commas and all. Break only when a comment is genuinely long: put one sentence per line, or for a single long sentence wrap at a clause boundary so each line ends in `,`/`.`/`:` - never mid-phrase, and an abbreviation's period (`e.g.`, `i.e.`, `etc.`, `vs.`) is not a boundary. Don't split a short sentence just because it contains a comma.

```
# wrong - short sentence split on its comma
# Usually the lease start date,
# unless a setting moves it.

# wrong - wrapped mid-phrase ("30-day / calendar flag")
# ignores the 30-day
# calendar flag

# wrong - broke after an abbreviation's period ("e.g.")
# settled charges (e.g.
# deposits) skip the sync

# right - short sentence, one line
# Usually the start date, unless a setting moves it.

# right - two sentences, one per line
# The 30-day calendar passes days_in_month=30.
# A 31st move-in still prorates to 1 day.
```

### House style: copy the codebase's clearest comments

The comments reviewers hold up as good share a shape. Match it.

**Branching on a domain case? Lead-in line, then one bullet per case.**

```python
# Find which charges to create for the selected add-on:
# - For renewals, we only create the recurring charges
# - For signups and upgrades, we create all the charges
```

The lead-in says what the code is deciding. Each bullet names the billing event in domain words rather than the `isinstance` check, then says what happens for it. This is the single biggest difference between our clearest comments and AI-written ones, which reach for a prose paragraph where a case list belongs.

**Write "we", present tense.** "we carry the edited categories over from the previous invoice", "we return an empty list", "we look up the last invoice we actually billed". Never "the system", never passive.

**Lead with the human word, put the code word in `(i.e. ...)`.**

```python
"""
A setup fee is charged on an upgrade when someone adds a teammate
(i.e. a seat, both a new item on the subscription and a new invoice line).
"""
```

"teammate" first, `seat` in the parenthetical. A reader who knows the product follows the sentence; a reader who knows the models still gets the mapping. Leading with the model name and never mentioning the human word is an AI habit worth dropping.

**Quote a setting by its label, not its field name.** `the plan is marked as "keep price on renewal"` - that is the wording an admin sees on screen, so it is the wording that lets someone check the setting.

**Say when you don't know.**

```python
# The new invoice is a reconciliation, in that case we also clear the end date
# (the WHY is not clear for me)
```

An honest gap beats an invented rationale. It also tells the next person there is something real to find out. Never manufacture a reason to make a comment sound finished.

**Name the road not taken when you deliberately avoided the obvious one.**

```python
# Add the add-on to the invoice with the creator directly rather than the
# orchestrator, so we control which charges get created.
```

This is not the defensive justification the rule above bans. Naming an alternative you considered and rejected, plus what it would have cost, is genuine *why* that the code cannot show. Narrating what the code does not do ("in one query", "avoids an N+1") is still noise.

**Take the words from the project's glossary.** A comment that coins a synonym for a term the team already has is the most common way AI writing reads as foreign. When a concept has a house word, use the house word; when it does not, say the plain thing rather than inventing a noun. `/team-setup:glossary-check` scans changed files for drift.

**What this replaces.** Three habits that make AI comments hard to read: an abstract noun coined for the occasion where the codebase already has a word; a flowing paragraph where the code branches on three named cases; and narrating the mechanism the reader can already see. If a comment needs a second read, it is usually one of those.

### Naming - descriptive, never terse or vague

Vague names are the thing that gets corrected in review most. Get them right the first time - code Claude writes should not need a naming-correction round-trip. Language-specific bits (Python `is_`/`create_` verbs and the creator/orchestrator prefixes; TS typed domain models) live in the per-language clean-code skills; these apply everywhere:

- **Functions are verbs, spelled out.** Name a function for the work it does. No terse or abbreviated verbs - a `to*` prefix or an `*Ops`/`*Cfg` suffix says too little (`toOperation`, `toStagedHistoricalOps`, `toSettings`, `categoryEditOps` are all vague about source and result). Use `build<Noun>` / `<verb><Noun>`: `buildStagedHistoricalOperations`, `buildAddOperationsForDraft`, `buildSettingsBlock`. Keep ONE verb prefix across a file - don't mix `to*` and `build*`.
- **Locals and params are domain names too.** Avoid generic `row`/`data`/`item`/`obj`/`result` when the thing has a name. **No single-letter lambda params** - `r`/`li`/`b`/`f`/`i`/`x` say nothing; name what they hold (`row`, `waiveFlag`, `quotedFee`). The only truly-generic pass is a `reduce` accumulator like `total`.
- **Name a variable for what it holds, not the role it plays in one check.** Mirror the source property (`firstLeaseStartDate = quote.first_lease_start_date`, not `floor`); name a map for what it keys and holds (`initialAmountByChangelogId`, not `before`). Role/metaphor names (`floor`, `threshold`, `bound`) and adjective-as-noun names (`tooEarly`, `others`) hide the domain thing.
- **Reuse the codebase's existing word** - grep first, match the established local name for a type, don't coin a synonym or churn.
- **No magic strings for a closed set.** A value from a fixed vocabulary (an action/kind discriminator, a status, a mode) gets ONE symbolic source and every use references a member, never the bare literal. Mechanics per language: Python `str` Enum + `Literal[Enum.MEMBER]`; TS `as const` object + `typeof OBJ.KEY`.

### Abstraction & DRY - share the rule, don't over-engineer

- **One class per case beats a switch ladder repeated everywhere.** When the same fixed set of kinds gets branched on in more than one place - validate, execute, and permissions each doing `if kind == add … elif kind == edit …`, or a pile of parallel private methods (`_add_standard`, `_edit_historical`, `_remove_standard`, …) - that repeated parallel structure is the smell. Give each case its own small class that owns its own validate + execute; the caller loops and never branches on kind. A 700-line service with an isinstance ladder becomes a thin loop plus one readable file per case. Adding a case is a new file, not another arm in three switches.
- **Make a shared guard unskippable.** When a base class runs a guard then hands off to subclasses, settle the entry method IN the base and have it call a hook the subclass fills - don't leave each subclass to remember `super().check()`. A forgotten `super()` silently drops the guard and no test catches it.
- **A context object owns the shared lookups - don't staple state onto a domain model.** When several steps share cached lookups (the addable set, a resolved row), put them on a small context/request object passed to each step, not as attributes monkeypatched onto a model (`quote._addable = …`). The model stays clean and the cache has one owner.
- **DRY the rule, not the mechanics.** A domain rule used by both validation and display (e.g. "is this fee removable") gets ONE definition so the two can't drift. Put an entity's predicate on the entity (a read-only model method), not a standalone module.
- **Don't trade duplication for indirection.** A dispatch table / registry of callables is NOT automatically cleaner than an explicit `if/elif` for a small, fixed set - prefer the explicit version when it reads plainly top-to-bottom. If you'd flag it as over-engineered in review, don't build it.
- **Judge a constant by its call sites, not its definition.** A symbolic map whose value equals its key (`OP_ACTION = { ADD: 'ADD' }`) looks like dead indirection but earns its keep - it names the concept and gives every call site one edit point, so a wire-value change touches one line, not twenty. Don't delete it for scattered literals. Conversely, an export / `__all__` entry / type alias nothing outside the module imports IS dead - delete it.
- **A contract written on both sides is the real duplication.** When an enum lives in the backend and is retyped in the frontend, that's the DRY concern - not the surface spelling. Changing casing or formatting doesn't fix it; a shared source (exported constants / codegen) does. Absent that, keep the two in sync deliberately and don't pretend a cosmetic tweak dedupes them.
- **One caller is not a smell.** A query method or a mutation helper with a single caller is fine when it's idiomatic encapsulation - don't inline it just to cut a method.
- **No silent guards in a shared method.** If callers already validate the input, the shared method assumes a valid input - don't add a guard that swallows bad input (`if x is None: return None`). Keep any back-compat guard local to the one caller that needs it.
- **Don't refactor legacy to reuse new code.** When new code (behind a flag) sits beside a legacy path that's deleted when the flag retires, keep legacy byte-for-byte - new↔legacy duplication is intentional and temporary.

### Over-decomposition - the tell reviewers name most often

"A million small functions, I'm having a hard time reading those" is the feedback. Extracting until every function is six lines makes each piece explainable on its own, but following one operation then means holding five stack frames at once. It reads as AI-written and reviewers stop trusting the code.

- **Extract when a function is reused or answers a named question - never to hit a line count.** A helper called once, from one place, belongs inlined in its caller. (This does not contradict "one caller is not a smell" above: idiomatic encapsulation is fine, a chain of single-use wrappers is not.)
- **Prefer concrete duplication over a generic mover.** Where two model families mirror each other (draft/committed, create/update), write both versions out. Duplication we can read beats an abstraction we can't.
- **Field names as string parameters is the worst offender.** `move(fee_field="draft_charge", owner_field="draft_subscription")` and then `**{f"{fee_field}_id": value}` forces the reader to resolve strings against models in their head. Write it twice, concretely.
- **The entry point is the table of contents.** Read `main()` (or the top-level function) start to finish and you should know what the code does; steps sit under it in call order.
- **A linear 80-line function with early returns beats eight 10-line functions.** The reader follows one thread instead of chasing wrappers.

**Calibrate against a neighbour, not an ideal.** Before calling code done, count the functions and compare against a file already in the repo that does a similar job. Many more functions than the neighbour is the signal - go read that file and match its shape. A one-off data script that grew to 37 functions when every comparable script in the same folder has 2-10 is the case that produced this rule.

### Tests that actually pin behaviour

A green test proves nothing until you know why it's green.

- **Run every new test against the unfixed code and watch it fail.** Not just guards - every test you add for a change. Stash the fix, or paste the old line back, run the one test, see it red, restore. A test that has never been red is a test you are guessing about. Two tests shipped green in one session this way: neither was exercising the change.
- **Green-for-the-wrong-reason has two usual causes, and both look identical to a real pass.** The assertion is looser than you meant - a substring matcher like `toHaveTextContent('/settings/plans/')` also passes on `/settings/plans/new/`, so anchor it (`/^…$/`) or compare exact text. Or the interaction silently did nothing - a simulated click that the handler ignores (a synthetic event missing a field the handler checks) leaves the modal open, so the assertion tests the starting state. When a test passes first try on a bug you just reproduced by hand, assume one of these until you have seen it fail.
- **Assert the intermediate state, not only the outcome.** A step that quietly no-ops is invisible at the end of the test. `expect(modal).not.toBeInTheDocument()` after the click would have caught the dead click immediately.
- **Every guard gets its negative case.** Assert both that the kept thing is kept and that the dropped thing is dropped. A test with only the positive assertion passes whether or not your filter runs.
- **Fixtures must match production configuration on the fields the guard reads.** A factory default that differs from real config makes the test pass for the wrong reason - a quantity guard never fired in a test because the factory left `max_seats` unset while every real row has it at 1. Check the real value (see "Check the data before you design") and set it in the fixture.
- **Widening a condition? Find the tests pinning the narrow behaviour first.** `grep` the assertion, not just the function name. Broadening a guard from "flagged rows" to "all rows of this kind" silently changes behaviour the suite already promised; if a test fails, the test is usually right and your rule is too wide.
- **Don't reach into private attributes from a test.** Calling `orchestrator._charge_creator` couples the test to internals; instantiate the public class instead.

## Skill authoring

Every new skill (vendored or original) must:

1. **Reference our docs** - `CLAUDE.md`, `docs/glossary.md`, relevant ADRs ([0001](../../docs/decisions/0001-build-before-install.md) build-before-install, [0002](../../docs/decisions/0002-layered-enforcement.md) layered enforcement, [0003](../../docs/decisions/0003-feature-grouped-docs.md) feature-grouped docs, [0004](../../docs/decisions/0004-vendor-for-learning-build-for-owning.md) vendor for learning).
2. **Follow our voice** - terse, "we" voice, matrix format, no formal phrasing.
3. **Understand the ecosystem** - know what hooks fire (`capture-nudge` on Write/Edit ≥10 lines, `review-required` on Write/Edit ≥50 lines, `session-start` doc-audit), what companion skills exist (chain into them), what agents are available (`team-setup:team-reviewer`, plus generics).
4. **Integrate, don't relabel** - a new skill that doesn't fit our ecosystem is a missed opportunity. The point of a custom skill is *team integration*, not relabeling existing patterns.
5. **Descriptions are trigger surfaces, not metadata storage.** Lead with imperative phrasing ("MUST use when X" / "MUST use BEFORE Y"). Capture the trigger keywords up front (the user's likely vocabulary). Operational details and vendoring sources go AFTER the trigger description - never before. Soft descriptions = quiet skills = no auto-trigger. We learned this when vendored skills failed to fire because we softened upstream's aggressive "MUST use" framing to descriptive "Use when".

For vendored skills specifically, see [ADR 0004 §"Vendoring requirements"](../../docs/decisions/0004-vendor-for-learning-build-for-owning.md) - additional rules on stripping, source documentation, and discipline inheritance.

**Note on the meta-skill** - `using-team-setup` is the always-on meta-skill that forces invocation of other team-setup skills via imperative framing. It's what makes the rest fire instead of Claude defaulting to "explore first." Vendored from `superpowers:using-superpowers`. If individual skills aren't auto-firing despite aggressive descriptions, check that `using-team-setup` is loaded (its description must include "MUST use when starting any conversation").

## Agent Dispatch

When a skill dispatches an agent (`feature-dev:code-architect`, `feature-dev:code-explorer`, `team-setup:team-reviewer`, etc.), include this in the prompt:

> *"Apply our team discipline - see `./CLAUDE.md` and `./docs/decisions/`. Specifically: TDD, DRY (3+ repeats abstract), SOLID, no shortcuts on security or architecture."*

Three layers of discipline:
- **L1 (agent system prompt):** specialized agents bake the rules in (e.g., `team-setup:team-reviewer`). Use only when the agent's primary output IS a verdict against rules.
- **L2 (dispatch prompt):** generic agents get the rules forwarded by the orchestrator. Use for design / planning agents whose output flows back through Claude.
- **L3 (Claude main context):** value-neutral agents (e.g., `code-explorer`) operate fine without team awareness. Claude applies discipline post-hoc to their findings.

Don't fork every plugin's agent. Specialize where it earns its keep; pass discipline forward elsewhere.
