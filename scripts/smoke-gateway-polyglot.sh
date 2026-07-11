#!/usr/bin/env bash
# Confirm SPA/gateway ↔ polyglot via Java gateway :18888 (no VITE_POLYGLOT_DIRECT).
set -euo pipefail

GW="${GATEWAY_URL:-http://127.0.0.1:18888}"
SPA="${SPA_URL:-http://127.0.0.1:5173}"

pass=0
fail=0
check() {
  local name="$1" url="$2" method="${3:-GET}" data="${4:-}"
  printf "  %-44s " "$name"
  if [[ "$method" == "POST" ]]; then
    code=$(curl -s -o /tmp/gw-body.txt -w "%{http_code}" --max-time 10 -X POST \
      -H 'Content-Type: application/json' -d "$data" "$url" || echo 000)
  else
    code=$(curl -s -o /tmp/gw-body.txt -w "%{http_code}" --max-time 10 "$url" || echo 000)
  fi
  if [[ "$code" =~ ^2 ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "FAIL ($code)"
    head -c 160 /tmp/gw-body.txt; echo
    ((fail++)) || true
  fi
}

echo "=== Via Java gateway $GW ==="
check "gateway news" "$GW/api/v1/newsservice/"
check "gateway office regions" "$GW/office/getRegionList"
check "gateway office api" "$GW/api/v1/ticketofficeservice/getRegionList"
check "gateway voucher" "$GW/getVoucher" POST '{"orderId":"gw-smoke","type":1}'
check "gateway voucher api" "$GW/api/v1/voucherservice/voucher" POST '{"orderId":"gw-api","type":1}'

echo ""
echo "=== Via SPA (expects Vite → gateway, no POLYGLOT_DIRECT) ==="
check "SPA→GW news" "$SPA/api/v1/newsservice/"
check "SPA→GW office" "$SPA/office/getRegionList"
check "SPA→GW voucher" "$SPA/getVoucher" POST '{"orderId":"spa-gw","type":1}'

echo ""
echo "=== Results: $pass passed, $fail failed ==="
[[ "$fail" -eq 0 ]]
