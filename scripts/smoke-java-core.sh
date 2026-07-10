#!/usr/bin/env bash
# Confirm SPA ↔ Java gateway ↔ core Java services (+ polyglot still healthy).
set -euo pipefail

GW="${GATEWAY_URL:-http://127.0.0.1:18888}"
SPA="${SPA_URL:-http://127.0.0.1:5173}"

pass=0
fail=0
check() {
  local name="$1" url="$2"
  printf "  %-44s " "$name"
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

echo "=== Direct Java services ==="
check "station :12345" "http://127.0.0.1:12345/api/v1/stationservice/stations"
check "route :11178" "http://127.0.0.1:11178/api/v1/routeservice/routes"
check "train :14567" "http://127.0.0.1:14567/api/v1/trainservice/trains"
check "config :15679" "http://127.0.0.1:15679/api/v1/configservice/configs"
check "wait-order :17525" "http://127.0.0.1:17525/api/v1/waitorderservice/welcome"
check "food-delivery :18957" "http://127.0.0.1:18957/api/v1/fooddeliveryservice/welcome"

echo ""
echo "=== Via gateway $GW ==="
check "GW stations" "$GW/api/v1/stationservice/stations"
check "GW routes" "$GW/api/v1/routeservice/routes"
check "GW trains" "$GW/api/v1/trainservice/trains"
check "GW config" "$GW/api/v1/configservice/configs"
check "GW wait-order" "$GW/api/v1/waitorderservice/welcome"
check "GW food-delivery" "$GW/api/v1/fooddeliveryservice/welcome"
check "GW news (polyglot)" "$GW/api/v1/newsservice/"
check "GW office (polyglot)" "$GW/office/getRegionList"

echo ""
echo "=== Via SPA $SPA ==="
check "SPA stations" "$SPA/api/v1/stationservice/stations"
check "SPA wait-order" "$SPA/api/v1/waitorderservice/welcome"
check "SPA food-delivery" "$SPA/api/v1/fooddeliveryservice/welcome"
check "SPA news" "$SPA/api/v1/newsservice/"
check "SPA office" "$SPA/office/getRegionList"

echo ""
echo "=== Results: $pass passed, $fail failed ==="
[[ "$fail" -eq 0 ]]
