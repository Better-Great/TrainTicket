#!/usr/bin/env bash
# Manage the optional local SonarQube stack and run a complete quality scan.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT/docker-compose.quality.yml"
START_TIMEOUT="${SONAR_START_TIMEOUT:-600}"
command_name="${1:-scan}"

cd "$ROOT"

if [[ -f "$ROOT/.env" ]]; then
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^SONAR_[A-Z0-9_]+$ ]] || continue
    [[ -z "${!key:-}" ]] || continue
    value="${value%$'\r'}"
    value="${value#\"}"
    value="${value%\"}"
    printf -v "$key" '%s' "$value"
    export "$key"
  done < "$ROOT/.env"
fi

command -v docker >/dev/null 2>&1 || {
  echo "docker is required." >&2
  exit 1
}
docker compose version >/dev/null

compose=(docker compose -f "$COMPOSE_FILE")

usage() {
  echo "Usage: $0 {up|scan|down|purge}" >&2
}

require_database_password() {
  : "${SONAR_DB_PASSWORD:?Set SONAR_DB_PASSWORD in .env or export it}"
  export SONAR_DB_PASSWORD
}

check_kernel_limit() {
  if [[ "$(sysctl -n vm.max_map_count)" -lt 524288 ]]; then
    echo "vm.max_map_count must be at least 524288." >&2
    echo "Run: sudo sysctl -w vm.max_map_count=524288" >&2
    exit 1
  fi
}

wait_for_sonarqube() {
  local container health deadline
  container="$("${compose[@]}" ps -q sonarqube)"
  if [[ -z "$container" ]]; then
    echo "SonarQube container was not created." >&2
    exit 1
  fi

  deadline=$((SECONDS + START_TIMEOUT))
  while (( SECONDS < deadline )); do
    health="$(docker inspect --format \
      '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' \
      "$container")"
    case "$health" in
      healthy)
        return
        ;;
      unhealthy|exited|dead)
        "${compose[@]}" logs --tail=100 sonarqube postgres >&2 || true
        echo "SonarQube entered state: $health" >&2
        exit 1
        ;;
    esac
    sleep 10
  done

  echo "SonarQube did not become healthy within ${START_TIMEOUT}s." >&2
  exit 1
}

start_stack() {
  require_database_password
  check_kernel_limit
  "${compose[@]}" up -d postgres sonarqube
  wait_for_sonarqube
  echo "SonarQube is ready at http://localhost:${SONAR_PORT:-9000}"
}

case "$command_name" in
  up)
    start_stack
    ;;
  scan)
    require_database_password
    : "${SONAR_TOKEN:?Export a SonarQube project token as SONAR_TOKEN}"
    export SONAR_TOKEN
    command -v mvn >/dev/null 2>&1 || {
      echo "mvn is required to test the Java modules." >&2
      exit 1
    }
    command -v bun >/dev/null 2>&1 || {
      echo "bun is required to test ts-ui-web." >&2
      exit 1
    }
    command -v go >/dev/null 2>&1 || {
      echo "go is required to test ts-news-service." >&2
      exit 1
    }

    echo "=== Verifying Java modules and JaCoCo XML ==="
    mvn -B -ntp verify

    echo "=== Verifying TypeScript UI and LCOV ==="
    (
      cd ts-ui-web
      bun install --frozen-lockfile
      bun run check
      bun run test:coverage
    )

    echo "=== Testing Go service ==="
    (cd ts-news-service && go test ./...)

    start_stack
    echo "=== Running scanner and waiting for the quality gate ==="
    "${compose[@]}" --profile scan run --rm sonar-scanner
    ;;
  down)
    require_database_password
    "${compose[@]}" down
    ;;
  purge)
    require_database_password
    "${compose[@]}" down --volumes --remove-orphans
    ;;
  *)
    usage
    exit 2
    ;;
esac
