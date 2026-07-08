# AI Changelog

Newest first.

---

## 2026-07-09 — ai-docs complete tree

**Agent:** Cursor  
**Tickets:** TT-000, TT-001a, TT-002a, TT-003a

### Summary

- Created full `ai-docs/` directory: ARCHITECTURE, FLAWS-AUDIT, PARITY-CHECKLIST
- Added backlog EPIC-00 through EPIC-09
- Added sessions/ and implemented/ records
- Updated HANDOFF, ROADMAP, README for next agent

---

## 2026-07-08 — S0 gateway & edge routing

**Agent:** Cursor  
**Tickets:** TT-001, TT-002, TT-003

### Summary

- Gateway routes for wait-order, food-delivery, polyglot services
- nginx edge proxy via gateway only
- Sentinel startup fix in GatewayConfiguration + Dockerfile
- Added `scripts/smoke-test-routes.sh`

### Files changed

- `ts-gateway-service/src/main/resources/application.yml`
- `ts-gateway-service/src/main/java/gateway/GatewayConfiguration.java`
- `dockerfile/Dockerfile.Ts.Gateway.Service`
- `ts-ui-dashboard/nginx.conf`
- `scripts/smoke-test-routes.sh`

### Blockers

- Gateway slow start on WSL; Nacos health wait required
- Log bind mount permissions for Sentinel (fixed with `/tmp/sentinel`)
