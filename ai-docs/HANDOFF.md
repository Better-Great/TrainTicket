# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-10  
**Branch:** `feat` (local commits; do not push unless asked)  
**Scope:** Whole `TrainTicket/` (not SPA-only).

## Stage status

| Stage | Status |
|-------|--------|
| **A — UI ready (mock SPA)** | **DONE** — `./scripts/smoke-stage-a-ui.sh` green; **91** Vitest tests |
| **B — Live gateway / smoke** | **NEXT** — stack not up locally (`localhost:18888` down); `./scripts/smoke-test-routes.sh` fails until compose |
| **C — Service harden** | After B |

## Strategy

1. UI-first / local-first mocks matching gateway paths ← **complete**  
2. Live: `VITE_USE_MOCK=false` + docker compose + gateway smoke  
3. Harden Java / polyglot services  

## Stage A surfaces (complete)

Client: home, auth, search, advanced, book, orders (+ voucher link), collect, contacts, wallet, wait-list, food, voucher, offices, news  

Admin: dashboard, stations, routes, trains, travels, prices, config, contacts, users, orders, security (TT-306)

## Verify Stage A

```bash
./scripts/smoke-stage-a-ui.sh
# or: cd ts-ui-web && bun run check && bun run dev
```

## Next — Track B

```bash
# bring up gateway + deps (compose profile as documented)
./scripts/smoke-test-routes.sh
# then point SPA: VITE_USE_MOCK=false bun run dev
```
