# Backlog Index

**Ticket format:** `TT-###`  
**Status:** `Backlog` → `Ready` → `In Progress` → `Review` → `Done`

## Epics

| Epic | Title | Sprint | Status |
|------|-------|--------|--------|
| [EPIC-00](EPIC-00-ai-docs.md) | ai-docs bootstrap | S-1 | Done |
| [EPIC-01](EPIC-01-edge-routing.md) | Edge routing & gateway | S0 | In Progress |
| [EPIC-02](EPIC-02-frontend-spa.md) | Bun + Vue 3 SPA | S1 | Backlog |
| [EPIC-03](EPIC-03-ui-ux.md) | UI/UX polish | S5 | Backlog |
| [EPIC-04](EPIC-04-backend.md) | Backend hardening | S6 | Backlog |
| [EPIC-05](EPIC-05-devops.md) | DevOps & CI/CD | S7 | Backlog |
| [EPIC-06](EPIC-06-observability.md) | Observability | S7 | Backlog |
| [EPIC-07](EPIC-07-feature-parity-plus.md) | Feature parity+ | S2–S3 | Backlog |
| [EPIC-08](EPIC-08-resilience.md) | Resilience & sagas | S6 | Backlog |
| [EPIC-09](EPIC-09-research-ops.md) | Research benchmark ops | S7+ | Backlog |

Open S0 leftovers: **TT-006** (ports), **TT-007** (avatar direct HTTP), green smoke. See [`../IMPROVEMENTS.md`](../IMPROVEMENTS.md).

## Client UI tickets (Phase 2)

| ID | Title | Epic |
|----|-------|------|
| TT-201 | App shell | EPIC-02 |
| TT-202 | Login | EPIC-02 |
| TT-203 | Trip search | EPIC-07 |
| TT-204 | Booking wizard | EPIC-07 |
| TT-205 | Order list | EPIC-07 |
| TT-206 | Collect + board | EPIC-07 |
| TT-207 | Advanced search | EPIC-07 |
| TT-208–220 | See EPIC-07 | EPIC-07 |

## Admin UI tickets (Phase 3)

| ID | Title | Epic |
|----|-------|------|
| TT-301–306 | Admin CRUD + security | EPIC-07 |

## Recently completed

| ID | Title | Record |
|----|-------|--------|
| TT-000 | ai-docs bootstrap | [implemented/TT-000-ai-docs.md](../implemented/TT-000-ai-docs.md) |
| TT-001 | Gateway routes | [implemented/TT-001-gateway-routes.md](../implemented/TT-001-gateway-routes.md) |
| TT-003 | nginx edge proxy | [implemented/TT-003-nginx-edge.md](../implemented/TT-003-nginx-edge.md) |

## Ticket ID ranges

| Range | Domain |
|-------|--------|
| TT-000–099 | Foundation, edge, docs |
| TT-101–199 | SPA scaffold & tooling |
| TT-201–399 | Client & admin UI |
| TT-401–499 | UX polish |
| TT-501–599 | Backend & security |
| TT-601–699 | DevOps & CI |
| TT-701–799 | Observability |
| TT-801–899 | Research ops parity |
