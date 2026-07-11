# TrainTicket UI (`ts-ui-web`)

**Single UI package** for the whole frontend:

| Path | Role |
|------|------|
| `src/` | Modern SPA — Bun + Vite + Vue 3 + TypeScript |
| `legacy/` | Former `ts-ui-dashboard/static` (Vue2/jQuery/AngularJS) |
| `edge/` | nginx config for Docker (SPA + `/legacy/` + gateway proxy) |
| `Dockerfile` | Multi-stage Bun build → nginx image |

`ts-ui-dashboard/` has been **removed**; compose still uses service name `ts-ui-dashboard` with `build: ts-ui-web`.

## Local-first (no Docker)

```bash
cd ts-ui-web
bun install
bun run check          # typecheck + unit tests + production build
bun run dev            # http://localhost:5173  (mock API by default)
bun run legacy         # optional: legacy static on :8080
```

SEO assets live in `public/`. `.env` defaults to `VITE_USE_MOCK=true`.

## Against a real gateway

1. Set `VITE_USE_MOCK=false` in `.env`.
2. `bun run dev` — Vite proxies `/api` (and `/office`, etc.) to `VITE_GATEWAY_URL`.

## Docker

```bash
# From repo root (compose)
docker compose -f docker-compose.build.yml build ts-ui-dashboard

# Or package context
docker build -t ts-ui-web -f ts-ui-web/Dockerfile ts-ui-web
```

Image serves SPA at `/` and legacy at `/legacy/`.

## Scripts

| Script | Purpose |
|--------|---------|
| `dev` / `dev:mock` | Vite SPA |
| `legacy` | Python static server for `legacy/` |
| `test` / `typecheck` / `build` / `check` | Quality gate |
