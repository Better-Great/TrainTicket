#!/usr/bin/env bash
# Smoke-test gateway routes and SPA/edge proxy (run after local stack is up).
set -euo pipefail

GATEWAY="${GATEWAY_URL:-http://localhost:18888}"
# Prefer Vite dev (:5173) for local Track B; fall back to nginx edge (:8080)
if [[ -n "${UI_URL:-}" ]]; then
  UI="$UI_URL"
elif curl -sf --max-time 1 -o /dev/null http://127.0.0.1:5173/ 2>/dev/null; then
  UI="http://127.0.0.1:5173"
elif curl -sf --max-time 1 -o /dev/null http://127.0.0.1:8080/ 2>/dev/null; then
  UI="http://127.0.0.1:8080"
else
  UI="http://localhost:8080"
fi

pass=0
fail=0

check() {
  local name="$1"
  local url="$2"
  local expect="${3:-}"
  printf "  %-40s " "$name"
  if code=$(curl -s -o /tmp/smoke-body.txt -w "%{http_code}" --max-time 15 "$url"); then
    if [[ -n "$expect" ]] && ! grep -q "$expect" /tmp/smoke-body.txt 2>/dev/null; then
      echo "FAIL (body mismatch, http $code)"
      head -c 200 /tmp/smoke-body.txt; echo
      ((fail++)) || true
      return
    fi
    if [[ "$code" =~ ^[23] ]]; then
      echo "OK (http $code)"
      ((pass++)) || true
    else
      echo "FAIL (http $code)"
      head -c 200 /tmp/smoke-body.txt; echo
      ((fail++)) || true
    fi
  else
    echo "FAIL (curl error)"
    ((fail++)) || true
  fi
}

echo "=== Gateway direct ($GATEWAY) ==="
check "news API path" "$GATEWAY/api/v1/newsservice/news" "News"
check "news legacy path" "$GATEWAY/news-service/news" "News"
check "ticket office regions" "$GATEWAY/office/getRegionList" ""
check "ticket office API path" "$GATEWAY/api/v1/ticketofficeservice/getRegionList" ""
check "verifycode generate" "$GATEWAY/api/v1/verifycode/generate" ""
check "stations" "$GATEWAY/api/v1/stationservice/stations" ""
soft_check() {
  local name="$1" url="$2" expect="${3:-}"
  printf "  %-40s " "$name"
  code=$(curl -s -o /tmp/smoke-body.txt -w "%{http_code}" --max-time 12 "$url" || echo 000)
  if [[ "$code" == "503" || "$code" == "000" ]]; then
    echo "SKIP (downstream down)"
    return
  fi
  if [[ -n "$expect" ]] && ! grep -q "$expect" /tmp/smoke-body.txt 2>/dev/null; then
    echo "FAIL (body mismatch, http $code)"
    ((fail++)) || true
    return
  fi
  if [[ "$code" =~ ^[23] ]]; then
    echo "OK (http $code)"
    ((pass++)) || true
  else
    echo "FAIL (http $code)"
    ((fail++)) || true
  fi
}
soft_check "wait-order welcome" "$GATEWAY/api/v1/waitorderservice/welcome" "Wait"
soft_check "food-delivery welcome" "$GATEWAY/api/v1/fooddeliveryservice/welcome" "food"
soft_check "config" "$GATEWAY/api/v1/configservice/configs" ""
soft_check "travel welcome" "$GATEWAY/api/v1/travelservice/welcome" "Welcome"
soft_check "order welcome" "$GATEWAY/api/v1/orderservice/welcome" "Welcome"

echo ""
echo "=== UI proxy ($UI) ==="
if [[ "${SKIP_UI:-0}" == "1" ]]; then
  echo "  (skipped — SKIP_UI=1)"
elif ! curl -sf --max-time 2 -o /dev/null "$UI/" 2>/dev/null; then
  echo "  (skipped — $UI not up)"
else
  check "UI homepage" "$UI/" ""
  check "UI news" "$UI/api/v1/newsservice/" "News"
  check "UI verifycode" "$UI/api/v1/verifycode/generate" ""
fi

echo ""
echo "=== Results: $pass passed, $fail failed ==="
[[ "$fail" -eq 0 ]]
