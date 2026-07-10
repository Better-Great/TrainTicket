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

`ts-ui-dashboard/` **removed**. Compose service name may still be `ts-ui-dashboard` with `build: ts-ui-web`.

## Local

```bash
cd ts-ui-web
bun run check && bun run dev     # SPA :5173, mock by default
bun run legacy                   # optional legacy static
```

## Done recently

- Client flows, wait-list, offices, admin stations
- News feed TT-219 (`/news` + Go service tests)

## Next

1. Admin Routes CRUD (+ unit tests)
2. Admin Trains / Users CRUD
3. Gateway live mode (`VITE_USE_MOCK=false`) + smoke — deferred
