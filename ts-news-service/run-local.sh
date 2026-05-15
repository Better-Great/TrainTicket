#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export NEWS_SERVICE_PORT="${NEWS_SERVICE_PORT:-12862}"
echo "ts-news-service → http://127.0.0.1:${NEWS_SERVICE_PORT}/ (GET returns JSON news list)"
exec go run ./src/main
