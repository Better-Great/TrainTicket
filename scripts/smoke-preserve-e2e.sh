#!/usr/bin/env bash
# Offline-ready E2E smoke: login → preserve (requires infra + auth + booking peers).
# Does not start services — run after compose + start-*-local scripts.
set -euo pipefail

GW="${GATEWAY_URL:-http://127.0.0.1:18888}"
USER="${TT_USER:-fdse_microservice}"
PASS="${TT_PASS:-111111}"

pass=0
fail=0
check() {
  local name="$1" code="$2" want="$3"
  printf "  %-48s " "$name"
  if [[ "$code" == "$want" ]]; then
    echo "OK ($code)"
    ((pass++)) || true
  else
    echo "FAIL (got $code want $want)"
    ((fail++)) || true
  fi
}

echo "=== Auth login via gateway ==="
login_body=$(curl -s -o /tmp/tt-login.json -w "%{http_code}" --max-time 15 \
  -X POST "$GW/api/v1/users/login" \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"$USER\",\"password\":\"$PASS\"}" || echo 000)
check "POST /api/v1/users/login" "$login_body" "200"

TOKEN=$(python3 - <<'PY' 2>/dev/null || true
import json
try:
    d=json.load(open("/tmp/tt-login.json"))
    # Response shapes vary: data.token / data / token
    data=d.get("data") or d
    if isinstance(data, dict):
        print(data.get("token") or data.get("id") or "")
    elif isinstance(data, str):
        print(data)
except Exception:
    pass
PY
)

if [[ -z "${TOKEN:-}" ]]; then
  echo "  (no token parsed — body follows)"
  head -c 300 /tmp/tt-login.json; echo
  echo "=== Results: $pass passed, auth incomplete ==="
  exit 1
fi
echo "  token length: ${#TOKEN}"

echo ""
echo "=== Preserve (expects JWT; may fail if contacts/user/assurance down) ==="
preserve_code=$(curl -s -o /tmp/tt-preserve.json -w "%{http_code}" --max-time 30 \
  -X POST "$GW/api/v1/preserveservice/preserve" \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "accountId":"4d2a46c7-71ce-4cf1-a5bb-b68406d9da6f",
    "contactsId":"02e6c4f3-2dd4-4370-a3df-df40c07229a0",
    "tripId":"G1234",
    "seatType":2,
    "date":"2026-07-12",
    "from":"nanjing","to":"shanghai",
    "assurance":0,"foodType":0
  }' || echo 000)

# 200 = booked; 401 = gateway/auth; 5xx/200 with status 0 = peer gaps
printf "  %-48s " "POST /preserveservice/preserve"
echo "HTTP $preserve_code"
head -c 240 /tmp/tt-preserve.json; echo

echo ""
echo "=== Welcome still public ==="
w=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 "$GW/api/v1/preserveservice/welcome" || echo 000)
check "GET preserve welcome" "$w" "200"

echo ""
echo "=== Results: $pass passed, $fail failed (preserve body inspected above) ==="
[[ "$fail" -eq 0 ]]
