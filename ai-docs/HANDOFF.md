# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-09  
**Branch:** `feat` (changes **not committed** — see AUDIT.md)  
**Active sprint:** S0 — wrapping up (smoke tests **not yet green**)

## Read first on new server

1. [`AUDIT.md`](AUDIT.md) — honest confidence + gaps  
2. [`MIGRATION.md`](MIGRATION.md) — setup steps  
3. This file — current focus

## Current state (honest)

| Area | Status |
|------|--------|
| ai-docs/ | **Complete** — 23 files, all epics |
| Gateway routes (code) | **In repo** — not fully runtime-verified |
| nginx edge (code) | **In repo** — UI static OK; API needs gateway warm |
| Smoke tests | **Not passing** last run (gateway slow / 502) |
| ts-ui-web SPA | **Not started** (TT-101 next) |
| CI/CD, k8s | **Not started** |

## Uncommitted work — commit before server move

```
M  dockerfile/Dockerfile.Ts.Gateway.Service
M  ts-gateway-service/.../GatewayConfiguration.java
M  ts-gateway-service/.../application.yml
M  ts-ui-dashboard/nginx.conf
?? ai-docs/
?? scripts/smoke-test-routes.sh
```

## S0 tickets

| ID | Title | Code | Verified |
|----|-------|------|----------|
| TT-000 | ai-docs | Done | Yes |
| TT-001 | Gateway routes | Done | Partial |
| TT-002 | Polyglot paths | Done | Partial |
| TT-003 | nginx edge | Done | Partial |
| TT-004 | Edge container | Backlog | — |
| TT-005 | PARITY-CHECKLIST | Done | Yes |
| TT-006 | Port docs + ini alignment | Backlog | — |

**S0 is NOT Done** until `scripts/smoke-test-routes.sh` exits 0.

## Next tickets (priority)

1. Commit + push `feat` branch  
2. On new server: `MIGRATION.md` setup → smoke tests  
3. TT-006 — fix `PORTS.md` + `docker.application.ini` port drift  
4. TT-101 — Scaffold `ts-ui-web` (Bun + Vue 3)

## Known port drift (fix in TT-006)

`properties/docker.application.ini` has stale ports vs `docker-compose.build.yml`:

- News: ini 16900 → compose **12862**
- Wait-order: ini 17525 → compose **16804**
- Food-delivery: ini 18957 → compose **16803**

## Smoke test

```bash
docker compose -f docker-compose.build.yml up -d mysql nacos rabbitmq redis \
  ts-gateway-service ts-ui-dashboard ts-news-service ts-voucher-service \
  ts-ticket-office-service ts-wait-order-service ts-food-delivery-service
# wait 3 min
./scripts/smoke-test-routes.sh
```

## Scope reminder

- **Edit:** `TrainTicket/` only  
- **Reference:** `train-ticket/` read-only  
- **Runtime:** Bun (not Node) for future frontend
