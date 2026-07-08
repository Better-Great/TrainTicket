# Session 2026-07-08 — S0 Gateway & Edge Routing

## Goal

Bootstrap `ai-docs/`, add missing gateway routes, update nginx edge proxy, smoke-test locally.

## Changes

| Area | Files |
|------|-------|
| Gateway routes | `ts-gateway-service/src/main/resources/application.yml` |
| Edge nginx | `ts-ui-dashboard/nginx.conf` |
| Sentinel fix | `GatewayConfiguration.java`, `Dockerfile.Ts.Gateway.Service` |
| Smoke script | `scripts/smoke-test-routes.sh` |
| ai-docs | `ai-docs/**` |

## Tickets

- TT-000 — ai-docs skeleton
- TT-001 — gateway routes
- TT-002 — polyglot path normalization
- TT-003 — nginx API via gateway

## Blockers encountered

1. Gateway crashed: Sentinel `FileHandler` NPE → fixed with `catch (Throwable)` + `-Dcsp.sentinel.log.dir=/tmp/sentinel`
2. Log bind mount permission denied on `/app/logs/sentinel` → use `/tmp/sentinel`
3. Nacos slow to become healthy (~25s) — wait before starting Java services
4. Full 46-service pull very slow on first run

## Local test

```bash
docker compose -f docker-compose.build.yml up -d mysql nacos rabbitmq redis \
  ts-gateway-service ts-ui-dashboard ts-news-service ts-voucher-service \
  ts-ticket-office-service ts-wait-order-service ts-food-delivery-service
./scripts/smoke-test-routes.sh
```

## Next session

1. Confirm gateway fully healthy; re-run smoke tests
2. TT-005 — complete PARITY-CHECKLIST (done in ai-docs)
3. TT-101 — scaffold `ts-ui-web` (Bun + Vue 3)
