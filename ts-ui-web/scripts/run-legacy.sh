#!/usr/bin/env bash
# Serve legacy static UI only (no API proxy). Prefer: bun run dev for the SPA.
set -euo pipefail
cd "$(dirname "$0")/.."
PORT="${UI_DASHBOARD_PORT:-8080}"
echo "TrainTicket legacy UI (static only — APIs need gateway):"
echo "  http://127.0.0.1:${PORT}/legacy/           ← admin home"
echo "  http://127.0.0.1:${PORT}/legacy/client_login.html"
echo "Modern SPA: bun run dev → http://127.0.0.1:5173/"
exec python3 -m http.server "$PORT" --directory .
