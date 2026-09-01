# Good Tech Plan Examples

Reference examples for tone and style. The domain is a generic subscription-billing product so nothing here reads as a real plan - copy the **shape**, not the subject.

<!-- Add examples below this line -->

Problem statement - concrete pain, not abstract (from Metering API v2)
```
## Problem

Our usage ingest was built 3 years ago when we billed 12 workspaces. We now bill 200+, and the
event parser fails silently on 15% of imports. Admins report missing usage daily - we get ~8
support requests a week about this.

The v1 API has no concept of per-event tiering, so we have been working around it with custom
fields that break on every provider update.
```

Decision matrix - multiple approaches with criteria (from Metering API v2)
```
## Decision matrix

| Criteria | A: Move to Metering v2 | B: Custom ingest service | C: Patch v1 |
|----------|:------:|:------:|:------:|
| Tiered pricing support | Native | Custom build | Workaround |
| Provider compatibility | Industry standard | Our workspaces only | Fragile |
| Effort | L (6-8 weeks) | XL (10-12 weeks) | S (2 weeks) |
| Long-term maintenance | Low | High | High |
| Risk | Medium - new parser | High - custom protocol | Low - known code |

**Recommendation:** Approach A. Industry standard, native tiering support, lower long-term
maintenance. The upfront effort is worth it.
```

Phase breakdown - ordered implementation (from pricing refactor)
```
## Implementation phases

### Phase 1: New models + dual-write (2 weeks)
- Create `PriceVersion` alongside the existing `Price`
- Dual-write: every rate update writes to both old and new model
- No reads from the new model yet - this is a safety net
- **Deliverable:** Migration deployed, dual-write confirmed in staging

### Phase 2: Read migration (1 week)
- Switch all price reads to `PriceVersion`
- Old model still receives writes (rollback path)
- Feature flag: `use_price_versions` per account
- **Deliverable:** 5 pilot accounts reading from the new model

### Phase 3: Cleanup (1 week)
- Remove dual-write
- Deprecate the old price fields
- Remove the feature flag
- **Deliverable:** Old model fields marked for removal next sprint
```

Before/after comparison - showing what changes (from pricing refactor)
```
## Before/after

**Before (current):**
```python
# Price lookup is scattered across 4 different methods
price = Price.objects.filter(
    add_on=add_on,
    start_date__lte=today,
).order_by('-start_date').first()
# ... repeated in scheduled_prices.py, carry_over.py, renewal_utils.py, charge_orchestrator.py
```

**After (proposed):**
```python
# Single source of truth
price = Price.active(date=start_date).for_add_on(add_on)
# All 4 call sites use this
```
```

Risk-mitigation pair (from Metering API v2)
```
## Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| v2 parser mishandles edge cases | Usage lost on import | Medium | Run old + new parsers in parallel for 2 weeks, compare outputs |
| Providers slow to adopt v2 | Some workspaces stuck on v1 | Low | Keep the v1 parser as fallback, feature-flag per account |
| Migration takes longer than estimated | Delays the Q2 roadmap | Medium | Phase 1 is independently valuable - can ship and pause |
```

Real-world validation - testing against production data (from add-on grouping)
```
## Real-world validation

Tested the grouping logic against production data from 3 accounts:

| Account | Add-ons | Current groups | Proposed groups | Improvement |
|---------|:---:|:---:|:---:|:---:|
| Acme | 45 | 1 (all lumped) | 3 (by tier) | Customers can filter |
| Globex | 120 | 12 (one per add-on) | 4 (by category) | Admins manage 4 groups, not 120 |
| Initech | 8 | 8 (one per add-on) | 2 (metered/flat) | Simpler pricing |

The proposed grouping handles all 3 patterns. Edge case: Globex has 2 add-ons with custom
pricing - these stay as individual groups.
```

Product doc gap flag
```
{warning}No product doc exists for the Metering v2 requirements.
This tech plan includes minimal context to be readable, but product requirements
should be documented separately with /write-product-doc.{warning}
```

Open questions - always last, concrete
```
## Open questions

1. **Rollback window** - how long do we keep the old parser running in parallel?
   2 weeks feels right, but depends on how fast providers adopt v2.
2. **Feature flag granularity** - per account or per provider?
   Per account is simpler, per provider is more logical.
3. **Who owns v2 schema validation?** - us or the integrations team?
   Need to confirm with that team.
```
