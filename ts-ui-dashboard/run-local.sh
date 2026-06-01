#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PORT="${UI_DASHBOARD_PORT:-8080}"
echo "TrainTicket UI (static files only — /api/v1/ needs nginx + gateway in Docker):"
echo "  http://127.0.0.1:${PORT}/           ← admin home (index.html)"
echo "  http://127.0.0.1:${PORT}/client_login.html  ← client entry"
exec python3 -m http.server "$PORT" --directory static
