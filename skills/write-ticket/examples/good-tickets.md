# Good Ticket & Epic Examples

Real examples from Funnel's JIRA. Use these for tone/style reference.

---

## Epic Example (condensed)

An epic starts with Goal, What is X, How it works, What it looks like — then tickets.

```
# Epic: Rhino/Jetty Deposit Alternative Integration

> **Goal**: Allow communities to offer Rhino as a deposit alternative — when Rhino is on
> a lease, deposit fees are filtered from the resident's charges and totals.

## What is Rhino?

Rhino is an external deposit alternative provider. Instead of paying a security deposit
upfront, residents enroll in Rhino and Rhino covers the deposit for them. From our
perspective, Rhino is a rental option that works by presence alone — it has no fees. When
it's on a transaction, deposit fees are completely filtered from charges and display.

## How it works

- **No RO fees** — Rhino RO has zero RentalOptionFees. Its presence is what matters.
- **No fee manipulation** — deposit fees stay at their actual amounts in the database.
  We don't zero them — we filter them from totals and display when Rhino is present.
- **No snapshot/restore** — since fees aren't modified, removing Rhino just stops the
  filtering. The original deposit amounts are already there.
- **Carry-over just works** — Rhino SRO carries over like any other SRO.
- **Price update protection** — deposits covered by Rhino should not receive scheduled
  price updates.

## What it looks like for agents

Agents manage Rhino through the rental profile, just like any other RO. They add Rhino →
deposit lines disappear from totals and display. They remove Rhino → normal deposit amounts
reappear. A blue banner indicates Rhino is active.
```

**Why this epic works:** The Goal is one sentence. "What is Rhino?" explains it for someone who's never heard of it. "How it works" is a bullet list of rules with bold keywords. Tickets follow below with clear user stories and concrete tests.

---

## Ticket Examples

### Example 1: MLC date alignment (gold standard)

This ticket demonstrates the ideal format — clear user story, bulleted example in description, blockquote callouts for context, h4 test titles with bold Given/When/Then, horizontal rules between tests, parenthetical reasoning, and a product-facing open question.

```
# Update rental option item dates when lease start date changes in MLC

## User story

As an agent when starting an MLC, I want rental option items to stay in sync with the lease start date so that all deposits and fees remain visible after changing the move-in date.

## Description

When an agent changes the lease start date during an MLC, existing rental option items keep their original start date from when they were first added. If the lease start moves to the future, older items end up before the new lease start — making them invisible in the pricing breakdown, Deposits & Fees modal, and guest card.

> **Why carried-over items with past dates need updating:** The pricing breakdown, Deposits & Fees modal, and guest card filter items by the lease's date range. When the lease start moves to the future (e.g., February to March), items that were valid at the old start date now fall before the new lease start. The system treats them as not belonging to this lease period and hides them — even though the fee was legitimately part of the lease.

> **Example:**
> - A lease starts in February with a wine cooler
> - Agent creates an MLC and changes the lease start to March
> - Agent adds a second wine cooler during the MLC
> - MLC completes
> - The first wine cooler still has a February start date while the lease now starts in March
> - The first wine cooler disappears from the breakdown because it falls outside the lease's date range

Transfers already handle this by resetting item dates during carry-over. MLCs have no equivalent.

## Requirements

- When the lease start date changes during an MLC, update all existing rental option item start dates on the current quote to `max(new_lease_start, item.start_date)`
  - This ensures no item starts before the lease — items at or after the new start keep their date, items before it get updated to the new start
- Item fee start dates should sync automatically via the existing save-time sync
- Only apply to the current MLC quote's items — do not touch historical/completed transaction items
- This should happen when lease terms are saved, not at MLC completion — so the pricing breakdown reflects the correct dates immediately

> **Important:** This only applies to MLCs. Applications, transfers, and renewals already handle dates correctly.

---

## Acceptance tests

#### Test 1: Rentable item date updates when lease start date is changed to the future

**Given** a lease starting Feb 20th with a wine cooler (item start date = Feb 20th)

**When** an agent creates an MLC and changes the lease start date to Mar 15th

**Then** the wine cooler item start date is updated to Mar 15th (because the item was before the new lease start, so it's updated to match)

---

#### Test 2: New rentable item added during MLC gets the new lease start date

**Given** a lease starting Feb 20th with an existing wine cooler

**When** an agent creates an MLC, changes the lease start to Mar 15th, and adds a second wine cooler

**Then** the new wine cooler has start date = Mar 15th

**And** both wine coolers are visible in the pricing breakdown

---

#### Test 3: Rentable item keeps its date when lease start date is changed to the past

**Given** a lease starting Mar 15th with a wine cooler (item start date = Mar 15th)

**When** an agent creates an MLC and changes the lease start to Feb 20th

**Then** the wine cooler item start date remains Mar 15th (because the item already starts after the new lease start, no change needed)

---

#### Test 4: Rentable item remains visible in pricing breakdown after lease start date is changed to the future

**Given** a lease starting Feb 20th with a pet deposit

**When** an agent creates an MLC, changes the lease start to Mar 15th, and views the pricing breakdown

**Then** the pet deposit is still visible in the pricing breakdown (because its start date was updated to match the new lease start)

## Open questions

- **Confirm with Product:** If a rentable item was scheduled to start in the future (e.g., wine cooler starting Jun 1st) and the lease start date changes from Feb 20th to Mar 15th — should the wine cooler keep its Jun 1st start date, or should it also move? Our assumption is to leave future-dated items as-is and only update items that fall before the new lease start.
```

