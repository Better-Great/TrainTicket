# Dockerfiles for Train Ticket Services

## Java services

All Java microservices use the same production-ready structure: Eclipse Temurin 17 JRE on Alpine, token-based config, non-root user, and healthchecks.

## Non-Java services

- **`Dockerfile.Ts.Ui.Dashboard`** – OpenResty/nginx frontend (port 8080).
- **`Dockerfile.Ts.Avatar.Service`** – Python/Flask face-detection (port 17001).
- **`Dockerfile.Ts.Voucher.Service`** – Python/Tornado voucher API (port 16101).
- **`Dockerfile.Ts.Ticket.Office.Service`** – Node.js/Express (port 16108).
- **`Dockerfile.Ts.News.Service`** – Go HTTP service (port 12862).

All are built from repo root with `context: .` and copy from the corresponding `ts-*` directory.

## Layout

- **`Dockerfile.Ts.<Name>.Service`** – One Dockerfile per Java service (e.g. `Dockerfile.Ts.Auth.Service`, `Dockerfile.Ts.Station.Service`).
- **`templates/<service>/application.properties.ini`** – Config template per Java service; tokens are replaced at runtime from `properties/${ENVIRONMENT}.application.ini`.

## Build requirements

- **JARs in `jar/`** (from repo root): run `./scripts/build.sh` then `./scripts/deploy.sh` (and deploy `ts-token-replacement-service`).
- **Context**: build from repo root with `context: .` and `dockerfile: dockerfile/Dockerfile.Ts.<Name>.Service`.

## Build and run

From repo root:

```bash
# Build all images (Java: uses jar/; non-Java: uses ts-* source dirs)
docker compose -f docker-compose.minimal.yml -f docker-compose.build.yml build

# Or build one service (Java or non-Java)
docker compose -f docker-compose.minimal.yml -f docker-compose.build.yml build ts-station-service
docker compose -f docker-compose.minimal.yml -f docker-compose.build.yml build ts-ui-dashboard

# Run (ensure properties/ and .env are set)
docker compose -f docker-compose.minimal.yml -f docker-compose.build.yml up -d
```

Each service expects:

- **Volume**: `./properties` mounted at `/app/external-config` (read-only), with `${ENVIRONMENT}.application.ini` (default: `docker.application.ini`).
- **Env**: `ENVIRONMENT`, `TZ`, `PORT` (and vars referenced in the service template).

## Regenerating Dockerfiles

To add or regenerate Dockerfiles for new services, use:

```bash
./dockerfile/gen_dockerfiles.sh
```

Then add the service and its volume to `docker-compose.build.yml` if needed.
