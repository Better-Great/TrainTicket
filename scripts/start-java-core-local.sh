#!/usr/bin/env bash
# Build and run local Stage B/C Java services (search + booking + auth path).
# Requires: docker compose -f docker-compose.minimal.yml up -d  (nacos, mysql, redis, rabbitmq)
# Then: ./scripts/start-gateway-local.sh && ./scripts/smoke-java-core.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/log/java"
mkdir -p "$LOG" "$ROOT/jar"

export NACOS_ADDRS="${NACOS_ADDRS:-127.0.0.1:8848}"
export SPRING_CLOUD_NACOS_DISCOVERY_IP="${SPRING_CLOUD_NACOS_DISCOVERY_IP:-127.0.0.1}"
export JWT_SECRET="${JWT_SECRET:-change-me-local-dev-only}"
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3307}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-root}"

# East-west peers: jar defaults are K8s service DNS; pin loopback for laptop
export STATION_SERVICE_HOST="${STATION_SERVICE_HOST:-127.0.0.1}"
export TRAIN_SERVICE_HOST="${TRAIN_SERVICE_HOST:-127.0.0.1}"
export ROUTE_SERVICE_HOST="${ROUTE_SERVICE_HOST:-127.0.0.1}"
export PRICE_SERVICE_HOST="${PRICE_SERVICE_HOST:-127.0.0.1}"
export BASIC_SERVICE_HOST="${BASIC_SERVICE_HOST:-127.0.0.1}"
export SEAT_SERVICE_HOST="${SEAT_SERVICE_HOST:-127.0.0.1}"
export ORDER_SERVICE_HOST="${ORDER_SERVICE_HOST:-127.0.0.1}"
export ORDER_OTHER_SERVICE_HOST="${ORDER_OTHER_SERVICE_HOST:-127.0.0.1}"
export CONFIG_SERVICE_HOST="${CONFIG_SERVICE_HOST:-127.0.0.1}"
export TRAVEL_SERVICE_HOST="${TRAVEL_SERVICE_HOST:-127.0.0.1}"
export USER_SERVICE_HOST="${USER_SERVICE_HOST:-127.0.0.1}"
export CONTACTS_SERVICE_HOST="${CONTACTS_SERVICE_HOST:-127.0.0.1}"
export SECURITY_SERVICE_HOST="${SECURITY_SERVICE_HOST:-127.0.0.1}"
export ASSURANCE_SERVICE_HOST="${ASSURANCE_SERVICE_HOST:-127.0.0.1}"
export ASSURANCE_SERVICE_PORT="${ASSURANCE_SERVICE_PORT:-18887}"
export PAYMENT_SERVICE_HOST="${PAYMENT_SERVICE_HOST:-127.0.0.1}"
export FOOD_SERVICE_HOST="${FOOD_SERVICE_HOST:-127.0.0.1}"
export CONSIGN_SERVICE_HOST="${CONSIGN_SERVICE_HOST:-127.0.0.1}"
export RABBITMQ_HOST="${RABBITMQ_HOST:-127.0.0.1}"
export RABBITMQ_PORT="${RABBITMQ_PORT:-5672}"

