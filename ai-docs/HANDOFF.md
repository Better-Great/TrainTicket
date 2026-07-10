# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-10  
**Branch:** `feat` (local commits + uncommitted UI unify)  
**Active focus:** Single UI package `ts-ui-web/`

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
bun run check && bun run dev     # SPA :5173
bun run legacy                   # optional legacy static
```

## Next

1. News feed or more admin CRUDs  
2. Gateway live mode  
3. Commit accumulated work when ready  
