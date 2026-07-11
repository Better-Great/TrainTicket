#!/usr/bin/env bash
# Confirm SPA ↔ non-Java backends (direct or via Vite proxy).
set -euo pipefail

NEWS="${NEWS_URL:-http://127.0.0.1:12862}"
OFFICE="${OFFICE_URL:-http://127.0.0.1:16108}"
VOUCHER="${VOUCHER_URL:-http://127.0.0.1:16101}"
SPA="${SPA_URL:-http://127.0.0.1:5173}"

pass=0
fail=0
check() {
  local name="$1" url="$2" method="${3:-GET}" data="${4:-}"
  printf "  %-40s " "$name"
  if [[ "$method" == "POST" ]]; then
    code=$(curl -s -o /tmp/poly-body.txt -w "%{http_code}" --max-time 8 -X POST \
      -H 'Content-Type: application/json' -d "$data" "$url" || echo 000)
  else
    code=$(curl -s -o /tmp/poly-body.txt -w "%{http_code}" --max-time 8 "$url" || echo 000)
  fi
  if [[ "$code" =~ ^2 ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "FAIL ($code)"
    head -c 160 /tmp/poly-body.txt; echo
    ((fail++)) || true
  fi
}

echo "=== Direct polyglot backends ==="
check "news /" "$NEWS/"
check "office regions" "$OFFICE/office/getRegionList"
check "office specific" "$OFFICE/office/getSpecificOffices" POST \
  '{"province":"Shanghai","city":"Shanghai","region":"Pudong New Area"}'
check "voucher health" "$VOUCHER/health"
check "voucher print" "$VOUCHER/getVoucher" POST '{"orderId":"poly-smoke","type":1}'

echo ""
echo "=== Via SPA Vite proxy (if running) ==="
check "SPA proxy news" "$SPA/api/v1/newsservice/news"
check "SPA proxy office" "$SPA/office/getRegionList"
check "SPA proxy voucher" "$SPA/getVoucher" POST '{"orderId":"poly-spa","type":1}'

echo ""
echo "=== Results: $pass passed, $fail failed ==="
[[ "$fail" -eq 0 ]]
