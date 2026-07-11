#!/usr/bin/env bash
# Start non-Java polyglot backends for local SPA live checks (no full Java stack).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/log/polyglot"
mkdir -p "$LOG"

echo "=== Starting non-Java services ==="

# News (Go)
if ! curl -sf --max-time 1 http://127.0.0.1:12862/ >/dev/null 2>&1; then
  (cd "$ROOT/ts-news-service" && go run . >"$LOG/news.log" 2>&1) &
  echo $! >"$LOG/news.pid"
  echo "news pid $(cat "$LOG/news.pid")"
else
  echo "news already up on :12862"
fi

# Ticket office (Node, file mode)
if ! curl -sf --max-time 1 http://127.0.0.1:16108/office/ >/dev/null 2>&1; then
  if [[ ! -d "$ROOT/ts-ticket-office-service/node_modules" ]]; then
    (cd "$ROOT/ts-ticket-office-service" && npm install --silent)
  fi
  (
    cd "$ROOT/ts-ticket-office-service"
    TICKET_OFFICE_DATA_MODE=file PORT=16108 node bin/www >"$LOG/office.log" 2>&1
  ) &
  echo $! >"$LOG/office.pid"
  echo "office pid $(cat "$LOG/office.pid")"
else
  echo "office already up on :16108"
fi

# Voucher (Python venv, in-memory)
if ! curl -sf --max-time 1 http://127.0.0.1:16101/health >/dev/null 2>&1; then
  if [[ ! -x "$ROOT/ts-voucher-service/.venv/bin/python" ]]; then
    python3 -m venv "$ROOT/ts-voucher-service/.venv"
    "$ROOT/ts-voucher-service/.venv/bin/pip" install -q -r "$ROOT/ts-voucher-service/requirements.txt"
  fi
  (
    cd "$ROOT/ts-voucher-service"
    VOUCHER_INMEMORY=1 PORT=16101 .venv/bin/python server.py >"$LOG/voucher.log" 2>&1
  ) &
  echo $! >"$LOG/voucher.pid"
  echo "voucher pid $(cat "$LOG/voucher.pid")"
else
  echo "voucher already up on :16101"
fi

sleep 2
echo ""
echo "=== Health probes ==="
curl -sf http://127.0.0.1:12862/ | head -c 120; echo
curl -sf http://127.0.0.1:16108/office/getRegionList | head -c 120; echo
curl -sf -X POST http://127.0.0.1:16101/getVoucher \
  -H 'Content-Type: application/json' \
  -d '{"orderId":"smoke-1","type":1}' | head -c 200; echo
echo "OK — polyglot backends ready"
echo "SPA: cd ts-ui-web && VITE_USE_MOCK=false VITE_POLYGLOT_DIRECT=1 bun run dev"
