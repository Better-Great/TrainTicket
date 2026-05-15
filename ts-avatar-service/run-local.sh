#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example to .env and adjust values." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

: "${AVATAR_SERVICE_HOST:?Set AVATAR_SERVICE_HOST in .env}"
: "${AVATAR_SERVICE_PORT:?Set AVATAR_SERVICE_PORT in .env}"

if [[ ! -d venv ]]; then
  python3 -m venv venv
fi
# shellcheck disable=SC1091
source venv/bin/activate
pip install -r requirements.txt

echo "ts-avatar-service → http://${AVATAR_SERVICE_HOST}:${AVATAR_SERVICE_PORT}/"
exec python app.py
