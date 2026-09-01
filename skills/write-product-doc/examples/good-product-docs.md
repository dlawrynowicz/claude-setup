# Good Product Doc Examples

Reference examples for tone and style when writing new product docs. The domain is a generic subscription-billing product (plans, add-ons, charges, invoices) so nothing here reads as a real spec - copy the **pattern**, not the content.

Each example is annotated with **why it works**.

---

## Pattern 1: Requirement with Example and Source

The default pattern. A clear requirement bullet, a concrete Given/When/Then example showing non-obvious behavior, and a traceable source.

```
- When the start date is changed on a draft subscription, and the customer has not yet paid
  (=no deposit settled), we should recalculate the add-on prices so we pick up the rates that
  will be active on that date.
    - Example
        - Given an account configured with a $50/month priority-support add-on
          And a price change is scheduled for that add-on, raising it to $60/month,
          starting on 01/20
        - When a subscription is drafted with a start date of 01/15
        - Then the $50/month add-on is applied to the subscription
        - When the start date is moved to 01/25
          And the customer has not paid the deposit yet
        - Then the add-on is automatically updated to $60/month
    - Source
        Requirements from this ticket: <your-jira-host>/browse/PROJ-10230
```

**Why it works:** The requirement is one sentence. The example makes the non-obvious behavior concrete ($50 → $60 because the date crossed a boundary). The source is a ticket link.

---

## Pattern 2: Requirement with Italicized Reasoning

When behavior is counter-intuitive, add a *(the reason is...)* block. This prevents future developers from "fixing" the behavior thinking it's a bug.

```
- When an add-on is attached to a subscription after the deposit is paid, but before the first
  invoice is issued, the added add-on is still subject to scheduled price changes.
    - Example
        - On 01/10, a subscription is drafted with a start date of 01/15
          And the customer pays the deposit (the subscription is committed)
        - On 01/13, a price change is scheduled for extra seats, raising them from
          $50/month to $60/month, effective 01/14 (before the start date)
        - On 01/13, the admin attaches extra seats to the subscription
        - Then a $60/month extra-seats charge is applied
        *(the reason is that the start date falls after the scheduled price change, so $60 is the
        active rate at the moment the subscription begins, and that newly added add-on was not
        there when the deposit was paid - there is no earlier price to honour, so we use the
        active one)*
    - Source
        Confirmed during a call with the team January 14, 2026
```

**Why it works:** Without the reasoning, someone would ask "why doesn't the deposit protect this add-on?" The italicized block answers that preemptively.

---

## Pattern 3: Behavioral Matrix

When the same concept varies across 3+ event types, a matrix replaces a wall of bullets. Each cell should be verifiable.

```
| Behavior | Signup | Renewal | Upgrade | Amendment | Cancellation | Reconciliation |
|----------|:------:|:-------:|:-------:|:---------:|:------------:|:--------------:|
| Recalculate charge amounts | Yes | Yes | **No** | **No** | **No** | **No** |
| Update to latest catalog price | Yes | Yes | Yes | **No** | **No** | **No** |
| Preserve admin-edited amounts | **Yes** | No | No | **Yes** | No | No |
| Auto-add missing mandatory charges | Yes | Yes | Yes | **No** | **No** | **No** |
| Carry over discounts | No | No | No | **Yes** | **Yes** | **Yes** |

¹ "Recalculate" means charges are re-derived from the catalog. Amendment, Cancellation,
Upgrade and Reconciliation all preserve the effective amount from the subscription as-is.
```

**Why it works:** Bold marks surprising values. Footnotes explain non-obvious terms. A reviewer can scan one row to see how a behavior differs across all 6 types - no need to read 6 separate paragraphs.

---

## Pattern 4: Negative Requirement

Explicitly call out what we do NOT support. This saves engineers from investigating dead ends and prevents PMs from assuming it works.

```
- A subscription with no recurring charge and no deposit, so nothing for the customer to pay
  at all, is NOT supported today.
  It will be supported once the "workspace-specific pricing" epic ships (Q1 2026).
```

**Why it works:** States the gap, gives the timeline. Without this, someone would file a bug.

---

## Pattern 5: Priority / Ordered Logic

When there's a fallback chain or priority order, use a numbered list. Each step is a decision point.

