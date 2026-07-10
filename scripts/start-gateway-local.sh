#!/usr/bin/env bash
# Build (if needed) and run ts-gateway-service with the local profile.
# Polyglot backends should already be up (./scripts/start-polyglot-local.sh).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/log/gateway"
mkdir -p "$LOG" "$ROOT/jar"

JAR="$ROOT/jar/ts-gateway-service-1.0.jar"
BUILT="$ROOT/ts-gateway-service/target/ts-gateway-service-1.0.jar"

if [[ ! -f "$JAR" && ! -f "$BUILT" ]]; then
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

WITH_NACOS=false
if [[ "${1:-}" == "--with-nacos" ]] || [[ "${GATEWAY_NACOS:-}" == "1" ]]; then
  WITH_NACOS=true
fi

if curl -sf --max-time 1 -o /dev/null http://127.0.0.1:18888/api/v1/newsservice/ 2>/dev/null; then
  if [[ "$WITH_NACOS" == "true" ]]; then
    echo "Restarting gateway with Nacos discovery..."
    if [[ -f "$LOG/gateway.pid" ]]; then kill "$(cat "$LOG/gateway.pid")" 2>/dev/null || true; fi
    pkill -f 'ts-gateway-service-1.0.jar' 2>/dev/null || true
    sleep 2
  else
    echo "gateway already responding on :18888"
    exit 0
  fi
fi

echo "=== Starting gateway (profile=local, nacos=$WITH_NACOS) ==="
(
  cd "$ROOT"
  export NEWS_SERVICE_HOST=127.0.0.1
  export NEWS_SERVICE_PORT=12862
  export TICKET_OFFICE_SERVICE_HOST=127.0.0.1
  export TICKET_OFFICE_SERVICE_PORT=16108
  export VOUCHER_SERVICE_HOST=127.0.0.1
  export VOUCHER_SERVICE_PORT=16101
  export NACOS_ADDRS="${NACOS_ADDRS:-127.0.0.1:8848}"
  export GATEWAY_NACOS="$WITH_NACOS"
  java -Xms128m -Xmx384m \
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
