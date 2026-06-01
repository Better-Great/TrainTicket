#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Copy .env.example to .env first." >&2
  exit 1
fi

echo "Starting TrainTicket (infra + apps) via docker-compose.build.yml ..."
docker compose -f docker-compose.build.yml up -d "$@"
echo ""
echo "  UI:      http://localhost:${UI_DASHBOARD_PORT:-8080}"
echo "  Gateway: http://localhost:${GATEWAY_SERVICE_PORT:-18888}"
echo "  Nacos:   http://localhost:${NACOS_HTTP_PORT:-8848}/nacos"
echo ""
echo "  docker compose -f docker-compose.build.yml ps"
echo "  docker compose -f docker-compose.build.yml logs -f ts-gateway-service"
