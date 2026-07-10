---
name: trainticket-modernize
description: >-
  TrainTicket modernization workflow — edit TrainTicket/ only, local-first SPA,
  gateway-first APIs, ai-docs session protocol. Use when working in the
  TrainTicket repo, ts-ui-web, gateway, or ai-docs.
---

# TrainTicket Modernize

## Scope

- **Edit:** `TrainTicket/` only
- **Reference:** `train-ticket/` read-only
- **Frontend runtime:** Bun (not Node)
- **UI path:** `ts-ui-web/` — not legacy `ts-ui-dashboard` polish

## Session protocol

1. Read `ai-docs/HANDOFF.md` + `ai-docs/IMPROVEMENTS.md`
2. Apply skills: senior-ui-ux, senior-fullstack, senior-java, cloud-devops, system-design as relevant
3. End: update `CHANGELOG-AI.md`, `HANDOFF.md`, `sessions/YYYY-MM-DD-*.md`

## Priority order

1. SPA local (`VITE_USE_MOCK=true`, `bun run check`)
2. SEO/a11y/parity pages
3. Gateway integration (`VITE_USE_MOCK=false`)
4. Smoke + lean compose
5. CI / k8s

## Verify SPA

```bash
cd ts-ui-web && bun run check && bun run dev
```
