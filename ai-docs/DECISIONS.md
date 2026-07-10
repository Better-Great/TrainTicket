# Architecture Decision Records

## ADR-001 — Gateway owns all north-south API routing

**Date:** 2026-07-08  
**Status:** Accepted

Browser-facing APIs go through `ts-gateway-service`. The UI nginx container serves static files and proxies `/api/` and legacy polyglot paths to the gateway — it does not route to individual service ports.

## ADR-002 — Polyglot services use direct HTTP in gateway

**Date:** 2026-07-08  
**Status:** Accepted

`ts-voucher-service`, `ts-ticket-office-service`, and `ts-news-service` do not register with Nacos. Gateway routes use `http://host:port` URIs with `RewritePath` filters for `/api/v1/` normalization and legacy path compatibility.

## ADR-003 — ai-docs on GitHub for AI continuity

**Date:** 2026-07-08  
**Status:** Accepted

All plans, handoffs, decisions, and implementation logs live in `TrainTicket/ai-docs/` and are committed to the repo.

## ADR-004 — Bun as JS/TS runtime

**Date:** 2026-07-08  
**Status:** Accepted

Use Bun instead of Node/npm for `ts-ui-web` SPA, ticket-office service, CI, and Docker builds (`oven/bun` image).

## ADR-005 — Modern SPA rewrite (not incremental legacy polish)

**Date:** 2026-07-08  
**Status:** Accepted

Replace static Vue2 + jQuery + AngularJS with new `ts-ui-web/` (Bun + Vite + Vue 3 + TypeScript). Legacy UI remains until SPA reaches parity.

## ADR-006 — Sentinel failures are non-fatal at gateway startup

**Date:** 2026-07-08  
**Status:** Accepted

`GatewayConfiguration.doInit()` catches `Throwable` from Sentinel rule init. Sentinel logs go to `/tmp/sentinel` to avoid bind-mount permission issues on `log/ts-gateway-service/`.

## ADR-007 — train-ticket/ is read-only reference

**Date:** 2026-07-08  
**Status:** Accepted

All implementation work in `TrainTicket/` only. Use `train-ticket/` for feature parity and API contract reference; never modify it.

## ADR-008 — Single UI package (`ts-ui-web`)

**Date:** 2026-07-10  
**Status:** Accepted

All frontend assets live under `ts-ui-web/`: modern SPA in `src/`, legacy dashboard in `legacy/`, nginx edge in `edge/`. The old `ts-ui-dashboard/` directory is removed. Docker Compose may keep the historical service name `ts-ui-dashboard` while building from `ts-ui-web`.
