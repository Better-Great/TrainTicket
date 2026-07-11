#!/usr/bin/env bash
# Welcome smoke for preserve / payment / inside-payment (direct + gateway).
set -euo pipefail

GW="${GATEWAY_URL:-http://127.0.0.1:18888}"
pass=0
fail=0

check() {
  local name="$1" url="$2"
  printf "  %-48s " "$name"
  code=$(curl -s -o /tmp/booking-smoke.txt -w "%{http_code}" --max-time 12 "$url" || echo 000)
  if [[ "$code" =~ ^2 ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "FAIL ($code)"
    head -c 160 /tmp/booking-smoke.txt; echo
    ((fail++)) || true
  fi
}

echo "=== Direct booking services ==="
check "preserve :14568" "http://127.0.0.1:14568/api/v1/preserveservice/welcome"
check "payment :19001" "http://127.0.0.1:19001/api/v1/paymentservice/welcome"
check "inside-payment :18673" "http://127.0.0.1:18673/api/v1/inside_pay_service/welcome"

echo ""
echo "=== Via gateway $GW ==="
check "GW preserve" "$GW/api/v1/preserveservice/welcome"
check "GW payment" "$GW/api/v1/paymentservice/welcome"
check "GW inside-payment" "$GW/api/v1/inside_pay_service/welcome"

echo ""
echo "=== Gateway JWT gate (booking mutating paths) ==="
check_code() {
  local name="$1" url="$2" want="$3" auth="${4:-}"
  printf "  %-48s " "$name"
  if [[ -n "$auth" ]]; then
    code=$(curl -s -o /tmp/booking-smoke.txt -w "%{http_code}" --max-time 12 -H "Authorization: Bearer $auth" -X POST -H 'Content-Type: application/json' -d '{}' "$url" || echo 000)
  else
    code=$(curl -s -o /tmp/booking-smoke.txt -w "%{http_code}" --max-time 12 -X POST -H 'Content-Type: application/json' -d '{}' "$url" || echo 000)
  fi
  if [[ "$code" == "$want" ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "FAIL (got $code want $want)"
    head -c 120 /tmp/booking-smoke.txt; echo
    ((fail++)) || true
  fi
}

# Welcome stays open; preserve without Bearer must be 401 at the edge
check_code "GW preserve POST no token → 401" "$GW/api/v1/preserveservice/preserve" "401"
check_code "GW payment POST no token → 401" "$GW/api/v1/paymentservice/payment" "401"
check_code "GW inside-pay POST no token → 401" "$GW/api/v1/inside_pay_service/inside_payment" "401"

echo ""
echo "=== Results: $pass passed, $fail failed ==="
[[ "$fail" -eq 0 ]]
