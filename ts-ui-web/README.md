# TrainTicket SPA (`ts-ui-web`)

Modern client UI: **Bun + Vite + Vue 3 + TypeScript**.

## Local-first (no Docker)

```bash
cd ts-ui-web
bun install
bun run check          # typecheck + unit tests + production build
bun run dev            # http://localhost:5173  (mock API by default)
```

SEO assets live in `public/`: `robots.txt`, `sitemap.xml`, `site.webmanifest`, `og-default.svg`, `ld-website.json`.

`.env` defaults to `VITE_USE_MOCK=true` so you can exercise login → search → advanced → book → pay → collect → passengers without containers.

## Against a real gateway (later)

1. Start gateway (and deps) however you prefer.
2. Set `VITE_USE_MOCK=false` in `.env`.
3. `bun run dev` — Vite proxies `/api` to `VITE_GATEWAY_URL` (default `http://localhost:18888`).

Do **not** containerize this UI until `bun run check` is green and the mock flow is verified in the browser.

## Scripts

| Script | Purpose |
|--------|---------|
| `dev` / `dev:mock` | Local Vite server |
| `test` | Vitest unit tests (API services, stores, utils, components) |
| `typecheck` | `vue-tsc` |
| `build` | Production bundle |
| `check` | typecheck + test + build |

Every mock-backed service path (auth, travel, contacts, preserve/pay/collect/enter, wallet, wait-list) has unit coverage via `src/api/mock.test.ts` and `src/api/services.test.ts`.

