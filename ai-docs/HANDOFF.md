# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-10  
**Branch:** `feat` (local commits; do not push unless asked)  
**Active focus:** Whole `TrainTicket/` — section-by-section with unit tests

## UI layout (ADR-008)

```
ts-ui-web/
  src/       ← modern SPA (primary)
  legacy/    ← former ts-ui-dashboard/static
  edge/      ← nginx.conf
  Dockerfile
```

## Local

```bash
cd ts-ui-web
bun run check && bun run dev     # SPA :5173, mock by default
```

## Done recently

- Client flows, wait-list, offices, news (TT-219)
- Admin stations + **routes** CRUD

## Next

1. Admin Trains CRUD (+ unit tests)
2. Admin Users CRUD
3. Gateway live mode (`VITE_USE_MOCK=false`) + smoke — deferred
