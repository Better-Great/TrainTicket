#!/usr/bin/env bash
# Build and run preserve + payment + inside-payment for local booking path.
# Requires: nacos, mysql :3307, rabbitmq, and preferably travel/basic/seat already up.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/log/java"
mkdir -p "$LOG" "$ROOT/jar"

export NACOS_ADDRS="${NACOS_ADDRS:-127.0.0.1:8848}"
export SPRING_CLOUD_NACOS_DISCOVERY_IP="${SPRING_CLOUD_NACOS_DISCOVERY_IP:-127.0.0.1}"
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3307}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-root}"

SERVICES=(
  "ts-payment-service|ts-payment-service|19001|ts-payment-mysql|PAYMENT"
  "ts-inside-payment-service|ts-inside-payment-service|18673|ts-inside-payment-mysql|INSIDE_PAYMENT"
  "ts-preserve-service|ts-preserve-service|14568|-|PRESERVE"
)

ensure_infra() {
  echo "Waiting for Nacos..."
  for i in $(seq 1 30); do
    if curl -sf --max-time 2 -o /dev/null "http://127.0.0.1:8848/nacos/" 2>/dev/null; then
      echo "Nacos ready"
      break
    fi
    sleep 2
  done

  if ! ss -tln | grep -q ':5672 '; then
    echo "Starting rabbitmq..."
    (cd "$ROOT" && docker compose -f docker-compose.minimal.yml up -d rabbitmq)
    for i in $(seq 1 40); do
      ss -tln | grep -q ':5672 ' && break
      sleep 2
    done
  fi
  echo "RabbitMQ: $(ss -tln | grep -q ':5672 ' && echo UP || echo DOWN)"

  docker exec trainticket-mysql mysql -uroot -proot -e "
    CREATE DATABASE IF NOT EXISTS \`ts-payment-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-inside-payment-mysql\` CHARACTER SET utf8mb4;
  " 2>/dev/null || true
}

build_modules() {
  echo "=== Building preserve + payment + inside-payment ==="
  (cd "$ROOT" && mvn -pl ts-common,ts-preserve-service,ts-payment-service,ts-inside-payment-service -am -DskipTests package -q)
}

start_one() {
  local name="$1" mod="$2" port="$3" db="$4" pfx="$5"
  local jar="$ROOT/$mod/target/${name}-1.0.jar"
  if [[ ! -f "$jar" ]]; then
    jar=$(ls "$ROOT/$mod/target/"*-1.0.jar 2>/dev/null | grep -v original | head -1 || true)
  fi
  if [[ -z "${jar:-}" || ! -f "$jar" ]]; then
    echo "SKIP $name — jar not found" >&2
    return 1
  fi
  cp -f "$jar" "$ROOT/jar/$(basename "$jar")"

  if ss -tln | grep -q ":${port} "; then
    echo "$name already up on :$port"
    return 0
  fi

  echo "Starting $name on :$port"
  (
    export NACOS_ADDRS SPRING_CLOUD_NACOS_DISCOVERY_IP
    export RABBITMQ_HOST=127.0.0.1 RABBITMQ_PORT=5672
    if [[ "$db" != "-" ]]; then
      export "${pfx}_MYSQL_HOST=$MYSQL_HOST"
      export "${pfx}_MYSQL_PORT=$MYSQL_PORT"
      export "${pfx}_MYSQL_DATABASE=$db"
      export "${pfx}_MYSQL_USER=$MYSQL_USER"
      export "${pfx}_MYSQL_PASSWORD=$MYSQL_PASSWORD"
    fi
    java -Xms48m -Xmx160m -jar "$jar" >"$LOG/${name}.log" 2>&1
  ) &
  echo $! >"$LOG/${name}.pid"
}

ensure_infra

if [[ "${1:-}" == "--build" ]] || [[ ! -f "$ROOT/ts-preserve-service/target/ts-preserve-service-1.0.jar" ]]; then
  build_modules
fi

for entry in "${SERVICES[@]}"; do
  IFS='|' read -r name mod port db pfx <<<"$entry"
  start_one "$name" "$mod" "$port" "$db" "$pfx" || true
done

echo ""
echo "Waiting for booking listeners..."
for i in $(seq 1 90); do
  up=0
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r _name _mod port _db _pfx <<<"$entry"
    ss -tln | grep -q ":${port} " && ((up++)) || true
  done
  [[ "$up" -eq 3 ]] && break
  sleep 1
done

for entry in "${SERVICES[@]}"; do
  IFS='|' read -r name _mod port _db _pfx <<<"$entry"
  printf "  %-32s " "$name:$port"
  if ss -tln | grep -q ":${port} "; then
    echo UP
  else
    echo DOWN
    grep -E 'APPLICATION FAILED|Caused by:' "$LOG/${name}.log" 2>/dev/null | tail -3 || true
  fi
done

echo ""
echo "Restart gateway to pick up booking URIs: GATEWAY_RESTART=1 ./scripts/start-gateway-local.sh"
echo "Smoke: ./scripts/smoke-booking.sh"
