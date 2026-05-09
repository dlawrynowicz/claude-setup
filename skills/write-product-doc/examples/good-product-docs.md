# Good Product Doc Examples

Real examples from Funnel's product documentation. Use these for tone and style reference when writing new product docs.

Each example is annotated with **why it works** — use the pattern, not just the content.

---

## Pattern 1: Requirement with Example and Source

The default pattern. A clear requirement bullet, a concrete Given/When/Then example showing non-obvious behavior, and a traceable source.

```
- When the lease start date is updated on an application, and the unit is not reserved yet
  (=holding deposit not paid), we should recalculate the price of the rental options to make
  sure we pick up the fees that will be active at that date.
    - Example
        - Given a community configured with a $50/month cleaning fee
          And a price update is scheduled for that cleaning fee, to increase it to $60/month,
          starting on 01/20
        - When an application is started with a lease start date of 01/15
        - Then the $50/month cleaning fee is added to the application
        - When the lease start date of the application is updated to 01/25
          And the applicant has not paid the holding deposit yet
        - Then the cleaning fee is automatically updated to $60/month
    - Source
        Requirements from this ticket: https://nestiolistings.atlassian.net/browse/OL-10230
```

**Why it works:** The requirement is one sentence. The example makes the non-obvious behavior concrete ($50 → $60 because the date crossed a boundary). The source is a JIRA link.

---

## Pattern 2: Requirement with Italicized Reasoning

When behavior is counter-intuitive, add a *(the reason is...)* block. This prevents future developers from "fixing" the behavior thinking it's a bug.

```
- When a rentable item is added to the application after the payment of the holding deposit,
  but before the lease is generated, the added rentable item is subject to scheduled price changes.
    - Example
        - On 01/10, an application is started with a lease start date of 01/15
          And the applicant pays the holding deposit (unit is reserved)
        - On 01/13, a price update is scheduled for the dog's monthly rent fee, to increase it
          from $50/month to $60/month, effective on 01/14 (before the lease start date)
        - On 01/13, the agent adds a dog to the application
        - Then a $60 dog's monthly rent should be added to the application
        *(the reason is that the lease start date is after the scheduled price update, so $60
        will be the active fee at the moment the lease will start, and that newly added rentable
        item was not there when the applicant paid the holding deposit, so we have no price to
        "respect" and we should use the active one)*
    - Source
        Confirmed during a call with the team January 14, 2026
```

**Why it works:** Without the reasoning, someone would ask "why does the holding deposit not protect this item?" The italicized block answers that preemptively.

---

## Pattern 3: Behavioral Matrix

When the same concept varies across 3+ transaction types, a matrix replaces a wall of bullets. Each cell should be verifiable.

```
| Behavior | Application | Renewal | Transfer | MLC | Vacate | Reconciliation |
|----------|:-----------:|:-------:|:--------:|:---:|:------:|:--------------:|
| Recalculate fee amounts | Yes | Yes | **No** | **No** | **No** | **No** |
| Update to latest catalog price | Yes | Yes | Yes | **No** | **No** | **No** |
| Preserve agent-edited amounts | **Yes** | No | No | **Yes** | No | No |
| Auto-add missing mandatory charges | Yes | Yes | Yes | **No** | **No** | **No** |
| Carry over concessions | No | No | No | **Yes** | **Yes** | **Yes** |

¹ "Recalculate" means fees are re-derived from the catalog. MLC, Vacate, Transfer,
and Reconciliation all preserve the effective amount from the lease as-is.
```

**Why it works:** Bold marks surprising values. Footnotes explain non-obvious terms. A reviewer can scan one row to see how a behavior differs across all 6 types — no need to read 6 separate paragraphs.

---

## Pattern 4: Negative Requirement

Explicitly call out what we do NOT support. This saves engineers from investigating dead ends and prevents PMs from assuming it works.

```
- A flow where there is no application fee + no holding deposit, so nothing to pay for the
  primary applicant, is NOT supported today.
  It will be supported soon (Q1 2026), once the "unit-specific payables" epic is released.
```

**Why it works:** States the gap, gives the timeline. Without this, someone would file a bug.

---

## Pattern 5: Priority / Ordered Logic

When there's a fallback chain or priority order, use a numbered list. Each step is a decision point.

