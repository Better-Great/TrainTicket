# Session — Admin trains CRUD

**Date:** 2026-07-10  
**Scope:** SPA admin train types + tests

## Done

- `/admin/trains` CRUD via `adminbasicservice/adminbasic/trains`
- Preserves legacy `confortClass` field name
- AdminNav includes Trains; Vitest coverage

## Verify

```bash
cd ts-ui-web && bun run check
```

## Next

1. Admin Users CRUD
2. Prices / Config / Contacts admin
3. Gateway live mode + smoke (deferred)
