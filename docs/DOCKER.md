# Docker deployment

## Files

| File | Role |
|------|------|
| `docker-compose.minimal.yml` | MySQL, Nacos, RabbitMQ, Redis, Kafka, Zipkin |
| `docker-compose.build.yml` | **Includes minimal** + all app images (Java + non-Java) — canonical, single source of truth |
| `dockerfile/Dockerfile.Ts.*` | Per-service Dockerfiles (build context = repo root) |
| `.env` | Ports, credentials, `IMG_REPO`, `IMG_TAG` |

## Quick commands

```bash
cp .env.example .env

# Build all app images (46 services)
docker compose -f docker-compose.build.yml build

# Start stack
./scripts/up-docker.sh

# Stop stack
./scripts/down-docker.sh

# Build + push to Docker Hub (IMG_REPO=bettergreat in .env)
docker login
./scripts/docker-build-push.sh
```

Images are tagged `bettergreat/ts-<service>:<IMG_TAG>` when `IMG_REPO=bettergreat`.

## Non-Java services in the build compose file

Included in `docker-compose.build.yml`:

- `ts-ui-dashboard` compose service → image `${IMG_REPO}/ts-ui-web` (nginx, port 8080); CI also tags `ts-ui-dashboard` as a legacy Hub alias
- `ts-gateway-service` (18888 — UI proxies `/api/v1/` here)
- `ts-avatar-service`, `ts-news-service`, `ts-voucher-service`, `ts-ticket-office-service`

Voucher and ticket-office need MySQL (`mysql` hostname on `trainticket-net`); env vars are set in the compose file with defaults matching `properties/docker.application.ini`.

## Build one service

```bash
docker compose -f docker-compose.build.yml build ts-user-service
```

## Logs

```bash
docker compose -f docker-compose.build.yml logs -f ts-user-service
```

Service logs also bind-mount under `./log/<service-name>/` for Java services.