# name|module|port|mysql_db|mysql_env_prefix|extra_java_args
SERVICES=(
  "ts-auth-service|ts-auth-service|12340|ts-auth-mysql|AUTH|"
  "ts-verification-code-service|ts-verification-code-service|15678|-|VERIFY|"
  "ts-station-service|ts-station-service|12345|ts-station-mysql|STATION|"
  "ts-route-service|ts-route-service|11178|ts-route-mysql|ROUTE|"
  "ts-train-service|ts-train-service|14567|ts-train-mysql|TRAIN|"
  "ts-config-service|ts-config-service|15679|ts-config-mysql|CONFIG|"
  "ts-order-service|ts-order-service|12031|ts-order-mysql|ORDER|"
  "ts-travel-service|ts-travel-service|12346|ts-travel-mysql|TRAVEL|"
  "ts-basic-service|ts-basic-service|15680|-|BASIC|"
  "ts-price-service|ts-price-service|16579|ts-price-mysql|PRICE|"
  "ts-seat-service|ts-seat-service|18898|-|SEAT|"
  "ts-payment-service|ts-payment-service|19001|ts-payment-mysql|PAYMENT|"
  "ts-inside-payment-service|ts-inside-payment-service|18673|ts-inside-payment-mysql|INSIDE_PAYMENT|"
  "ts-preserve-service|ts-preserve-service|14568|-|PRESERVE|"
  "ts-user-service|ts-user-service|12342|ts-user-mysql|USER|"
  "ts-contacts-service|ts-contacts-service|12347|ts-contacts-mysql|CONTACTS|"
  "ts-security-service|ts-security-service|11188|ts-security-mysql|SECURITY|"
  "ts-assurance-service|ts-assurance-service|18887|ts-assurance-mysql|ASSURANCE|--server.port=18887"
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
    echo "Starting rabbitmq (preserve needs it)..."
    (cd "$ROOT" && docker compose -f docker-compose.minimal.yml up -d rabbitmq) || true
    for i in $(seq 1 40); do
      ss -tln | grep -q ':5672 ' && break
      sleep 2
    done
  fi

  docker exec trainticket-mysql mysql -uroot -proot -e "
    CREATE DATABASE IF NOT EXISTS \`ts-auth-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-config-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-order-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-travel-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-price-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-payment-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-inside-payment-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-user-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-contacts-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-security-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-assurance-mysql\` CHARACTER SET utf8mb4;
  " 2>/dev/null || true
}

build_modules() {
  local mods=()
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r _name mod _port _db _pfx _extra <<<"$entry"
    mods+=("$mod")
  done
  echo "=== Building: ${mods[*]} ==="
  (cd "$ROOT" && mvn -pl "$(IFS=,; echo "${mods[*]}")" -am -DskipTests package -q)
}

start_one() {
  local name="$1" mod="$2" port="$3" db="$4" pfx="$5" extra="${6:-}"
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
    export NACOS_ADDRS SPRING_CLOUD_NACOS_DISCOVERY_IP JWT_SECRET
    export STATION_SERVICE_HOST TRAIN_SERVICE_HOST ROUTE_SERVICE_HOST PRICE_SERVICE_HOST
    export BASIC_SERVICE_HOST SEAT_SERVICE_HOST ORDER_SERVICE_HOST ORDER_OTHER_SERVICE_HOST
    export CONFIG_SERVICE_HOST TRAVEL_SERVICE_HOST USER_SERVICE_HOST CONTACTS_SERVICE_HOST
    export SECURITY_SERVICE_HOST ASSURANCE_SERVICE_HOST ASSURANCE_SERVICE_PORT
    export PAYMENT_SERVICE_HOST FOOD_SERVICE_HOST CONSIGN_SERVICE_HOST
    export RABBITMQ_HOST RABBITMQ_PORT
    if [[ "$db" != "-" ]]; then
      export "${pfx}_MYSQL_HOST=$MYSQL_HOST"
      export "${pfx}_MYSQL_PORT=$MYSQL_PORT"
      export "${pfx}_MYSQL_DATABASE=$db"
      export "${pfx}_MYSQL_USER=$MYSQL_USER"
      export "${pfx}_MYSQL_PASSWORD=$MYSQL_PASSWORD"
    fi
    # shellcheck disable=SC2086
    java -Xms48m -Xmx160m -jar "$jar" $extra >"$LOG/${name}.log" 2>&1
  ) &
  echo $! >"$LOG/${name}.pid"
}

ensure_infra

if [[ "${1:-}" == "--build" ]] || [[ ! -f "$ROOT/ts-auth-service/target/ts-auth-service-1.0.jar" ]]; then
  build_modules
fi

ONLY_MISSING=1
[[ "${1:-}" == "--all" || "${2:-}" == "--all" ]] && ONLY_MISSING=0

for entry in "${SERVICES[@]}"; do
  IFS='|' read -r name mod port db pfx extra <<<"$entry"
  if [[ "$ONLY_MISSING" == "1" ]] && ss -tln | grep -q ":${port} "; then
    echo "$name already up on :$port"
    continue
  fi
  start_one "$name" "$mod" "$port" "$db" "$pfx" "$extra" || true
done

echo ""
echo "Waiting for listeners..."
for i in $(seq 1 120); do
  up=0
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r _name _mod port _db _pfx _extra <<<"$entry"
    ss -tln | grep -q ":${port} " && ((up++)) || true
  done
  [[ "$up" -ge 10 ]] && break
  sleep 1
done

for entry in "${SERVICES[@]}"; do
  IFS='|' read -r name _mod port _db _pfx _extra <<<"$entry"
  printf "  %-36s " "$name:$port"
  if ss -tln | grep -q ":${port} "; then
    echo UP
  else
    echo DOWN
    grep -E 'APPLICATION FAILED|Caused by:' "$LOG/${name}.log" 2>/dev/null | tail -3 || true
  fi
done

echo ""
echo "Gateway: GATEWAY_RESTART=1 ./scripts/start-gateway-local.sh"
echo "Smoke:   ./scripts/smoke-java-core.sh"