**Why this ticket works:**
- User story says who and why in one sentence
- Description explains the pain with a concrete bulleted example
- Blockquote callouts explain the "why" and flag important scope limits
- Requirements are precise without being overly technical
- Tests use h4 headers (stand out from bold keywords), concrete dates, and parenthetical reasoning
- Open question is framed for Product (no technical formulas), with a clear assumption stated

---

### Example 2: Validation rules with production data

```
# Add validation rules for application fee rental options

## User story

As a leasing agent or a Funnel admin, I don't want to be able to configure an application fee or other fees that are due at application in a way that is not supported by the system.

## Requirements

- Add a new rental option validation rule: Rental options with an "Application Fee" category can only have fees that are due at application
- Add a new rental option validation rule: If a rental option fee is due at application, its rental option must have a fee category of "Application Fee" or "Holding deposit"
- These new rules should be applied everywhere we allow a rental option to be created/updated (i.e. django admin, agent's settings page, MITS ingestion, bulk uploader)

## Technical details

- Currently in production, we have 108 rental options that have the "Application fee" fee category but a fee that is not marked as "due at application"
- Currently in production, we have 4,385 rental options that have a fee marked as "due at application" but have a fee category that is different from "Application fee" or "Holding deposit"

## Acceptance tests

#### Test 1: Application fee with incorrect payment time

**Given** an existing rental option with a fee category of "Application fee" and no fees

**When** a user tries to add a fee due at move-in for this rental option through the Django admin

**Then** a validation error is displayed and the fee is not created

---

#### Test 2: Due-at-application fee on incorrect category

**Given** an existing rental option with a fee category of "Cleaning fee" and no fees

**When** a user tries to add a fee due at application for this rental option through the Django admin

**Then** a validation error is displayed and the fee is not created

---

#### Test 3: Valid configuration

**Given** an existing rental option with a fee category of "Application fee" and no fees

**When** a user tries to add a fee due at application for this rental option through the Django admin

**Then** the fee is successfully created

---

#### Test 4: Existing misconfiguration blocks edits until fixed

**Given** an existing rental option with no fee category and an existing fee marked as "due at application"

**When** a user tries to edit this rental option or this rental option fee

**Then** a validation error is displayed and no update is possible until either an "application fee" or "holding deposit" fee category is specified for the rental option, or the payment time of the fee is updated to something else
```

---

### Example 3: Unit-specific fees with agent and resident paths

```
# Handle unit-specific transfer fees

## User story

As an agent or a resident, I would like the proper holding deposit and transfer fee to be selected when I start a transfer, even if the community is configured with multiple unit-specific rental options for those.

## Requirements

- When a transfer is started, and the community is configured with multiple unit-specific transfer fees, the correct fee should be displayed on the "Start Transfer" modal and should be added to the transfer
- The same behavior should be applied if the transfer is started from the applicant's side

## Acceptance tests

#### Test 1: Transfer fee from agent side

**Given** a community with two unit-specific transfer fee rental options:
- "Transfer fee A" for units on layout A
- "Transfer fee B" for units on layout B

**When** an agent starts a transfer for a current resident, and the transfer is for a unit on layout A

**Then** the "Transfer fee A" should be displayed on the "Start Transfer" modal (no transfer fee B)

**And** that fee should automatically be added to the created transfer

**And** that fee should be displayed on the pricing breakdown and the "Deposits and Fees" modal

---

#### Test 2: Holding deposit from agent side

**Given** a community with two unit-specific holding deposit rental options:
- "Holding deposit A" for units on layout A
- "Holding deposit B" for units on layout B

**When** an agent starts a transfer for a current resident, and the transfer is for a unit on layout B

**Then** the "Holding deposit B" should be displayed on the "Start Transfer" modal (no holding deposit A)

**And** that fee should automatically be added to the created transfer

**And** that fee should be displayed on the pricing breakdown and the "Deposits and Fees" modal

---

#### Test 3: Transfer fee from resident side

**Given** a community with two unit-specific transfer fee rental options:
- "Transfer fee A" for units on layout A
- "Transfer fee B" for units on layout B

**When** the resident starts a transfer on Woodhouse, and the transfer is for a unit on layout A

**Then** "Transfer fee A" is automatically added to the transfer (no transfer fee B)
```

---

### Example 4: Small ticket (no rigid structure needed)

```
# Remove deprecated Launch Darkly flag

Once the feature is released, we will be able to remove the ol-rental-profile-validation-for-rental-options-not-available-for-layout-type-04172023 Launch Darkly flag.

This one was used to control the display of the warning banner on the rental profile for rental options that were displayed but were not applicable to the transaction.

Now, we completely removed this banner as we don't display the non-applicable rental options anymore on the rental profile. This flag is not used anymore.

LD link: https://app.launchdarkly.com/projects/default/flags/ol-rental-profile-validation-for-rental-options-not-available-for-layout-type-04172023/
```
