# TrainTicket Modernization Roadmap

**Scope:** `TrainTicket/` only. Reference: `train-ticket/` (read-only).

## Decisions locked in

- Modern SPA rewrite (Bun + Vue 3 + TypeScript)
- Gateway owns all north-south API routing
- ai-docs on GitHub for AI continuity

---

## Sprint plan

| Sprint | Focus | Exit criteria |
|--------|-------|---------------|
| **S-1** | TT-000–003a | ai-docs complete on GitHub |
| **S0** | TT-001–006 | Gateway routes in code; smoke tests must pass before Done |
| **S1** | TT-101–107 | `bun run dev` SPA hits gateway |
| **S2** | TT-201–205, TT-213 | Login + register + search + book + pay |
| **S3** | TT-206–220 | Full lifecycle + wallet + contacts + search variants |
| **S4** | TT-301–306 | Admin CRUD + security config |
| **S5** | TT-401–407, TT-532 | UX polish; G/D BFF; legacy UI deprecated |
| **S6** | TT-501–532 | Security, resilience, schema |
| **S7** | TT-601–811 | CI, K8s, observability, research ops |

---

## Phase 0 — Edge & Gateway (S0)

| ID | Ticket | Status |
|----|--------|--------|
| TT-000 | ai-docs bootstrap | Done |
| TT-001 | Missing gateway routes | Done |
| TT-002 | Polyglot path normalization | Done |
| TT-003 | nginx API via gateway | Done |
| TT-004 | Dedicated edge container | Backlog |
| TT-005 | PARITY-CHECKLIST | Done |
| TT-006 | Port docs alignment | Backlog |
| TT-007 | Avatar polyglot direct HTTP route | Backlog |

---

## Phase 1 — SPA Foundation (S1)

| ID | Ticket | Status |
|----|--------|--------|
| TT-101–108 | Bun + Vue 3 scaffold, API client, auth | **In progress** (`ts-ui-web/` local) |
| TT-107 | ticket-office on Bun | Backlog |

---

## Phase 2 — Client UI (S2–S3)

| ID | Ticket | Status |
|----|--------|--------|
| TT-201–212 | Core client pages | Backlog |
| TT-213–220 | Registration, wallet, transfer, route plan, etc. | Backlog |
| TT-204a–d | Booking sub-flows | Backlog |
| TT-205a–d | Order sub-flows | Backlog |

---

## Phase 3 — Admin UI (S4)

| ID | Ticket | Status |
|----|--------|--------|
| TT-301–306 | Admin CRUD + security config | Backlog |

---

## Phase 4 — UX (S5)

| ID | Ticket | Status |
|----|--------|--------|
| TT-401–407 | Design system, a11y, mobile, i18n | Backlog |

---

## Phase 5 — Backend (S6)

See `backlog/EPIC-04-backend.md` and `FLAWS-AUDIT.md` — TT-501 through TT-532.

---

## Phase 6 — DevOps (S7)

See `backlog/EPIC-05-devops.md` — TT-601 through TT-606.

---

## Phase 7 — Observability (S7)

See `backlog/EPIC-06-observability.md` — TT-701 through TT-706.

---

## Phase 8 — Research ops (S7+)

See `backlog/EPIC-09-research-ops.md` — TT-801 through TT-811.

---

## Target stack (2026)

| Layer | Today | Target |
|-------|-------|--------|
| Edge | nginx in UI container | Caddy/nginx static + single :8080 |
| Gateway | Partial routes | All north-south APIs + JWT + trace ID |
| Services | Boot 2.3, RestTemplate | Boot 2.7 bridge, WebClient |
| Frontend | Vue2+jQuery+AngularJS | Bun+Vite+Vue3+TS |
| Config | Token-replacement JAR | Nacos config + env |
| CI/CD | Manual scripts | GitHub Actions |
| AI docs | — | `ai-docs/` on GitHub |

---

## Epics index

| Epic | File |
|------|------|
| 00 ai-docs | `backlog/EPIC-00-ai-docs.md` |
| 01 Edge routing | `backlog/EPIC-01-edge-routing.md` |
| 02 Frontend SPA | `backlog/EPIC-02-frontend-spa.md` |
| 03 UI/UX | `backlog/EPIC-03-ui-ux.md` |
| 04 Backend | `backlog/EPIC-04-backend.md` |
| 05 DevOps | `backlog/EPIC-05-devops.md` |
| 06 Observability | `backlog/EPIC-06-observability.md` |
| 07 Feature parity+ | `backlog/EPIC-07-feature-parity-plus.md` |
| 08 Resilience | `backlog/EPIC-08-resilience.md` |
| 09 Research ops | `backlog/EPIC-09-research-ops.md` |
