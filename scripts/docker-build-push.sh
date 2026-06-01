#!/usr/bin/env bash
# Build all docker-compose.build.yml images and push to Docker Hub (IMG_REPO/IMG_TAG from .env).
# Usage (repo root):
#   docker login
#   ./scripts/docker-build-push.sh
#   ./scripts/docker-build-push.sh build   # build only
#   ./scripts/docker-build-push.sh push    # push only (images must exist)

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Missing .env — copy from .env.example and set IMG_REPO=bettergreat (or your Docker Hub user)." >&2
  exit 1
fi

# shellcheck disable=SC1091
set -a
source .env
set +a

if [[ -z "${IMG_REPO:-}" ]]; then
  echo "IMG_REPO is not set in .env (e.g. IMG_REPO=bettergreat)." >&2
  exit 1
fi

COMPOSE=(docker compose -f docker-compose.build.yml)
ACTION="${1:-all}"

case "$ACTION" in
  build)
    "${COMPOSE[@]}" build
    ;;
  push)
    "${COMPOSE[@]}" push
    ;;
  all)
    "${COMPOSE[@]}" build
    "${COMPOSE[@]}" push
    ;;
  *)
    echo "Usage: $0 [build|push|all]" >&2
    exit 1
    ;;
esac

echo "Done. Images: ${IMG_REPO}/<service>:${IMG_TAG:-latest}"
