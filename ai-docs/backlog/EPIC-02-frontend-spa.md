# EPIC-02 — Frontend SPA (Bun + Vue 3 + TypeScript)

**Status:** In Progress — `ts-ui-web/` scaffolded; mock-first local  
**Sprint:** S1

## Goal

Replace legacy static HTML (Vue2 + jQuery + AngularJS) with `ts-ui-web/` — Bun, Vite, Vue 3, TypeScript.

## Local-first rule

Run and test the SPA with `VITE_USE_MOCK=true` until `bun run check` is green and the browser flow works. **Do not containerize the UI first.**

## Tickets

| ID | Title | Status |
|----|-------|--------|
| TT-101 | Scaffold `ts-ui-web` (Bun + Vite + Vue 3 + TS) | Done |
| TT-102 | Pin Bun version in repo | Done (`packageManager`) |
| TT-103 | API client layer (`/api/v1/*`) + mock | Done |
| TT-104 | Auth module (login, captcha, JWT, guards) | Done |
| TT-105 | Vite dev proxy `/api` → gateway | Done |
| TT-106 | Production build → static nginx behind edge | Backlog |
| TT-107 | Migrate ticket-office to Bun runtime | Backlog |
| TT-108 | API client uses only gateway paths | Done (paths ready) |

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
