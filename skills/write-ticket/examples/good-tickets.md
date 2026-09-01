# Good Ticket & Epic Examples

Reference examples for tone and structure. The domain is a generic subscription-billing product (plans, add-ons, charges, invoices) so the examples stay concrete without belonging to any real codebase - copy the **shape**, not the subject.

---

## Epic Example (condensed)

An epic starts with Goal, What is X, How it works, What it looks like - then tickets.

```
# Epic: Usage Sync

> **Goal**: Let a workspace bill on metered usage - when a usage source is connected, recorded
> usage flows onto the invoice without anyone entering it by hand.

## What is a usage source?

A usage source is a connection between a workspace and a system that records usage (an API
gateway, a data warehouse). Once connected, we read usage from it at invoicing time. From our
perspective a usage source is a connection, not a store - it holds no usage of its own. When one
is active on a workspace, that workspace's metered add-ons are priced from it instead of from a
flat rate.

## How it works

- **No stored usage** - the usage source has zero rows of its own. Its presence is what matters.
- **No rewriting history** - past invoices keep the amounts they were issued with. We price from
  the source going forward, we don't restate.
- **Disconnecting is not a rollback** - since we never rewrote anything, removing the connection
  just stops the metered pricing. The flat rates were always there.
- **A new workspace inherits nothing** - connecting is explicit, never implied by a parent account.
- **Failure guard** - a workspace whose source is unreachable falls back to flat rate and flags
  the invoice for review.

## What it looks like for an admin

Admins connect a usage source from the workspace page like any other integration. They connect it
→ metered add-ons start pricing from recorded usage. They disconnect it → those add-ons return to
their flat rates and past invoices are untouched. A blue banner indicates a live connection.
```

**Why this epic works:** The Goal is one sentence. "What is a usage source?" explains it for someone who's never heard of it. "How it works" is a bullet list of rules with bold keywords. Tickets follow below with clear user stories and concrete tests.

---

## Ticket Examples

### Example 1: Date alignment (gold standard)

This ticket demonstrates the ideal format - clear user story, bulleted example in description, blockquote callouts for context, h4 test titles with bold Given/When/Then, horizontal rules between tests, parenthetical reasoning, and a product-facing open question.

