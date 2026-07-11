#!/usr/bin/env bash
# Lean auth + identity peers for preserve E2E (auth, verify, user, contacts, security, assurance).
# Requires: docker compose minimal (nacos, mysql). Assurance uses :18887 locally (gateway owns :18888).
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

# Preserve east-west (service-name defaults in jars)
export ASSURANCE_SERVICE_HOST="${ASSURANCE_SERVICE_HOST:-127.0.0.1}"
export ASSURANCE_SERVICE_PORT="${ASSURANCE_SERVICE_PORT:-18887}"
export SECURITY_SERVICE_HOST="${SECURITY_SERVICE_HOST:-127.0.0.1}"
export USER_SERVICE_HOST="${USER_SERVICE_HOST:-127.0.0.1}"
export CONTACTS_SERVICE_HOST="${CONTACTS_SERVICE_HOST:-127.0.0.1}"

SERVICES=(
  "ts-auth-service|ts-auth-service|12340|ts-auth-mysql|AUTH|"
  "ts-verification-code-service|ts-verification-code-service|15678|-|VERIFY|"
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
  docker exec trainticket-mysql mysql -uroot -proot -e "
    CREATE DATABASE IF NOT EXISTS \`ts-auth-mysql\` CHARACTER SET utf8mb4;
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
  echo "=== Building auth path: ${mods[*]} ==="
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
    export ASSURANCE_SERVICE_HOST ASSURANCE_SERVICE_PORT SECURITY_SERVICE_HOST
    export USER_SERVICE_HOST CONTACTS_SERVICE_HOST
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

for entry in "${SERVICES[@]}"; do
  IFS='|' read -r name mod port db pfx extra <<<"$entry"
  start_one "$name" "$mod" "$port" "$db" "$pfx" "$extra" || true
done

echo ""
echo "Waiting for auth-path listeners..."
for i in $(seq 1 90); do
  up=0
  for entry in "${SERVICES[@]}"; do
    IFS='|' read -r _name _mod port _db _pfx _extra <<<"$entry"
    ss -tln | grep -q ":${port} " && ((up++)) || true
  done
  [[ "$up" -ge 4 ]] && break
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
echo "Also set for preserve: ASSURANCE_SERVICE_PORT=18887"
echo "Gateway: GATEWAY_RESTART=1 ./scripts/start-gateway-local.sh"
echo "Smoke: ./scripts/smoke-preserve-e2e.sh"
