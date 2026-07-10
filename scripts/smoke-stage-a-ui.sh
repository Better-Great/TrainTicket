#!/usr/bin/env bash
# Stage A — local SPA readiness smoke (mock mode; no Docker required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/ts-ui-web"

echo "=== Stage A: bun check (typecheck + unit tests + build) ==="
bun run check

echo ""
echo "=== Stage A: route SEO coverage (subset of vitest) ==="
bunx vitest run src/router/stage-a-ready.test.ts

echo ""
echo "=== Stage A READY ==="
echo "SPA mock surface is complete for client + admin parity."
echo "Next: Track B — docker compose up + ./scripts/smoke-test-routes.sh"