```
# Update add-on start dates when the subscription start date changes

## User story

As an admin setting up a subscription, I want add-ons to stay in step with the start date so that charges remain visible after I move the date.

## Description

When an admin changes the start date while a subscription is still in draft, add-ons already attached keep the date they were added on. If the start date moves later, those add-ons end up before the subscription begins - which makes them invisible in the price breakdown, the Charges modal, and the customer's invoice preview.

> **Why already-attached add-ons need updating:** The price breakdown, Charges modal, and invoice preview all filter add-ons by the subscription's date range. When the start date moves from Feb 20th to Mar 15th, add-ons valid at the old date now fall before the subscription begins. We treat them as belonging to a different period and hide them - even though the admin legitimately attached them.

> **Example:**
> - A subscription starts Feb 20th with a priority-support add-on
> - Admin reopens the draft and moves the start date to Mar 15th
> - Admin attaches a second add-on during the draft
> - The draft is confirmed
> - The first add-on still carries its Feb 20th date while the subscription now starts Mar 15th
> - The first add-on disappears from the breakdown because it falls outside the subscription's range

Renewals already handle this by resetting add-on dates during carry-over. Draft subscriptions have no equivalent.

## Requirements

- When the start date changes on a draft, update every existing add-on's start date on the current draft to `max(new_start_date, add_on.start_date)`
  - No add-on may start before the subscription - add-ons at or after the new start keep their date, add-ons before it move up to it
- Add-on charge dates should sync automatically via the existing save-time sync
- Only touch the current draft's add-ons - never historical or already-invoiced periods
- This should happen when the draft is saved, not at confirmation - so the price breakdown is correct immediately

> **Important:** This applies to draft subscriptions only. Renewals, upgrades and cancellations already handle dates correctly.

---

## Acceptance tests

#### Test 1: Add-on date moves forward when the start date is pushed later

**Given** a subscription starting Feb 20th with a priority-support add-on (add-on start date = Feb 20th)

**When** an admin moves the start date to Mar 15th

**Then** the add-on's start date becomes Mar 15th (because it was before the new start date, so it moves up to match)

---

#### Test 2: Add-on attached after the change gets the new date

**Given** a subscription starting Feb 20th with an existing priority-support add-on

**When** an admin moves the start date to Mar 15th and attaches an extra-seats add-on

**Then** the new add-on has start date = Mar 15th

**And** both add-ons are visible in the price breakdown

---

#### Test 3: Add-on keeps its date when the start date is pulled earlier

**Given** a subscription starting Mar 15th with a priority-support add-on (add-on start date = Mar 15th)

**When** an admin moves the start date to Feb 20th

**Then** the add-on's start date stays Mar 15th (because it already starts after the new start date, so nothing needs to change)

---

#### Test 4: Add-on stays visible in the breakdown after the start date moves later

**Given** a subscription starting Feb 20th with a setup fee

**When** an admin moves the start date to Mar 15th and views the price breakdown

**Then** the setup fee is still listed (because its start date moved up to match the new start date)

## Open questions

- **Confirm with Product:** If an add-on was deliberately scheduled to begin later (say, a training package starting Jun 1st) and the start date moves from Feb 20th to Mar 15th - should that add-on keep its Jun 1st date, or move too? Our assumption is to leave future-dated add-ons alone and only move ones that fall before the new start date.
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
# Add validation rules for signup-time charges

## User story

As an admin or a support engineer, I don't want to be able to configure a charge in a way the billing engine cannot support.

## Requirements

- Add a validation rule: a plan with a "Setup fee" category can only carry charges billed at signup
- Add a validation rule: if a charge is billed at signup, its plan must have a category of "Setup fee" or "Deposit"
- Apply these rules everywhere a plan can be created or updated (admin, the settings page, catalog import, bulk upload)

## Technical details

- In production today, 108 plans carry the "Setup fee" category but hold a charge that is not billed at signup
- In production today, 4,385 plans hold a charge billed at signup but carry a category other than "Setup fee" or "Deposit"

## Acceptance tests

#### Test 1: Setup fee with the wrong billing time

**Given** an existing plan with a category of "Setup fee" and no charges

**When** a user tries to add a charge billed at first renewal through the admin

**Then** a validation error is displayed and the charge is not created

---

#### Test 2: Signup-time charge on the wrong category

**Given** an existing plan with a category of "Overage" and no charges

**When** a user tries to add a charge billed at signup

**Then** a validation error is displayed and the charge is not created

---

#### Test 3: Valid configuration

**Given** an existing plan with a category of "Setup fee" and no charges

**When** a user adds a charge billed at signup

**Then** the charge is created successfully

---

#### Test 4: Existing misconfiguration blocks edits until fixed

**Given** an existing plan with no category and a charge already billed at signup

**When** a user tries to edit this plan or this charge

**Then** a validation error is displayed and no update is possible until either a "Setup fee" or "Deposit" category is set, or the charge's billing time is moved off signup
```

---

### Example 3: Scoped records with two entry paths

```
# Handle region-specific onboarding fees

## User story

As an admin or a customer, I would like the correct onboarding fee to be applied when a subscription is created, even when the account is configured with several region-specific fees.

## Requirements

- When a subscription is created, and the account holds several region-specific onboarding fees, the correct fee should be shown on the "New Subscription" modal and applied to the subscription
- The same behavior applies when the customer creates the subscription through self-serve checkout

## Acceptance tests

#### Test 1: Onboarding fee from the admin side

**Given** an account with two region-specific onboarding fees:
- "Onboarding - EU" for workspaces in the EU region
- "Onboarding - US" for workspaces in the US region

**When** an admin creates a subscription for an EU workspace

**Then** "Onboarding - EU" is shown on the "New Subscription" modal (no US fee)

**And** that fee is automatically applied to the created subscription

**And** that fee appears in the price breakdown and the Charges modal

---

#### Test 2: Deposit from the admin side

**Given** an account with two region-specific deposits:
- "Deposit - EU" for workspaces in the EU region
- "Deposit - US" for workspaces in the US region

**When** an admin creates a subscription for a US workspace

**Then** "Deposit - US" is shown on the "New Subscription" modal (no EU deposit)

**And** that deposit is automatically applied to the created subscription

**And** that deposit appears in the price breakdown and the Charges modal

---

#### Test 3: Onboarding fee from the customer side

**Given** an account with two region-specific onboarding fees:
- "Onboarding - EU" for workspaces in the EU region
- "Onboarding - US" for workspaces in the US region

**When** a customer completes self-serve checkout for an EU workspace

**Then** "Onboarding - EU" is automatically applied to the subscription (no US fee)
```

---

### Example 4: Small ticket (no rigid structure needed)

```
# Remove deprecated feature flag

Once the feature is released we can remove the `catalog-warning-banner-04172023` flag.

It controlled a warning banner on the plan page for add-ons that were listed but not available for the workspace's region. We no longer list unavailable add-ons at all, so the banner is gone and the flag is unused.

Flag link: <your-flag-provider>/projects/default/flags/catalog-warning-banner-04172023/
```
