#!/usr/bin/env bash
# Stage B/C smoke: core Java + booking welcomes + gateway JWT gates.
# Optional: polyglot / SPA checks soft-skip if those processes are down.
set -euo pipefail

GW="${GATEWAY_URL:-http://127.0.0.1:18888}"
SPA="${SPA_URL:-http://127.0.0.1:5173}"

pass=0
fail=0
skip=0

check() {
  local name="$1" url="$2"
  printf "  %-48s " "$name"
  code=$(curl -s -o /tmp/java-smoke.txt -w "%{http_code}" --max-time 12 "$url" || echo 000)
  if [[ "$code" =~ ^2 ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "FAIL ($code)"
    head -c 160 /tmp/java-smoke.txt; echo
    ((fail++)) || true
  fi
}

check_opt() {
  local name="$1" url="$2"
  printf "  %-48s " "$name"
  code=$(curl -s -o /tmp/java-smoke.txt -w "%{http_code}" --max-time 8 "$url" || echo 000)
  if [[ "$code" =~ ^2 ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "SKIP ($code)"
    ((skip++)) || true
  fi
}

check_code() {
  local name="$1" url="$2" want="$3"
  printf "  %-48s " "$name"
  code=$(curl -s -o /tmp/java-smoke.txt -w "%{http_code}" --max-time 12 \
    -X POST -H 'Content-Type: application/json' -d '{}' "$url" || echo 000)
  if [[ "$code" == "$want" ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "FAIL (got $code want $want)"
    head -c 120 /tmp/java-smoke.txt; echo
    ((fail++)) || true
  fi
}

echo "=== Direct core ==="
check "station :12345" "http://127.0.0.1:12345/api/v1/stationservice/stations"
check_opt "route :11178" "http://127.0.0.1:11178/api/v1/routeservice/routes"
check_opt "train :14567" "http://127.0.0.1:14567/api/v1/trainservice/trains"
check_opt "config :15679" "http://127.0.0.1:15679/api/v1/configservice/configs"

echo ""
echo "=== Direct booking / auth ==="
check "preserve :14568" "http://127.0.0.1:14568/api/v1/preserveservice/welcome"
check "payment :19001" "http://127.0.0.1:19001/api/v1/paymentservice/welcome"
check "inside-payment :18673" "http://127.0.0.1:18673/api/v1/inside_pay_service/welcome"
check_opt "auth :12340" "http://127.0.0.1:12340/api/v1/users/hello"

echo ""
echo "=== Via gateway $GW ==="
check "GW stations" "$GW/api/v1/stationservice/stations"
check "GW preserve welcome" "$GW/api/v1/preserveservice/welcome"
check "GW payment welcome" "$GW/api/v1/paymentservice/welcome"
check "GW inside-payment welcome" "$GW/api/v1/inside_pay_service/welcome"
check_opt "GW news" "$GW/api/v1/newsservice/"

echo ""
echo "=== Gateway JWT (mutating paths → 401 without Bearer) ==="
check_code "preserve POST" "$GW/api/v1/preserveservice/preserve" "401"
check_code "payment POST" "$GW/api/v1/paymentservice/payment" "401"
check_code "inside-pay POST" "$GW/api/v1/inside_pay_service/inside_payment" "401"
check_code "order POST" "$GW/api/v1/orderservice/order" "401"

echo ""
echo "=== Optional SPA $SPA ==="
check_opt "SPA stations" "$SPA/api/v1/stationservice/stations"

echo ""
echo "=== Results: $pass passed, $fail failed, $skip skipped ==="
[[ "$fail" -eq 0 ]]
