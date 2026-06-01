#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ ! -f .env ]]; then
  echo "Missing .env — copy .env.example to .env and set TICKET_OFFICE_MYSQL_* (and PORT)." >&2
  exit 1
fi
echo "Requires MySQL reachable at the host/port in .env (schema from Liquibase / docker init)."
exec npm start
