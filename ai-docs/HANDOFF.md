# Handoff — TrainTicket Modernization

**Last updated:** 2026-07-10  
**Branch:** `feat`  
**Active focus:** SPA quality — SEO/a11y + parity pages (local mock)

## Skills loaded

Personal (`~/.cursor/skills/`): `senior-ui-ux`, `senior-fullstack`, `senior-java`, `cloud-devops`, `system-design`  
Project: `.cursor/skills/trainticket-modernize`

## Read first

1. [`IMPROVEMENTS.md`](IMPROVEMENTS.md)  
2. [`../ts-ui-web/README.md`](../ts-ui-web/README.md)  
3. This file

## Where we stand

| Area | Status |
|------|--------|
| Skills | Installed (senior roles + TrainTicket workflow) |
| `ts-ui-web` | Home, login, register, search, **advanced**, book, orders, collect, **contacts** |
| SEO | Per-route title/desc/OG/Twitter, canonical, robots, sitemap, JSON-LD, webmanifest |
| A11y | Skip link, mobile nav, focus styles, reduced-motion, landmarks |
| Tests | `bun run check` — **10** unit tests + typecheck + build green |
| Docker | Still deferred |

## Next (continue)

1. Wait-list orders UI (TT-211)  
2. Ticket office finder (TT-212)  
3. Admin shell (login + one CRUD)  
4. Then gateway integration (`VITE_USE_MOCK=false`)

Wallet (TT-215) landed in SPA mock.

## Local

```bash
cd ts-ui-web && bun run check && bun run dev
# http://localhost:5173 — mock captcha 1234
```
