#!/usr/bin/env bash
# Smoke-test gateway routes and edge nginx proxy (run after docker compose is up).
set -euo pipefail

GATEWAY="${GATEWAY_URL:-http://localhost:18888}"
UI="${UI_URL:-http://localhost:8080}"

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
check "wait-order welcome" "$GATEWAY/api/v1/waitorderservice/welcome" "Wait"
check "food-delivery welcome" "$GATEWAY/api/v1/fooddeliveryservice/welcome" "food"
check "news API path" "$GATEWAY/api/v1/newsservice/news" "News"
check "news legacy path" "$GATEWAY/news-service/news" "News"
check "ticket office regions" "$GATEWAY/office/getRegionList" ""
check "ticket office API path" "$GATEWAY/api/v1/ticketofficeservice/getRegionList" ""

echo ""
echo "=== UI edge proxy ($UI) ==="
if [[ "${SKIP_UI:-0}" == "1" ]]; then
  echo "  (skipped — SKIP_UI=1)"
elif ! curl -sf --max-time 2 -o /dev/null "$UI/" 2>/dev/null; then
  echo "  (skipped — $UI not up; set SKIP_UI=0 and start edge UI to include)"
else
  check "UI homepage" "$UI/" ""
  check "UI news legacy" "$UI/news-service/news" "News"
  check "verifycode (gateway)" "$UI/api/v1/verifycode/generate" ""
fi

echo ""
echo "=== Results: $pass passed, $fail failed ==="
[[ "$fail" -eq 0 ]]
