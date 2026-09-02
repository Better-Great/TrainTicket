# TrainTicket

[![CI](https://github.com/Better-Great/TrainTicket/actions/workflows/ci.yml/badge.svg)](https://github.com/Better-Great/TrainTicket/actions/workflows/ci.yml)
[![Docker Build & Publish](https://github.com/Better-Great/TrainTicket/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Better-Great/TrainTicket/actions/workflows/docker-publish.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

A ~46-service microservices train-ticket booking system — Spring Boot services, an API gateway, a modern Vue 3 SPA, and supporting infra (Nacos, MySQL, RabbitMQ, Redis, Kafka).

## What this is, and why

This is a fork and ongoing modernization of **[FudanSELab/train-ticket](https://github.com/FudanSELab/train-ticket)**, an academic microservices benchmark built for software-engineering research (fault localization, tracing, microservice architecture studies — see the [papers cited upstream](https://github.com/FudanSELab/train-ticket#paper-reference)). It's a genuinely large, realistic microservices system: 40+ services in Java/Spring Boot plus a few in Go/Python/Node, a shared MySQL-per-service data layer, Nacos service discovery, and all the operational messiness that comes with a system that size.

I'm using it as a working case study to build and demonstrate mid-level **cloud, DevOps, and MLOps** engineering — not by writing another toy CRUD app, but by taking a real (if academic) legacy system and moving it, piece by piece, toward how a team would actually run this in 2026: hardened auth and resilience patterns, a modern frontend, containers with sane defaults, CI/CD with proper image versioning, and — next — Kubernetes, observability, and a genuinely new ML-backed feature (not just a port of upstream work).

All modernization work happens in this repo and is tracked, ticket by ticket, against a running audit of what was found wrong with the original and a staged roadmap (edge/gateway → SPA → backend hardening → CI/CD → Kubernetes/Helm → observability → MLOps) kept internally alongside the code.

## What's been done so far

| Area | Status |
|------|--------|
| **Frontend** — Bun + Vite + Vue 3 + TypeScript SPA replacing the original Vue2/jQuery/AngularJS mix | Done |
| **Gateway** — single north-south entry point, JWT gates, CORS policy | Done |
| **Backend hardening** — fail-closed JWT secret, CORS/Swagger lockdown across all 40 services, Redis-backed idempotency on the booking path, a circuit breaker on the riskiest saga hops, request-ID log correlation | Done |
| **Containerization** — one shared Docker entrypoint (was 40+ copies of the same `echo`-chain), non-root containers, healthchecks, resource limits | Done |
| **Lean packing** — defaults that fit the booking path on ~8 GiB hosts (see below) | Done |
| **CI/CD** — GitHub Actions build+test gate; Docker publish pushes the **full** service matrix to Hub on `main`/`feat` (and on `v*` tags) | Done (see below) |
| **Supply chain** — CodeQL, dependency/secret/config/container scanning, SBOM/provenance, and keyless digest signing | Done |
| **Kubernetes + Helm** — manifests for the core booking path, then the full service set, then a Helm chart | Planned, next up |
| **Observability** — distributed tracing, Prometheus/Grafana, structured logs keyed on the request-ID work already in place | Planned |
| **MLOps** — demand forecasting → dynamic pricing, a genuinely new feature (not a port of upstream), with a real train → register → serve → monitor → retrain loop | Planned |

## Why the lean Docker defaults exist

The full 46-service set wants more RAM than a typical laptop or small VM has. Rather than pretend otherwise, the compose + entrypoint defaults are tuned so the **booking path** can come up on ~8 GiB:

- Shared `dockerfile/entrypoint.sh` gives every Java service a small SerialGC heap (`-Xmx128m` by default) and uses `spring.config.additional-location` so in-jar config (gateway routes especially) is not wiped.
- Compose caps Java apps around **320 MiB** (gateway a bit higher). Earlier we tried 192 MiB — that was below heap + metaspace and the kernel OOM-killed containers.
- Nacos' image defaults young-gen / metaspace huge (`JVM_XMN=512m`). We override those or it dies under a 640 MiB limit.
- Kafka and Zipkin sit behind Compose profile `full-infra` — useful later, not required for login → search → book → pay.
- `/actuator/health` is permitted without a JWT so Docker healthchecks mean something. Public APIs stay behind the same security rules as before.

If you have a bigger machine and want everything, use `./scripts/up-docker.sh` instead of the lean script.

## Quick start (Docker)

```bash
cp .env.example .env
# Set JWT_SECRET to something real (or leave the example for local scratch only)

# First time / after Java changes: build jars into jar/, then images
./scripts/build.sh all          # or a subset
./scripts/deploy.sh all
docker compose -f docker-compose.build.yml build

./scripts/up-lean.sh            # booking-path stack on small hosts
# or: ./scripts/up-docker.sh    # full app set
```

- **UI:** http://localhost:8080
- **Gateway:** http://localhost:18888
- **Nacos:** http://localhost:8848/nacos (`nacos` / `nacos`)

Sanity check once things have finished registering (first boot is slow — JVMs on a tight heap take a few minutes each):

```bash
./scripts/smoke-java-core.sh
```

Stop: `./scripts/down-docker.sh`

More detail: [docs/DOCKER.md](docs/DOCKER.md), [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md).

## CI/CD

Three GitHub Actions workflows live in [`.github/workflows/`](.github/workflows/):

- **`ci.yml`** — path-filtered `mvn verify` with JaCoCo XML for Java, plus ESLint, typechecking, tests, and build for the SPA.
- **`security.yml`** — CodeQL, dependency review, full-history Gitleaks, strict Trivy filesystem/configuration scans, and Hadolint; also runs weekly.
- **`docker-publish.yml`**
  - **Push to `main` or `feat`** → **full** matrix: all ~41 Java services + news/voucher/avatar/ticket-office + SPA (`ts-ui-web` + legacy `ts-ui-dashboard` alias)
  - **Tag `vX.Y.Z`** → same full set with semver tags
  - **Actions → Run workflow** → choose `full` (default) or `core` for a quick subset smoke
  - Images first receive immutable `sha-<full-commit>` tags with SBOM and provenance attestations. Trivy then scans the digest, Cosign signs and verifies it with GitHub OIDC, and only successful images receive `X.Y.Z`, `X.Y`, or `latest` aliases.

To actually push images, set both as **secrets** under **Settings → Secrets and variables → Actions → Secrets**:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (a Docker Hub access token, not your password)

Without them, the workflow still builds images (proving the Dockerfiles work) — it just skips the push. Without Hub creds, the SPA job also smoke-checks `/` via a local `docker run`.

## Documentation

All guides live under **[docs/](docs/README.md)**:

- [Getting started](docs/GETTING-STARTED.md) — Docker, local JARs, single services
- [Docker](docs/DOCKER.md) — lean vs full stack, build, Hub push
- [Security and supply chain](docs/SECURITY.md) — gates, local SonarQube, SBOMs, signatures
- [Non-Java services](docs/NON-JAVA-SERVICES.md) — UI, news, avatar, voucher, ticket-office
- [Local development](docs/LOCAL-DEVELOPMENT.md) — local-JAR workflow
- [Ports](docs/PORTS.md)
- [Deployment overview](docs/DEPLOYMENT.md)

## Layout

| Path | Purpose |
|------|---------|
| `ts-*-service/` | Microservice source |
| `ts-ui-web/` | Modern SPA (Bun + Vite + Vue 3 + TS); legacy UI under `legacy/` |
| `dockerfile/` | Central Dockerfiles (`Dockerfile.Ts.*`) + shared `entrypoint.sh` |
| `.github/workflows/` | CI (`ci.yml`) and Docker build/publish (`docker-publish.yml`) |
| `docker-compose.build.yml` | Build + run apps (includes minimal infra) |
| `docker-compose.minimal.yml` | MySQL, Nacos, Redis, RabbitMQ (Kafka/Zipkin optional) |
| `properties/` | `*.application.ini` for token replacement at container start |
| `scripts/` | Build, deploy jars, up/down, smoke tests |
| `jar/` | Staged JARs for Docker builds (from `./scripts/deploy.sh`) |
| `.env` | Local overrides (from `.env.example`; never commit) |

> During development, a plain clone of upstream lives as a sibling directory (`../train-ticket/`, outside this repo) purely as a read-only reference for feature parity and API contract checks — it's not part of this repo and isn't needed to build or run anything here.

## Build Java services

```bash
mvn clean package -DskipTests
# or
./scripts/build.sh all
./scripts/deploy.sh all   # copies target/*.jar → jar/ts-*-service.jar
```

## Push images to Docker Hub (manual, local alternative to CI)

```bash
# .env: IMG_REPO=<your-dockerhub-username> IMG_TAG=0.2.0
docker login
./scripts/docker-build-push.sh
```

## Credit

Built on **[FudanSELab/train-ticket](https://github.com/FudanSELab/train-ticket)** (Apache-2.0). This repo is a derivative work — the [`LICENSE`](LICENSE) is carried forward unchanged.
