# Docker deployment

How we run TrainTicket in containers, and why the defaults look the way they do.

## The short version

```bash
cp .env.example .env          # set JWT_SECRET
./scripts/build.sh all && ./scripts/deploy.sh all
docker compose -f docker-compose.build.yml build
./scripts/up-lean.sh          # booking path on ~8GiB
./scripts/smoke-java-core.sh
```

Full app set on a bigger box: `./scripts/up-docker.sh`. Stop with `./scripts/down-docker.sh`.

## Files

| File | Role |
|------|------|
| `docker-compose.minimal.yml` | MySQL, Nacos, RabbitMQ, Redis. Kafka/Zipkin only with `--profile full-infra` |
| `docker-compose.build.yml` | Includes minimal + every app image. Java services capped ~320 MiB |
| `scripts/up-lean.sh` | Infra + ~22 booking-path services — what we actually use on small hosts |
| `scripts/up-docker.sh` | Everything in `docker-compose.build.yml` |
| `dockerfile/entrypoint.sh` | Shared by all Java images: token-replace config, lean JVM, `additional-location` |
| `.env` / `.env.example` | Ports, Hub tags, `JAVA_OPTS`, Nacos JVM knobs, `JWT_SECRET` |

## Why these defaults

We hit this the hard way on an 8 GiB VM:

1. **Heap vs cgroup limit** — `-Xmx128m` plus metaspace does not fit in a 192 MiB container. Compose uses ~320 MiB so the JVM can finish starting.
2. **Nacos** — upstream image sets `JVM_XMN=512m` even when you shrink `JVM_XMX`. Override XMN/MS/MMS or it OOMs and every app blocks on `depends_on: nacos healthy`.
3. **Gateway routes** — `spring.config.location=...` replaced the classpath `application.yml` and the gateway came up with **zero routes** (every `/api/v1/**` → 404). Entrypoint now uses `additional-location`.
4. **JWT_SECRET** — fail-closed on purpose. No secret → requests explode inside `JWTUtil`. Copy `.env.example` and set one before `up-lean`.
5. **Sentinel logs** — gateway tried to write `/app/logs/csp`. If the bind-mounted `log/` dir is root-owned, that NPE takes down request handling. Default opts include `-Dcsp.sentinel.log.dir=/tmp/csp`.
6. **Assurance vs gateway ports** — both used to default to 18888. Assurance is **18887** in compose + `properties/docker.application.ini`.
7. **Healthchecks** — `/actuator/health` is permitAll so Docker's health status tracks process health, not "did you send a JWT?".

## Quick commands

```bash
# Build one service image
docker compose -f docker-compose.build.yml build ts-preserve-service

# Optional heavy infra
docker compose -f docker-compose.minimal.yml --profile full-infra up -d

# Logs
docker compose -f docker-compose.build.yml logs -f ts-gateway-service
```

Java service logs also bind-mount under `./log/<service-name>/`. Prefer fixing ownership with your user id if Sentinel or log writers complain (`sudo chown -R "$USER" log`).

## Images / Hub

```bash
docker login
./scripts/docker-build-push.sh
```

Tags look like `${IMG_REPO}/ts-<service>:${IMG_TAG}` (see `.env`). CI publishes the full set on `main`, `feat`, version tags, and the weekly security schedule; manual runs can select the smaller `core` matrix. Unrelated docs/CI-only commits do not rebuild all images.

Publishing is digest-first: BuildKit attaches SBOM and provenance attestations to
the full-commit SHA image, Trivy blocks High/Critical findings, and Cosign signs
and verifies the digest with GitHub OIDC. `latest` and semver aliases are created
only after those checks pass. See [Security and software supply chain](SECURITY.md)
for inspection and verification commands.

## Non-Java services in compose

- `ts-ui-dashboard` → image `ts-ui-web` (nginx, port 8080); Hub also gets a legacy `ts-ui-dashboard` alias from CI
- `ts-news-service`, `ts-voucher-service`, `ts-avatar-service`, `ts-ticket-office-service`

Voucher / ticket-office talk to MySQL on the compose network (`mysql:3307` by default).