```
- When a charge is already set on a subscription and we carry it over to a renewal, here is the
  logic for deciding the carried-over amount:
    1. If the add-on is configured to pull its price from the billing provider, take that first.
    2. If price changes are scheduled, pick the rate matching the renewal quote's issue date.
    3. If the charge is configured with a "renewal amount", use it.
    4. If the original amount was edited by hand, use that edited amount.
    5. Otherwise use the configured amount (fixed, percentage, dynamic, etc.)
    - Source
        Requirements from <your-jira-host>/browse/PROJ-9311
        Confirmed November 19, 2025 by the PM (in a call with two engineers).
```

**Why it works:** The numbered list communicates priority - step 1 wins over step 2. The source traces back to a specific call.

---

## Pattern 6: Data Model with Concrete Example

Walk through a real scenario showing what records get created. Use a specific example (the "Design" workspace, not "an item").

```
- Take an available "Extra workspace" add-on on the account, which carries two charges:
  a setup charge of $400 and a monthly charge of $50.
  If a subscription indicates it wants a workspace ("Design"), these records are linked to it:
    - 1 SelectedAddOn to represent the "Extra workspace" add-on
    - 2 SelectedAddOnCharge
        - 1 for the "setup" charge
        - 1 for the "monthly" charge
    - 1 SelectedAddOnItem to represent our workspace "Design"
    - 2 SelectedAddOnItemCharge linking a charge to an item
        - 1 for "setup" on Design
        - 1 for "monthly" on Design
        *(with 3 workspaces there would be 6 item charges in total, 2 per workspace)*
```

**Why it works:** Concrete names ("Design", $400, $50) make the hierarchy tangible. The parenthetical shows how it scales.

---

## Pattern 7: Verbal Source Attribution

When requirements come from standups, calls, or chat - not tickets - say who, when, and where.

```
- When the start date changes on a subscription and the customer has already paid,
  we should NOT recalculate the add-on prices.
    - Source
        Confirmed by the PM during standup January 12, 2026.
```

**Why it works:** If this requirement is questioned later, we know exactly who to ask.

---

## Pattern 8: Excluded Categories Table

When different event types exclude different things, a compact table beats prose.

```
| Type | Excluded Categories |
|------|---------------------|
| Renewal | Deposit, Upgrade Fee |
| Upgrade | _(none - carries all; Upgrade Fee added fresh)_ |
| Amendment | Deposit, Upgrade Fee |
| Cancellation | Deposit, Setup Fee, Upgrade Fee |
| Reconciliation | _(none)_ |
```

**Why it works:** One glance answers "what's excluded on an upgrade?" Italicized notes explain surprising values inline.

---

## Pattern 9: Protection / Guard Table

When multiple conditions block an action, list them as protections with their effects.

```
| Protection | Effect |
|-----------|--------|
| Deposit paid | Stops recalculation when the start date changes |
| Invoice issued | Stops all scheduled price updates for that subscription |
| "Hold price on renewal" flag | Blocks renewal price updates (but NOT newly added items) |
| Settled charge | Skips the update entirely |
| Ranged charges | Excluded from all scheduled recalculation |
```

**Why it works:** Engineers implementing a new path can check this table to see all the guards they need to respect.

---

## Anti-Patterns (what NOT to do)

**Don't write requirements without sources:**
```
BAD:  "We should recalculate prices when the date changes."
GOOD: "We should recalculate prices when the date changes.
       - Source: Confirmed by the PM during standup January 12, 2026."
```

**Don't use walls of text when a matrix works:**
```
BAD:  "Signups recalculate charges. Renewals also recalculate charges. Upgrades do not
       recalculate charges. Amendments do not. Cancellations do not."
GOOD: Use a behavioral matrix (Pattern 3)
```

**Don't mix "what the code does" with "what Product decided":**
```
BAD:  "We recalculate charges on amendment." (is this what the code does, or what Product wants?)
GOOD: "We recalculate charges on amendment.
       - Source: Confirmed by the PM during standup January 12, 2026."
  OR: "The code recalculates charges on amendment, but Product has not confirmed this.
       TODO: Needs Product confirmation."
```

**Don't skip negative requirements:**
```
BAD:  (silence about unsupported flows)
GOOD: "A subscription with no recurring charge and no deposit is NOT supported today."
```
