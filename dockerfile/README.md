# Dockerfiles

Per-service images live here as `Dockerfile.Ts.*`. Build context is always the **repo root** so we can `COPY jar/…` and the shared entrypoint.

## Shared entrypoint

Every Java image uses [`entrypoint.sh`](entrypoint.sh):

1. Read `properties/${ENVIRONMENT}.application.ini` (mounted at `/app/external-config`)
2. Run the tiny token-replacement JAR to materialize `application.properties`
3. Start the service with lean `JAVA_OPTS` and `--spring.config.additional-location=…`

We switched away from `spring.config.location` after it wiped gateway routes that live in the jar's `application.yml`.

## Build & run

```bash
./scripts/deploy.sh all
docker compose -f docker-compose.build.yml build
./scripts/up-lean.sh
```

Details: [docs/DOCKER.md](../docs/DOCKER.md).

## Java vs non-Java

Java: `Dockerfile.Ts.<Name>.Service` — expects `jar/ts-*-service.jar` plus `jar/ts-token-replacement-service.jar`. Property templates sit under `dockerfile/templates/`.

Non-Java (built from their own contexts or the same compose file):

| Dockerfile / context | Service | Port |
|----------------------|---------|------|
| `ts-ui-web/Dockerfile` | nginx + SPA | 8080 |
| `Dockerfile.Ts.News.Service` | Go | 12862 |
| `Dockerfile.Ts.Avatar.Service` | Python | 17001 |
| `Dockerfile.Ts.Voucher.Service` | Python | 16101 |
| `Dockerfile.Ts.Ticket.Office.Service` | Node | 16108 |

Regenerate the Java Dockerfiles from the template helper if you add a service: `./dockerfile/gen_dockerfiles.sh`.
