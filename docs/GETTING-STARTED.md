# Getting started

TrainTicket is a microservices train-booking system: **41 Java** services (Spring Boot), **4 non-Java** services (UI, Node ticket-office, Python voucher, Go news, Python avatar), plus **Nacos**, **MySQL**, **RabbitMQ**, **Redis**, **Kafka**, and **Zipkin**.

## Prerequisites

- **Docker** (recommended for full stack)
- Or for local JARs: **Java 8**, **Maven 3**, **MySQL**, **Docker** (at least for Nacos)

## Option A — Full stack in Docker (recommended)

1. **Configure environment**

   ```bash
   cp .env.example .env
   # Edit .env if needed (ports, IMG_REPO=bettergreat for registry push)
   ```

2. **Build images** (first time or after code changes)

   ```bash
   docker compose -f docker-compose.build.yml build
   ```

   Or build and push to Docker Hub:

   ```bash
   docker login
   ./scripts/docker-build-push.sh
   ```

3. **Start everything** (apps + MySQL + Nacos + messaging infra)

   ```bash
   ./scripts/up-docker.sh
   ```

4. **Open**

   | URL | Purpose |
   |-----|---------|
   | http://localhost:8080 | Web UI (`ts-ui-dashboard`) |
   | http://localhost:18888 | API gateway |
   | http://localhost:8848/nacos | Nacos console (`nacos` / `nacos`) |

5. **Logs / status**

   ```bash
   docker compose -f docker-compose.build.yml ps
   docker compose -f docker-compose.build.yml logs -f ts-gateway-service
   ```

6. **Stop**

   ```bash
   ./scripts/down-docker.sh
   ```

First boot can take several minutes while MySQL initializes and services register in Nacos.

See [DOCKER.md](DOCKER.md) for image tags and [NON-JAVA-SERVICES.md](NON-JAVA-SERVICES.md) for non-Java service details.

## Option B — Infrastructure only (minimal)

Start deps without app containers (useful when running services from IDE or JARs):

```bash
cp .env.example .env
docker compose -f docker-compose.minimal.yml up -d
```

MySQL is on host port `${MYSQL_PORT}` (default **3307** in `.env.example`).

## Option C — Local JARs / scripts

1. Build: `./scripts/build.sh all`
2. Init DB (local MySQL): `./scripts/init-databases-local.sh`
3. Start: `./scripts/start-local.sh`
4. Status: `./scripts/status.sh`
5. Stop: `./scripts/stop.sh`

Details: [LOCAL-DEVELOPMENT.md](LOCAL-DEVELOPMENT.md).

## Option D — Single non-Java service locally

Each service has a `run-local.sh` where applicable, e.g.:

```bash
./ts-ui-dashboard/run-local.sh          # static UI only (no /api/v1 proxy)
./ts-ticket-office-service/run-local.sh   # needs .env + MySQL
./ts-news-service/run-local.sh
```

See [NON-JAVA-SERVICES.md](NON-JAVA-SERVICES.md).

## Generate Java configs (token replacement)

For environment-specific `application.properties`:

```bash
./replace-tokens.sh dev    # or qa, prod, docker
```

Requires `ts-token-replacement-service` built once (`cd ts-token-replacement-service && ./build.sh`).

## Troubleshooting

- **Port in use** — check [PORTS.md](PORTS.md) or `ss -tlnp | grep <port>`
- **MySQL connection refused** — ensure `docker compose -f docker-compose.minimal.yml up -d mysql` and `.env` `MYSQL_PORT` matches
- **UI loads but API fails** — gateway must be up on **18888**; UI container proxies `/api/v1/` to `ts-gateway-service:18888`
- **IDE Java errors in a service** — open repo root in the IDE; run `mvn -pl ts-common install -DskipTests`
