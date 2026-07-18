#!/usr/bin/env bash
# Start a dense booking-path stack on a small host (~8GiB).
# Skips kafka/zipkin (compose profile full-infra) and admin/peripheral services.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Copy .env.example to .env first." >&2
  exit 1
fi

# Shared lean JVM for Java app containers (override per-service in compose if needed).
# Metaspace ceiling sized for Spring Boot 3 / Jakarta EE — see .env.example.
export JAVA_OPTS="${JAVA_OPTS:--Xms32m -Xmx128m -Xss256k -XX:MetaspaceSize=80m -XX:MaxMetaspaceSize=160m -XX:+UseSerialGC -XX:+ExitOnOutOfMemoryError -Dcsp.sentinel.log.dir=/tmp/csp}"

CORE=(
  ts-gateway-service
  ts-auth-service
  ts-verification-code-service
  ts-station-service
  ts-route-service
  ts-train-service
  ts-config-service
  ts-travel-service
  ts-basic-service
  ts-price-service
  ts-seat-service
  ts-order-service
  ts-preserve-service
  ts-payment-service
  ts-inside-payment-service
  ts-user-service
  ts-contacts-service
  ts-security-service
  ts-assurance-service
  ts-news-service
  ts-voucher-service
  ts-ui-dashboard
)

echo "=== Lean infra (no kafka/zipkin) ==="
docker compose -f docker-compose.minimal.yml up -d nacos mysql redis rabbitmq

echo "=== Core apps (${#CORE[@]} services) ==="
docker compose -f docker-compose.build.yml up -d "${CORE[@]}"

echo ""
free -h | head -2
echo ""
docker compose -f docker-compose.build.yml ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null \
  || docker compose -f docker-compose.build.yml ps
echo ""
echo "  UI:      http://localhost:${UI_DASHBOARD_PORT:-8080}"
echo "  Gateway: http://localhost:${GATEWAY_SERVICE_PORT:-18888}"
echo "  Nacos:   http://localhost:${NACOS_HTTP_PORT:-8848}/nacos"
echo ""
echo "Optional heavy infra: docker compose -f docker-compose.minimal.yml --profile full-infra up -d"
echo "All apps:            ./scripts/up-docker.sh"