```
- When a fee is already set on a lease and we carry over that fee to a renewal, here is the
  logic we should follow to decide the amount of the carried-over fee:
    1. If the rental option is configured to pull the price from the PMS, then get the price
       from the PMS in priority.
    2. If there are some scheduled price changes, retrieve which rental option fee to use
       based on the lease offer ingestion date.
    3. If the rental option fee is configured with an "amount at renewal", use it.
    4. If the amount of the original fee was edited, use that custom edited amount.
    5. Use the configured amount from the rental option fee (can be fixed, percentage,
       dynamic, etc.)
    - Source
        Requirements from https://nestiolistings.atlassian.net/browse/OL-9311
        Confirmed November 19, 2025 by Max (in a call with Richard and William).
```

**Why it works:** The numbered list communicates priority — step 1 wins over step 2. The source traces back to a specific call with specific people.

---

## Pattern 6: Data Model with Concrete Example

Walk through a real scenario showing what instances get created. Use a specific example ("Bella" the dog, not "an item").

```
- Let's take the example of an available "Dog" rental option at the community, which has
  two different fees: a dog deposit of $400 and a dog monthly fee of $50.
  If on the quote, we indicate we want a dog ("Bella"), then here are the instances that
  will be linked to the quote:
    - 1 SelectedRentalOption to represent the "Dog" rental option
    - 2 SelectedRentalOptionFee
        - 1 to represent the "Dog deposit" rental option fee
        - 1 to represent the "Dog monthly fee" rental option fee
    - 1 SelectedRentalOptionItem to represent our dog "Bella"
    - 2 SelectedRentalOptionItemFee which links a fee and an item
        - 1 to represent the "Dog deposit" fee for our "Bella" dog
        - 1 to represent the "Dog monthly fee" for our "Bella" dog
        *(if we had 3 dogs, there will be 6 item fees in total, 2 per dog)*
```

**Why it works:** Concrete names ("Bella", $400, $50) make the hierarchy tangible. The parenthetical shows how it scales.

---

## Pattern 7: Verbal Source Attribution

When requirements come from standups, calls, or Slack — not tickets — say who, when, and where.

```
- When the lease start date is updated on an application, and the unit is already reserved,
  we should NOT recalculate the price of the rental options.
    - Source
        Confirmed by Max during standup January 12, 2026.
```

**Why it works:** If this requirement is questioned later, we know exactly who to ask.

---

## Pattern 8: Excluded Categories Table

When different transaction types exclude different things, a compact table beats prose.

```
| Type | Excluded Categories |
|------|---------------------|
| Renewal | Holding Deposit, Transfer Fee |
| Transfer | _(none — carries all; Transfer Fee added fresh)_ |
| MLC | Holding Deposit, Transfer Fee |
| Vacate | Holding Deposit, Application Fee, Transfer Fee |
| Reconciliation | _(none)_ |
```

**Why it works:** One glance answers "what's excluded on a transfer?" Italicized notes explain surprising values inline.

---

## Pattern 9: Protection / Guard Table

When multiple conditions block an action, list them as protections with their effects.

```
| Protection | Effect |
|-----------|--------|
| Holding deposit paid (application) | Stops recalculation on lease start date change |
| Documents sent/generated | Stops all scheduled price updates for that transaction |
| "Freeze for residents" flag | Blocks renewal price updates (but NOT MLC new items) |
| Paid LineItem | Skips the update entirely |
| Ranged fees | Excluded from all scheduled price recalculation |
```

**Why it works:** Engineers implementing a new path can check this table to see all the guards they need to respect.

---

## Anti-Patterns (what NOT to do)

**Don't write requirements without sources:**
```
BAD:  "We should recalculate prices when the date changes."
GOOD: "We should recalculate prices when the date changes.
       - Source: Confirmed by Max during standup January 12, 2026."
```

**Don't use walls of text when a matrix works:**
```
BAD:  "Applications recalculate fees. Renewals also recalculate fees. Transfers do not
       recalculate fees. MLCs do not recalculate fees. Vacates do not recalculate fees."
GOOD: Use a behavioral matrix (Pattern 3)
```

**Don't mix "what the code does" with "what Product decided":**
```
BAD:  "We recalculate fees on MLC." (is this what the code does, or what Product wants?)
GOOD: "We recalculate fees on MLC.
       - Source: Confirmed by Max during standup January 12, 2026."
  OR: "The code recalculates fees on MLC, but this has not been confirmed by Product.
       TODO: Needs Product confirmation."
```

**Don't skip negative requirements:**
```
BAD:  (silence about unsupported flows)
GOOD: "A flow where there is no application fee + no holding deposit is NOT supported today."
```
