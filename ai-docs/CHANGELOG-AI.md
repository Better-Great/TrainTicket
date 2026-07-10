# AI Changelog

Newest first.

---

## 2026-07-10 — Track B local: polyglot + core Java ↔ SPA

**Agent:** Cursor  

### Summary

- Polyglot local modes: news (Go), office (file), voucher (in-memory); `smoke-polyglot.sh` 8/8
- Java gateway local profile + jar; SPA→gateway→polyglot without `VITE_POLYGLOT_DIRECT`
- Core Java (station/route/train/auth) on shared MySQL+Nacos; `smoke-java-core.sh` **13/13**
- Scripts: `start-polyglot-local`, `start-gateway-local`, `start-java-core-local`, smokes

---

## 2026-07-10 — Stage A UI ready + Track B probe

**Agent:** Cursor  

### Summary

- Completed Stage A SPA parity: security (TT-306), admin dashboard, voucher print
- `./scripts/smoke-stage-a-ui.sh` — **91** Vitest tests + build green
- Track B probed: gateway `18888` / edge `8080` down; `smoke-test-routes.sh` fails until compose up
- Vite mock SPA on `:5173` responds 200

---

## 2026-07-10 — food delivery tracking (TT-220)

**Agent:** Cursor  

### Summary

- SPA `/food` with mock + `fooddeliveryservice` (create, trip/seat/time updates, delete)
- Search + seat tracking UX; **85** Vitest tests

---

## 2026-07-10 — admin orders BFF

**Agent:** Cursor  

### Summary

- SPA `/admin/orders` with mock + `adminorderservice/adminorder`
- Status filter/search; delete requires orderId + trainNumber; **81** Vitest tests

---

## 2026-07-10 — admin travels CRUD

**Agent:** Cursor  

### Summary

- SPA `/admin/travels` with mock + `admintravelservice/admintravel`
- Trip ID helper; options from trains/routes/stations; **77** Vitest tests

---

## 2026-07-10 — admin prices, config, contacts

**Agent:** Cursor  

### Summary

- SPA `/admin/prices`, `/admin/config`, `/admin/contacts` via `adminbasicservice`
- Mock validation + Vitest; **73** tests green

---

## 2026-07-10 — admin users CRUD

**Agent:** Cursor  

### Summary

- SPA `/admin/users` with mock + `adminuserservice/users`
- Unit tests for CRUD + duplicate username; **61** Vitest tests green

---

## 2026-07-10 — admin trains CRUD

**Agent:** Cursor  

### Summary

- SPA `/admin/trains` with mock + `adminbasicservice/adminbasic/trains`
- Legacy `confortClass` spelling preserved; unit tests for CRUD + validation
- **57** Vitest tests green

---

## 2026-07-10 — admin routes CRUD

**Agent:** Cursor  

### Summary

- SPA `/admin/routes` with mock + `/api/v1/adminrouteservice/adminroute`
- Shared admin nav; validation aligned with Java RouteInfo (comma lists)
- Unit tests for create/update/delete and mismatch cases

---

## 2026-07-10 — news feed (TT-219)

**Agent:** Cursor  

### Summary

- SPA `/news` with mock seed + live `/api/v1/newsservice/news` (fallback `/news-service/news`)
- Nav, SEO route meta, sitemap
- Vitest coverage for mock/services; `ts-news-service` Go tests (`hello` JSON + port env)
- **48** Vitest tests green

---

## 2026-07-10 — unify UI under ts-ui-web (ADR-008)

**Agent:** Cursor  

### Summary

- Moved `ts-ui-dashboard/static` → `ts-ui-web/legacy/`
- Moved nginx → `ts-ui-web/edge/nginx.conf` (SPA `/` + legacy `/legacy/` + gateway proxy)
- Removed `ts-ui-dashboard/`; compose builds from `ts-ui-web`
- Multi-stage Dockerfile (Bun SPA build → nginx)

---

## 2026-07-10 — admin shell + stations CRUD

**Agent:** Cursor  

### Summary

- `/admin/login` (separate `admin_token` session) + `/admin/stations` full CRUD
- Client API supports admin role headers (`apiPut`/`apiDelete`)
- Ticket offices + admin covered in unit tests — **46** total
- Still uncommitted on top of `40c8985` (not pushed)

---

## 2026-07-10 — ticket office finder (TT-212)

**Agent:** Cursor  

### Summary

- `/offices` cascading province → city → district search
- Mock + `/office/*` live paths; unit tests (40 total)
- Prior commit `40c8985` wait-list/tests remains local (not pushed)

---

## 2026-07-10 — wait-list polish + full service unit tests

**Agent:** Cursor  

### Summary

- Wait-list UX: validation, cancel, active/history filter, status chips, station swap, skeletons
- Mock hardening: `resetMockState`, wallet debit on pay, lifecycle guards, wait-list duplicate checks
- Unit tests for **every** SPA service path — **37** tests green
- Orders page: wallet link + collect CTA; pay respects mock status errors

---

## 2026-07-10 — wait-list UI (TT-211)

**Agent:** Cursor  

### Summary

- Added `/waitlist` — list + create wait-list orders (mock + gateway paths)
- Nav/SEO/robots updated; mock unit test added
- Prior SPA commit `f1119ae` remains local (not pushed)

---

## 2026-07-10 — skills + SEO + parity pages

**Agent:** Cursor  
**Tickets:** TT-207, TT-214, TT-401/403 (partial), SEO

### Summary

- Installed skills: senior-ui-ux, senior-fullstack, senior-java, cloud-devops, system-design + project `trainticket-modernize`
- SPA SEO: route meta, OG/Twitter, canonical, robots.txt, sitemap.xml, JSON-LD, webmanifest
- UX: skip link, mobile menu, footer, reduced-motion
- New pages: Advanced search, Passengers (contacts)
- Tests: 10 passing via `bun run check`

---

## 2026-07-10 — UI-first SPA scaffold (local)

**Agent:** Cursor  
**Tickets:** TT-101–105 (partial), TT-201–206 (partial), TT-406

### Summary

- Policy: improve UI locally with mocks **before** Docker/container testing
- Created `ts-ui-web/` — Bun + Vite + Vue 3 + TS + Pinia + Vue Router
- Design tokens (Syne/Manrope, steel + signal amber); hero + core client flows
- Mock API for login → search → book → pay → collect
- `bun run check` green (8 unit tests + production build)
- Updated `IMPROVEMENTS.md` / `HANDOFF.md` for UI-first sequence

### Verify locally

```bash
cd ts-ui-web && bun run check && bun run dev
```

---

## 2026-07-10 — path confirm + improvements backlog

**Agent:** Cursor  
**Tickets:** planning (TT-006, TT-007, pull-forward TT-706/604)

### Summary

- Confirmed active path: `TrainTicket/` on `feat` (S0 commit `0c80c43`); `train-ticket/` read-only
- Added `IMPROVEMENTS.md` — P0 smoke/ports/avatar, then SPA + lean compose + optional k8s
- New ticket **TT-007** (avatar direct HTTP gateway route)
- Refreshed `HANDOFF.md` (commit already done; smoke still unverified)

### Files changed

- `ai-docs/IMPROVEMENTS.md` (new)
- `ai-docs/HANDOFF.md`
- `ai-docs/README.md`
- `ai-docs/ROADMAP.md`
- `ai-docs/backlog/EPIC-01-edge-routing.md`
- `ai-docs/sessions/2026-07-10-path-improvements.md`

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
