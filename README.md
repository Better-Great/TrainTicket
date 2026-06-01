# TrainTicket

Microservices train-ticket system: Spring Boot services, API gateway, web UI, and supporting infra (Nacos, MySQL, RabbitMQ, Redis, Kafka).

## Quick start (Docker)

```bash
cp .env.example .env
docker compose -f docker-compose.build.yml build   # first time
./scripts/up-docker.sh
```

- **UI:** http://localhost:8080  
- **Gateway:** http://localhost:18888  
- **Nacos:** http://localhost:8848/nacos  

Stop: `./scripts/down-docker.sh`

## Documentation

All guides live under **[docs/](docs/README.md)**:

- [Getting started](docs/GETTING-STARTED.md) — Docker, local JARs, single services  
- [Docker](docs/DOCKER.md) — build, push to Docker Hub (`bettergreat/*`), compose  
- [Non-Java services](docs/NON-JAVA-SERVICES.md) — UI, news, avatar, voucher, ticket-office  
- [Local development](docs/LOCAL-DEVELOPMENT.md) — `scripts/start.sh` workflow  
- [Ports](docs/PORTS.md)  
- [Deployment overview](docs/DEPLOYMENT.md)  

## Layout

| Path | Purpose |
|------|---------|
| `ts-*-service/` | Microservice source |
| `dockerfile/` | Central Dockerfiles (`Dockerfile.Ts.*`) |
| `docker-compose.build.yml` | Build + run apps + minimal infra |
| `docker-compose.minimal.yml` | MySQL, Nacos, messaging only |
| `properties/` | `*.application.ini` for token replacement / Docker |
| `scripts/` | Build, start/stop, DB init, `up-docker.sh` |
| `.env` | Local overrides (from `.env.example`) |

## Build Java services

```bash
mvn clean package -DskipTests
# or
./scripts/build.sh all
```

## Push images to Docker Hub

```bash
# .env: IMG_REPO=bettergreat IMG_TAG=0.2.0
docker login
./scripts/docker-build-push.sh
```
