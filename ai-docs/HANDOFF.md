# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-10  
**Branch:** `feat`  
**Scope:** Whole `TrainTicket/` (not SPA-only).

## Stage status

| Stage | Status |
|-------|--------|
| **A — UI ready (mock SPA)** | **DONE** — `./scripts/smoke-stage-a-ui.sh`; **91** Vitest tests |
| **B — Live gateway / smoke** | **IN PROGRESS** — polyglot + core Java (incl. config/wait/food) live |
| **C — Service harden** | Next: more Java services, edge UI `:8080`, travel/order/payment |

## Track B — verified locally (2026-07-10)

```bash
docker compose -f docker-compose.minimal.yml --env-file .env up -d nacos mysql redis
./scripts/start-polyglot-local.sh
./scripts/start-java-core-local.sh --build   # auth,station,route,train,config,wait,food
./scripts/start-gateway-local.sh --with-nacos
cd ts-ui-web && VITE_USE_MOCK=false bun run dev

./scripts/smoke-polyglot.sh
./scripts/smoke-gateway-polyglot.sh
./scripts/smoke-java-core.sh
SKIP_UI=1 ./scripts/smoke-test-routes.sh     # gateway routes; skip nginx :8080
```

**Fixes this pass:** config MySQL 8 PK length; wait-order security (wrong order paths); local JDBC/Nacos defaults for wait/food/config.

## Next

- Edge UI on `:8080` (or point smoke at Vite `:5173`)
- More Java: travel, order, preserve, payment, verify-code
- Harden remaining k8s/MySQL defaults across services
