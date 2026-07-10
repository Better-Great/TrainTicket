# Session — Admin orders BFF

**Date:** 2026-07-10  
**Scope:** SPA admin orders aggregated BFF + tests

## Done

- `/admin/orders` CRUD via `adminorderservice/adminorder`
- Delete path includes `orderId/trainNumber` (legacy contract)
- Status filter + search for operator triage
- **81** Vitest tests green

## Verify

```bash
cd ts-ui-web && bun run check
```

## Next

1. Food delivery tracking (TT-220) or security config
2. Gateway live mode + smoke (deferred)
