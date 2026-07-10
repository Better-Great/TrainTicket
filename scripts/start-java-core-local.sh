#!/usr/bin/env bash
# Build and run a small set of Java services for local Track B (Nacos + shared MySQL).
# Requires: docker compose minimal (nacos, mysql, redis) and gateway with discovery.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/log/java"
mkdir -p "$LOG" "$ROOT/jar"

# Shared local infra (.env defaults)
export NACOS_ADDRS="${NACOS_ADDRS:-127.0.0.1:8848}"
# Keep lb:// targets on loopback (avoid public NIC IP in Nacos)
export SPRING_CLOUD_NACOS_DISCOVERY_IP="${SPRING_CLOUD_NACOS_DISCOVERY_IP:-127.0.0.1}"
MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3307}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-root}"

# Services: name|module|port|mysql_db|mysql_env_prefix
SERVICES=(
  "ts-auth-service|ts-auth-service|12340|ts-auth-mysql|AUTH"
  "ts-station-service|ts-station-service|12345|ts-station-mysql|STATION"
  "ts-route-service|ts-route-service|11178|ts-route-mysql|ROUTE"
  "ts-train-service|ts-train-service|14567|ts-train-mysql|TRAIN"
  "ts-config-service|ts-config-service|15679|ts-config-mysql|CONFIG"
  "ts-wait-order-service|ts-wait-order-service|17525|ts-wait-order-mysql|WAIT_ORDER"
  "ts-food-delivery-service|ts-food-delivery-service|18957|ts-food-delivery-mysql|FOOD_DELIVERY"
)

ensure_dbs() {
  docker exec trainticket-mysql mysql -uroot -proot -e "
    CREATE DATABASE IF NOT EXISTS \`ts-config-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-wait-order-mysql\` CHARACTER SET utf8mb4;
    CREATE DATABASE IF NOT EXISTS \`ts-food-delivery-mysql\` CHARACTER SET utf8mb4;
    DROP TABLE IF EXISTS \`ts-config-mysql\`.\`config\`;
  " 2>/dev/null || true
}

build_modules() {
  local mods=()
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r _name mod _port _db _pfx <<<"$entry"
    mods+=("$mod")
  done
  echo "=== Building: ${mods[*]} ==="
  (cd "$ROOT" && mvn -pl "$(IFS=,; echo "${mods[*]}")" -am -DskipTests package -q)
}

start_one() {
  local name="$1" mod="$2" port="$3" db="$4" pfx="$5"
  local jar="$ROOT/$mod/target/${name}-1.0.jar"
  # artifact names vary
  if [[ ! -f "$jar" ]]; then
    jar=$(ls "$ROOT/$mod/target/"*-1.0.jar 2>/dev/null | grep -v original | head -1 || true)
  fi
  if [[ -z "${jar:-}" || ! -f "$jar" ]]; then
    echo "SKIP $name — jar not found" >&2
    return 1
  fi
  cp -f "$jar" "$ROOT/jar/$(basename "$jar")"

  if curl -sf --max-time 1 "http://127.0.0.1:${port}/" >/dev/null 2>&1 \
    || ss -tln | grep -q ":${port} "; then
    echo "$name already up on :$port"
    return 0
  fi

  local host_var="${pfx}_MYSQL_HOST"
  local port_var="${pfx}_MYSQL_PORT"
  local db_var="${pfx}_MYSQL_DATABASE"
  local user_var="${pfx}_MYSQL_USER"
  local pass_var="${pfx}_MYSQL_PASSWORD"

  echo "Starting $name on :$port → mysql $db"
  (
    export NACOS_ADDRS
    export SPRING_CLOUD_NACOS_DISCOVERY_IP
    export "$host_var=$MYSQL_HOST"
    export "$port_var=$MYSQL_PORT"
    export "$db_var=$db"
    export "$user_var=$MYSQL_USER"
    export "$pass_var=$MYSQL_PASSWORD"
    java -Xms48m -Xmx192m -jar "$jar" >"$LOG/${name}.log" 2>&1
  ) &
  echo $! >"$LOG/${name}.pid"
}

ensure_dbs

if [[ "${1:-}" == "--build" ]] || [[ ! -f "$ROOT/ts-auth-service/target/ts-auth-service-1.0.jar" ]]; then
  build_modules
fi

# Only start missing services unless --all
ONLY_MISSING=1
[[ "${1:-}" == "--all" || "${2:-}" == "--all" ]] && ONLY_MISSING=0

for entry in "${SERVICES[@]}"; do
  IFS='|' read -r name mod port db pfx <<<"$entry"
  if [[ "$ONLY_MISSING" == "1" ]] && ss -tln | grep -q ":${port} "; then
    echo "$name already up on :$port"
    continue
  fi
  start_one "$name" "$mod" "$port" "$db" "$pfx" || true
done

echo ""
echo "Waiting for listeners (Spring Boot + Nacos ~60–90s)..."
for i in $(seq 1 90); do
  up=0
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r _name _mod port _db _pfx <<<"$entry"
    ss -tln | grep -q ":${port} " && ((up++)) || true
  done
  [[ "$up" -ge 6 ]] && break
  sleep 1
done
for entry in "${SERVICES[@]}"; do
  IFS='|' read -r name _mod port _db _pfx <<<"$entry"
  printf "  %-28s " "$name:$port"
  if ss -tln | grep -q ":${port} "; then
    echo UP
  else
    echo DOWN
    grep -E 'APPLICATION FAILED|Caused by:' "$LOG/${name}.log" 2>/dev/null | tail -3 || true
  fi
done

echo ""
echo "Nacos: http://127.0.0.1:8848/nacos  (nacos/nacos)"
echo "Gateway+discovery: ./scripts/start-gateway-local.sh --with-nacos"
echo "Smoke: ./scripts/smoke-java-core.sh && ./scripts/smoke-test-routes.sh"
