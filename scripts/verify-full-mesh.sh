#!/usr/bin/env bash
# Verify every service in docker-compose.build.yml actually boots, connects to
# MySQL/Nacos over the docker network, and (for Spring Cloud services) registers
# in Nacos — proof the network works, without needing all ~42 containers up at
# once (this host can't hold that much RAM simultaneously; see ai-docs session
# notes on the ~8GiB ceiling). Brings services up in small batches, checks each,
# then stops the batch before starting the next.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BATCH_SIZE="${BATCH_SIZE:-4}"
RESULTS_FILE="${RESULTS_FILE:-/tmp/verify-full-mesh-results.txt}"
: > "$RESULTS_FILE"

# Skip services already up and previously verified (lean core).
ALREADY_UP=(ts-user-service ts-seat-service ts-verification-code-service \
  ts-gateway-service ts-basic-service ts-ui-dashboard ts-voucher-service ts-news-service)

# Services that don't register in Nacos (non-Spring-Cloud stacks).
is_nacos_service() {
  case "$1" in
    ts-avatar-service|ts-voucher-service|ts-ticket-office-service|ts-news-service|\
    ts-ui-dashboard|ts-delivery-service|ts-train-food-service|ts-food-delivery-service)
      return 1 ;;
    *) return 0 ;;
  esac
}

mapfile -t ALL_SERVICES < <(docker compose -f docker-compose.build.yml config --services | grep '^ts-')

REMAINING=()
for s in "${ALL_SERVICES[@]}"; do
  skip=false
  for u in "${ALREADY_UP[@]}"; do
    [[ "$s" == "$u" ]] && skip=true && break
  done
  $skip || REMAINING+=("$s")
done

echo "Already verified/running (skipped): ${ALREADY_UP[*]}"
echo "Remaining to verify: ${#REMAINING[@]} services"
echo ""

for ((i = 0; i < ${#REMAINING[@]}; i += BATCH_SIZE)); do
  batch=("${REMAINING[@]:i:BATCH_SIZE}")
  echo "=== Batch $((i / BATCH_SIZE + 1)): ${batch[*]} ==="
  docker compose -f docker-compose.build.yml up -d "${batch[@]}"

  declare -A status
  for s in "${batch[@]}"; do status[$s]="pending"; done

  deadline=$((SECONDS + 150))
  while ((SECONDS < deadline)); do
    all_done=true
    for s in "${batch[@]}"; do
      [[ "${status[$s]}" == "pending" ]] || continue
      h=$(docker inspect --format='{{.State.Health.Status}}' "$s" 2>/dev/null || echo "none")
      case "$h" in
        healthy) status[$s]="healthy" ;;
        unhealthy) status[$s]="unhealthy" ;;
        *) all_done=false ;;
      esac
    done
    $all_done && break
    sleep 5
  done

  for s in "${batch[@]}"; do
    nacos_check="n/a"
    if [[ "${status[$s]}" == "healthy" ]] && is_nacos_service "$s"; then
      if curl -s "http://localhost:${NACOS_HTTP_PORT:-8848}/nacos/v1/ns/service/list?pageNo=1&pageSize=100" \
        | grep -q "\"$s\""; then
        nacos_check="registered"
      else
        nacos_check="NOT-registered"
      fi
    fi
    echo "$s: ${status[$s]:-timeout} nacos=$nacos_check" | tee -a "$RESULTS_FILE"
  done

  echo "--- stopping batch to free memory ---"
  docker compose -f docker-compose.build.yml stop "${batch[@]}"
  free -h | sed -n 2p
  echo ""
done

echo "=== FULL SUMMARY ==="
cat "$RESULTS_FILE"
echo ""
FAILS=$(grep -Ec "unhealthy|timeout|NOT-registered" "$RESULTS_FILE" || true)
echo "Failures: $FAILS / $(wc -l < "$RESULTS_FILE")"
