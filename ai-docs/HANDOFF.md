# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-10  
**Branch:** `feat`  
**Scope:** Whole `TrainTicket/` (not SPA-only).

## Stage status

| Stage | Status |
|-------|--------|
| **A — UI ready (mock SPA)** | **DONE** — `./scripts/smoke-stage-a-ui.sh`; **91** Vitest tests |
| **B — Live gateway / smoke** | **IN PROGRESS** — polyglot + core Java verified locally (see below) |
| **C — Service harden** | After B (remaining Java services, config DDL, full compose) |

## Track B — verified locally (2026-07-10)

### Non-Java (polyglot) → SPA
```bash
./scripts/start-polyglot-local.sh
# optional direct: VITE_USE_MOCK=false VITE_POLYGLOT_DIRECT=1 bun run dev
./scripts/smoke-polyglot.sh          # 8/8
```

### Java gateway → polyglot (+ SPA without POLYGLOT_DIRECT)
```bash
./scripts/start-gateway-local.sh     # profile=local, jar on :18888
cd ts-ui-web && VITE_USE_MOCK=false bun run dev
./scripts/smoke-gateway-polyglot.sh  # 8/8
```

### Core Java (auth/station/route/train) → gateway → SPA
```bash
# infra
docker compose -f docker-compose.minimal.yml --env-file .env up -d nacos mysql redis
./scripts/start-java-core-local.sh --build
./scripts/start-gateway-local.sh --with-nacos
./scripts/smoke-java-core.sh         # stations/routes/trains + polyglot via SPA
```

**Modern local notes:** polyglot file/in-memory modes; gateway `application-local.yml`; Nacos IP forced to `127.0.0.1`; heap caps on JVMs (~256–384m). `ts-config-service` still fails DDL on MySQL 8 (key length) — skip for now.

## Stage A surfaces (complete)

Client: home, auth, search, advanced, book, orders (+ voucher), collect, contacts, wallet, wait-list, food, voucher, offices, news  

Admin: dashboard, stations, routes, trains, travels, prices, config, contacts, users, orders, security

## Next — Track B remainder / Stage C

- Bring up more Java services (travel, order, preserve, payment, …) against shared MySQL  
- Fix `ts-config-service` schema for MySQL 8  
- Full `./scripts/smoke-test-routes.sh` once wait-order / food-delivery / edge UI are up  
- Harden & trim legacy defaults (k8s Nacos hostnames, hardcoded MySQL passwords)
