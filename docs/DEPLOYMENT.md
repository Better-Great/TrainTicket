# Deployment overview

## Paths

```
Local JARs / scripts  →  Docker Compose (build.yml)  →  Kubernetes (k8s/)
```

| Mode | When | Entry |
|------|------|--------|
| **Docker** | Default; full stack | [GETTING-STARTED.md](GETTING-STARTED.md) Option A |
| **Local JARs** | Debugging one service | [LOCAL-DEVELOPMENT.md](LOCAL-DEVELOPMENT.md) |
| **Kubernetes** | Production clusters | `kubectl apply -f k8s/` (if manifests present) |

## Docker (current recommended)

```bash
cp .env.example .env
docker compose -f docker-compose.build.yml build
./scripts/up-docker.sh
```

- **46** app images (Java + UI, avatar, news, voucher, ticket-office)
- Infra from included `docker-compose.minimal.yml` (MySQL, Nacos, …)
- Registry push: `IMG_REPO=bettergreat` + `./scripts/docker-build-push.sh`

Details: [DOCKER.md](DOCKER.md).

## Minimal dependency chain

```
MySQL → Nacos → microservices → Gateway (18888) → UI (8080)
```

## Config generation

Environment-specific Java config:

```bash
./replace-tokens.sh dev|qa|prod|docker
```

Uses `properties/<env>.application.ini` and `ts-token-replacement-service`.
