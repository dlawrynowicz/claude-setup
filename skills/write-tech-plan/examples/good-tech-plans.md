# Good Tech Plan Examples

Real examples from Funnel's best technical plans. Use these for tone and style reference.

<!-- Add examples below this line -->

Problem statement — concrete pain, not abstract (from MITS 5.0)
```
## Problem

Our current MITS 4.0 integration was built 3 years ago when we had 12 communities.
We now have 200+ communities, and the XML parser fails silently on 15% of imports.
Agents report missing floor plans daily — we get ~8 support tickets/week about this.

The MITS 4.0 spec doesn't support amenity-level pricing, so we've been working around
it with custom fields that break on every ILS update.
```

Decision matrix — multiple approaches with criteria (from MITS 5.0)
```
## Decision matrix

| Criteria | Approach A: Migrate to MITS 5.0 | Approach B: Custom REST API | Approach C: Patch MITS 4.0 |
|----------|:------:|:------:|:------:|
| Amenity pricing support | Native | Custom build | Workaround |
| ILS compatibility | Industry standard | Our communities only | Fragile |
| Effort | L (6-8 weeks) | XL (10-12 weeks) | S (2 weeks) |
| Long-term maintenance | Low | High | High |
| Risk | Medium — new parser | High — custom protocol | Low — known code |

**Recommendation:** Approach A. Industry standard, native amenity support, lower
long-term maintenance. The upfront effort is worth it.
```

Phase breakdown — ordered implementation (from RO refactor)
```
## Implementation phases

### Phase 1: New models + dual-write (2 weeks)
- Create `RentalOptionFeeVersion` model alongside existing `RentalOptionFee`
- Dual-write: every fee update writes to both old and new model
- No reads from new model yet — this is a safety net
- **Deliverable:** Migration deployed, dual-write confirmed in staging

### Phase 2: Read migration (1 week)
- Switch all fee reads to `RentalOptionFeeVersion`
- Old model still receives writes (rollback path)
- Feature flag: `use_fee_versions` per community
- **Deliverable:** 5 pilot communities reading from new model

### Phase 3: Cleanup (1 week)
- Remove dual-write
- Deprecate old fee fields
- Remove feature flag
- **Deliverable:** Old model fields marked for removal in next sprint
```

Before/after comparison — showing what changes (from RO refactor)
```
## Before/after

**Before (current):**
```python
# Fee lookup is scattered across 4 different methods
fee = RentalOptionFee.objects.filter(
    rental_option=ro,
    start_date__lte=today,
).order_by('-start_date').first()
# ... repeated in scheduled_price.py, carry_over.py, renewal_utils.py, line_item_orchestrator.py
```

**After (proposed):**
```python
# Single source of truth
fee = RentalOptionFee.active(date=lease_start_date).for_option(ro)
# All 4 call sites use this
```
```

Risk-mitigation pair (from MITS 5.0)
```
## Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| MITS 5.0 parser mishandles edge cases | Data loss on import | Medium | Run old + new parsers in parallel for 2 weeks, compare outputs |
| ILS providers slow to adopt 5.0 | Some communities stuck on 4.0 | Low | Keep 4.0 parser as fallback, feature-flag per community |
| Migration takes longer than estimated | Delays Q2 roadmap | Medium | Phase 1 is independently valuable — can ship and pause |
```

Real-world validation — testing against production data (from storage grouping)
```
## Real-world validation

Tested the grouping logic against production data from 3 communities:

| Community | Storage units | Current groups | Proposed groups | Improvement |
|-----------|:---:|:---:|:---:|:---:|
| Sunrise Apartments | 45 | 1 (all lumped) | 3 (by size) | Residents can filter |
| Harbor View | 120 | 12 (one per unit) | 4 (by floor) | Agents manage 4 groups, not 120 |
| Oak Gardens | 8 | 8 (one per unit) | 2 (indoor/outdoor) | Simpler pricing |

The proposed grouping correctly handles all 3 patterns. Edge case: Harbor View has
2 units with custom pricing — these stay as individual groups.
```

Product doc gap flag
```
{warning}No product doc exists for MITS 5.0 integration requirements.
This tech plan includes minimal context to be readable, but product requirements
should be documented separately with /write-product-doc.{warning}
```

Open questions — always last, concrete
```
## Open questions

1. **Rollback window** — how long do we keep the old parser running in parallel?
   2 weeks feels right, but depends on ILS provider adoption speed.
2. **Feature flag granularity** — per community or per ILS provider?
   Per community is simpler, per provider is more logical.
3. **Who owns the MITS 5.0 schema validation?** — us or the ILS team?
   Need to confirm with integrations team.
```
