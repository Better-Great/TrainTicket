#!/usr/bin/env bash
# Build (if needed) and run ts-gateway-service with the local profile.
# Polyglot backends should already be up (./scripts/start-polyglot-local.sh).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/log/gateway"
mkdir -p "$LOG" "$ROOT/jar"

JAR="$ROOT/jar/ts-gateway-service-1.0.jar"
BUILT="$ROOT/ts-gateway-service/target/ts-gateway-service-1.0.jar"

FORCE_REBUILD=false
WITH_NACOS=false
for arg in "$@"; do
  case "$arg" in
    --with-nacos) WITH_NACOS=true ;;
    --rebuild) FORCE_REBUILD=true ;;
  esac
done
[[ "${GATEWAY_NACOS:-}" == "1" ]] && WITH_NACOS=true

if [[ "$FORCE_REBUILD" == "true" ]] || [[ ! -f "$JAR" && ! -f "$BUILT" ]]; then
  echo "=== Building ts-common + ts-gateway-service ==="
  (cd "$ROOT" && mvn -pl ts-common,ts-gateway-service -am -DskipTests package -q)
fi

if [[ -f "$BUILT" ]]; then
  cp -f "$BUILT" "$JAR"
fi

if [[ ! -f "$JAR" ]]; then
  echo "Gateway jar missing at $JAR" >&2
  exit 1
fi

# Always restart when --rebuild or --with-nacos; else skip if healthy
if curl -sf --max-time 1 -o /dev/null http://127.0.0.1:18888/api/v1/newsservice/ 2>/dev/null; then
  if [[ "$WITH_NACOS" == "true" || "$FORCE_REBUILD" == "true" || "${GATEWAY_RESTART:-}" == "1" ]]; then
    echo "Restarting gateway..."
    if [[ -f "$LOG/gateway.pid" ]]; then kill "$(cat "$LOG/gateway.pid")" 2>/dev/null || true; fi
    pkill -f 'ts-gateway-service-1.0.jar' 2>/dev/null || true
    sleep 2
  else
    echo "gateway already responding on :18888"
    exit 0
  fi
fi

echo "=== Starting gateway (profile=local, nacos=$WITH_NACOS, http-direct local URIs) ==="
(
  cd "$ROOT"
  export NEWS_SERVICE_HOST=127.0.0.1 NEWS_SERVICE_PORT=12862
  export TICKET_OFFICE_SERVICE_HOST=127.0.0.1 TICKET_OFFICE_SERVICE_PORT=16108
  export VOUCHER_SERVICE_HOST=127.0.0.1 VOUCHER_SERVICE_PORT=16101
  # Bypass Nacos lb:// for core local services (works even if Nacos flaps)
  export STATION_SERVICE_URI=http://127.0.0.1:12345
  export ROUTE_SERVICE_URI=http://127.0.0.1:11178
  export TRAIN_SERVICE_URI=http://127.0.0.1:14567
  export CONFIG_SERVICE_URI=http://127.0.0.1:15679
  export VERIFICATION_CODE_SERVICE_URI=http://127.0.0.1:15678
  export WAIT_ORDER_SERVICE_URI=http://127.0.0.1:17525
  export FOOD_DELIVERY_SERVICE_URI=http://127.0.0.1:18957
  export ORDER_SERVICE_URI=http://127.0.0.1:12031
  export TRAVEL_SERVICE_URI=http://127.0.0.1:12346
  export AUTH_SERVICE_URI=http://127.0.0.1:12340
  export BASIC_SERVICE_URI=http://127.0.0.1:15680
  export PRICE_SERVICE_URI=http://127.0.0.1:16579
  export SEAT_SERVICE_URI=http://127.0.0.1:18898
  export PRESERVE_SERVICE_URI=http://127.0.0.1:14568
  export PAYMENT_SERVICE_URI=http://127.0.0.1:19001
  export INSIDE_PAYMENT_SERVICE_URI=http://127.0.0.1:18673
  export USER_SERVICE_URI=http://127.0.0.1:12342
  export CONTACTS_SERVICE_URI=http://127.0.0.1:12347
  export NACOS_ADDRS="${NACOS_ADDRS:-127.0.0.1:8848}"
  export GATEWAY_NACOS="$WITH_NACOS"
  export JWT_SECRET="${JWT_SECRET:-change-me-local-dev-only}"
  export GATEWAY_JWT_ENABLED="${GATEWAY_JWT_ENABLED:-true}"
  export GATEWAY_JWT_PROTECTED_PREFIXES="${GATEWAY_JWT_PROTECTED_PREFIXES:-/api/v1/admin,/api/v1/preserveservice,/api/v1/paymentservice,/api/v1/inside_pay_service}"
  java -Xms96m -Xmx256m \
    -jar "$JAR" \
    --spring.profiles.active=local \
    >"$LOG/gateway.log" 2>&1
) &
echo $! >"$LOG/gateway.pid"
echo "gateway pid $(cat "$LOG/gateway.pid") — log $LOG/gateway.log"

for i in $(seq 1 60); do
  if curl -sf --max-time 1 -o /dev/null http://127.0.0.1:18888/api/v1/newsservice/ 2>/dev/null \
    || grep -q "Started GatewayApplication" "$LOG/gateway.log" 2>/dev/null; then
    echo "gateway ready"
    exit 0
  fi
  sleep 1
done

echo "gateway did not become ready in 60s — last log:" >&2
tail -40 "$LOG/gateway.log" >&2
exit 1
