# EPIC-02 — Frontend SPA (Bun + Vue 3 + TypeScript)

**Status:** Backlog  
**Sprint:** S1

## Goal

Replace legacy static HTML (Vue2 + jQuery + AngularJS) with `ts-ui-web/` — Bun, Vite, Vue 3, TypeScript, Tailwind, Pinia.

## Tickets

| ID | Title | Status |
|----|-------|--------|
| TT-101 | Scaffold `ts-ui-web` (Bun + Vite + Vue 3 + TS) | Backlog |
| TT-102 | Pin Bun version in repo | Backlog |
| TT-103 | API client layer (`/api/v1/*`) | Backlog |
| TT-104 | Auth module (login, captcha, JWT, guards) | Backlog |
| TT-105 | Vite dev proxy `/api` → gateway | Backlog |
| TT-106 | Production build → static nginx behind edge | Backlog |
| TT-107 | Migrate ticket-office to Bun runtime | Backlog |
| TT-108 | API client uses only gateway paths | Backlog |

## Stack

```
ts-ui-web/
  package.json       # packageManager: bun@1.x
  vite.config.ts
  src/api/ stores/ views/ components/ router/
```

## Client UI flows (Phase 2 — S2–S3)

| ID | Title | Status |
|----|-------|--------|
| TT-201 | App shell | Backlog |
| TT-202 | Login + captcha | Backlog |
| TT-203 | Trip search (G/D or BFF) | Backlog |
| TT-204 | Booking wizard (+ TT-204a–d) | Backlog |
| TT-205 | Order list (+ TT-205a–d) | Backlog |
| TT-206 | Collect + enter station | Backlog |
| TT-207 | Advanced direct trip search | Backlog |
| TT-209–210 | Avatar, voucher | Backlog |

See EPIC-07 for TT-211–220 (registration, wallet, transfer, etc.).

## Depends on

- EPIC-01 (gateway routes working)
- TT-527 (OpenAPI client generation) — optional enhancement
