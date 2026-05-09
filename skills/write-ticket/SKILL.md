---
name: write-ticket
description: Write implementation-driven JIRA tickets with consistent terminology and human tone. Use when creating tickets, epics, or converting product docs to tickets.
---

# Write Ticket

Write JIRA tickets that read like a human wrote them — user stories, conversational requirements, and concrete Given/When/Then acceptance tests.

## Inputs

- `$ARGUMENTS` — topic, feature name, or product doc reference to convert into tickets

## Process

1. Read shared rules: [SHARED.md](../SHARED.md) — tone, terminology, domain knowledge
2. Read real examples for tone: [examples/good-tickets.md](examples/good-tickets.md)
3. If converting a product doc, research the codebase for gaps (models, existing patterns, constants)
4. Write tickets following the rules below
5. Review each ticket for gaps: missing tests, unclear mechanisms, incomplete scope, stale terminology, sizing

## Writing Rules

### Ticket-Specific Tone
- Start with "As a [role], I want..." — who benefits and what they need
- Describe current pain: "the applicant is blocked on...", "we failed to..."
- Use blockquote callouts for examples and important notes: `> **Example:**`, `> **Important:**`
- Examples in description should use bullet points showing exact steps — not prose paragraphs

### Epic Description
- Every epic starts with: Goal (one sentence), "What is X?" (1-2 paragraphs for someone who's never heard of it), "How it works" (bullet list of key behaviors/rules), "What it looks like for [role]" (user-facing experience)
- Write for a developer picking up any ticket — the epic description is their big picture

### Ticket Structure
- Sections: User story, Description, Requirements, Technical details, Acceptance tests, Open questions (always last)
- Requirements as bullet list — include exceptions inline ("only if X, unless Y")
- Acceptance tests use plain Given/When/Then paragraphs — see format below
- Technical details include production data, queries, links — in expandable sections when large
- Open questions only for truly unresolved decisions — if the answer is derivable from the codebase, make the call
- Use `(Bonus)` prefix for nice-to-have cleanup items that aren't required
- Small tickets can be just a title + paragraph + link — no rigid structure needed
- Scope completeness: if a rule applies "everywhere we allow X", list all the places

### Acceptance Test Format
```markdown
#### Test 1: Allow a global late rent RO alongside a unit-specific late rent RO

**Given** a community with one active global late rent rental option "Late Rent - Global" (no layouts, no unit types, no legal entities)

**When** an admin creates a second active late rent rental option "Late Rent - Studio" configured for layout "Studio"

**Then** the second rental option is saved successfully (because they differ in unit scope: one is global, the other is layout-specific)

---

#### Test 2: Reject duplicate global late rent ROs in the same community

**Given** a community with one active global late rent rental option "Late Rent - Global"

**When** an admin creates another global late rent rental option "Late Rent - Global 2" (same scope: no layouts, no unit types, no legal entities)

**Then** validation fails with "A global late rent rental option already exists" (because two global ROs of the same category in the same community would conflict)
```
Rules:
- `#### Test N: Title` — h4 header so the test title stands out from Given/When/Then keywords. Each title must be unique and specific — "Item date updated on forward move" not "Test case for dates"
- **Given/When/Then/And must be bold** (`**Given**`, `**When**`, `**Then**`, `**And**`) so they stand out visually in JIRA
- Add `---` horizontal rule above the "Acceptance tests" header to visually separate requirements from tests
- Separate individual tests with `---` horizontal rules for visual clarity
- Each keyword starts a new paragraph — no bullets within test steps
- Concrete data in every test ($500, layout "Studio", "Late Rent - Global")
- Add parenthetical reasoning after Then clauses: "(because they differ in unit scope: one is global, the other is layout-specific)"
- Keep Then + reasoning on the same line — no line break between the assertion and its parenthetical

### Grouping
- Group by what a developer implements together, NOT by product doc sections
- Model + validator + admin = one ticket
- Orchestrator + its hooks = one ticket
- Split backend/frontend when independently deployable (e.g. orchestrator = one ticket, rental profile UI = another)

### Sizing & Splitting
- If a ticket covers both backend logic and frontend UI and they're independently deployable, split them
- If a ticket has 8+ tests spanning different concerns, consider splitting
- Target M-sized tickets (2-4 days). L tickets should be split if possible.

### Scope & Downstream Impact
- Think about ALL dimensions of the problem — check the model for all scoping fields (layouts, unit types, legal entities, lease profiles, etc.)
- Include downstream impact — if validation changes, what code uses these objects and needs updating?
- Explicitly call out what's NOT in scope upfront (e.g. "Early termination rental options are not in the scope of this ticket") — list all affected categories at the top so the reader immediately knows the full scope
- Flag cleanup opportunities as bonus items (e.g. "remove duplicate validator")
- Make clear decisions instead of open questions when the answer is derivable from the codebase
- Add a Background section before requirements when context helps the developer

### Review Checklist
After writing, check each ticket for:
- Missing acceptance tests (edge cases, invalid scenarios, existing data issues)
- Unclear mechanisms ("how do we detect X?" — either explain or flag as open question)
- Incomplete scope ("everywhere we allow X" — did you list all the places?)
- Missing downstream impact (what code consumes what we're changing?)
- Stale terminology (check against glossary)
- Sizing (too big? split. too small? merge.)

### E2E Tests for Epics
- Every epic should include an E2E Playwright ticket as the final ticket
- E2E ticket depends on the feature tickets — it validates integrated behavior after they're complete
- Cover the key user-facing flows end to end (add/remove, carry-over, display filtering, etc.)
- Include: test spec file location, fixture data needs, page object additions, test tags

### Language & Dates
- Use domain language, not internal code paths — "when admin updates the rental option fee" NOT "cronjob path"; "when agent changes lease start date" NOT "view path"
- Test cases should use relative dates ("in 1 week", "in 2 weeks") so QA can execute them anytime — never absolute dates like "3/1/2026"
- Describe triggers from the user's perspective — who does what in the UI

### Output Format
- Always wrap the final ticket output in a code block so the user can copy raw markdown into JIRA without losing formatting

### What to avoid
- Over-specifying technical details — leave room for the developer
- Separate "write tests" tickets — tests are part of each ticket
- Referencing bugs in ticket descriptions
- Artificially limiting acceptance tests — write as many scenarios as needed
- Internal technical jargon in test cases (code paths, function names, event constants)
