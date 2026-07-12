# Getting started

TrainTicket is a microservices train-booking system: **~41 Java** Spring Boot services, a few **non-Java** side services (UI, news, voucher, avatar, ticket-office), plus **Nacos**, **MySQL**, **RabbitMQ**, and **Redis**. Kafka/Zipkin are optional.

If you only have a laptop or a small VM, start with the **lean** path. That is what we develop against day to day.

## Prerequisites

- Docker (Compose v2)
- For rebuilding Java images: JDK 17+ and Maven 3 (Temurin 17 matches the images)
- Bun only if you work on `ts-ui-web` outside Docker

## Option A — Lean Docker stack (recommended on ≤8 GiB)

This brings up infra + the booking path (gateway, auth, station/route/travel, preserve/pay, UI, …) without dragging every admin/food/consign service into RAM.

```bash
cp .env.example .env
# Edit JWT_SECRET — required. The example value is local-dev only.

./scripts/build.sh all
./scripts/deploy.sh all
docker compose -f docker-compose.build.yml build   # or build just what you changed

./scripts/up-lean.sh
./scripts/smoke-java-core.sh
```

| URL | Purpose |
|-----|---------|
| http://localhost:8080 | Web UI |
| http://localhost:18888 | API gateway |
| http://localhost:8848/nacos | Nacos (`nacos` / `nacos`) |

First boot is slow. Each JVM on a small heap can take 2–4 minutes before Tomcat listens; wait until smoke is green before debugging "connection refused".

Why lean exists (heap vs cgroup, Nacos young-gen, gateway routes, etc.): **[DOCKER.md](DOCKER.md)**.

Stop: `./scripts/down-docker.sh`

## Option B — Full Docker stack

Same as above, but start every app service:

```bash
./scripts/up-docker.sh
```

You will want more than 8 GiB free for this to be pleasant.

## Option C — Infra only

Run MySQL/Nacos/Redis/RabbitMQ and start services from the IDE or `java -jar`:

```bash
cp .env.example .env
docker compose -f docker-compose.minimal.yml up -d nacos mysql redis rabbitmq
./scripts/init-databases.sh   # if schemas are missing
```

MySQL is on host port `${MYSQL_PORT}` (default **3307**).

## Option D — Local JARs on the host

```bash
./scripts/build.sh all
./scripts/deploy.sh all
./scripts/init-databases-local.sh
./scripts/start-java-core-local.sh   # or start-local.sh for more
./scripts/status.sh
./scripts/stop.sh
```

See [LOCAL-DEVELOPMENT.md](LOCAL-DEVELOPMENT.md).

## After code changes

| Change | Rebuild |
|--------|---------|
| Java service source | `mvn -pl ts-<name>-service -am package -DskipTests` → `./scripts/deploy.sh <name>` → `docker compose … build ts-<name>-service` → recreate container |
| Shared `entrypoint.sh` | Rebuild **every** Java image that should pick it up (or bind-mount for a quick test) |
| `properties/docker.application.ini` | Recreate containers (mounted read-only; no image rebuild) |
| SPA | `docker compose … build ts-ui-dashboard` |

## Useful follow-ups

- Ports: [PORTS.md](PORTS.md)
- Non-Java services: [NON-JAVA-SERVICES.md](NON-JAVA-SERVICES.md)
- Hub / compose detail: [DOCKER.md](DOCKER.md)
