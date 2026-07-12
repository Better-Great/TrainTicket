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
| **Containerization** — one shared Docker entrypoint script (was 40+ copies of the same `echo`-chain), non-root containers, healthchecks, resource limits, a stale/broken legacy compose file removed | Done |
| **CI/CD** — GitHub Actions build+test gate; Docker publish with **core** matrix on `main` and **full** matrix on `v*` tags / manual dispatch | Done (see below) |
| **Kubernetes + Helm** — manifests for the core booking path, then the full service set, then a Helm chart | Planned, next up |
| **Observability** — distributed tracing, Prometheus/Grafana, structured logs keyed on the request-ID work already in place | Planned |
| **MLOps** — demand forecasting → dynamic pricing, a genuinely new feature (not a port of upstream), with a real train → register → serve → monitor → retrain loop | Planned |

## Quick start (Docker)

```bash
cp .env.example .env
docker compose -f docker-compose.build.yml build   # first time
./scripts/up-lean.sh          # dense booking-path stack (~8GiB hosts)
# or full stack: ./scripts/up-docker.sh
```

- **UI:** http://localhost:8080
- **Gateway:** http://localhost:18888
- **Nacos:** http://localhost:8848/nacos

Stop: `./scripts/down-docker.sh`

## CI/CD

Two GitHub Actions workflows live in [`.github/workflows/`](.github/workflows/):

- **`ci.yml`** — on push/PR to `main`/`feat`: path-filtered `mvn compile` + `mvn test` for Java, and `bun run check` for the SPA (both always run on `main`).
- **`docker-publish.yml`**
  - **Push to `main`** → **core** booking-path images only (gateway, auth, preserve/pay/inside-pay, order, travel/basic/station/seat, news, voucher, SPA) — fast and cheap.
  - **Tag `vX.Y.Z`** or **Actions → Run workflow (`full`)** → full ~46-service matrix for a release.
  - Images are versioned (`X.Y.Z`, `X.Y`, `sha-<short>`, `latest` on `main`). SPA publishes as **`ts-ui-web`** (primary) and **`ts-ui-dashboard`** (legacy alias).

To actually push images, set these in the repo's **Settings → Secrets and variables → Actions**:
- `DOCKERHUB_USERNAME` (as a repository **variable**, not secret — it's not sensitive)
- `DOCKERHUB_TOKEN` (as a **secret** — a Docker Hub access token, not your password)

Without them, the workflow still builds images (proving the Dockerfiles work) — it just skips the push step. On core runs without Hub creds, the SPA job also smoke-checks `/` via a local `docker run`.

## Documentation

All guides live under **[docs/](docs/README.md)**:

- [Getting started](docs/GETTING-STARTED.md) — Docker, local JARs, single services
- [Docker](docs/DOCKER.md) — build, push to Docker Hub, compose
- [Non-Java services](docs/NON-JAVA-SERVICES.md) — UI, news, avatar, voucher, ticket-office
- [Local development](docs/LOCAL-DEVELOPMENT.md) — local-JAR workflow
- [Ports](docs/PORTS.md)
- [Deployment overview](docs/DEPLOYMENT.md)

## Layout

| Path | Purpose |
|------|---------|
| `ts-*-service/` | Microservice source |
| `ts-ui-web/` | Modern SPA (Bun + Vite + Vue 3 + TS); legacy UI under `legacy/` |
| `dockerfile/` | Central Dockerfiles (`Dockerfile.Ts.*`) + the shared `entrypoint.sh` |
| `.github/workflows/` | CI (`ci.yml`) and Docker build/publish (`docker-publish.yml`) |
| `docker-compose.build.yml` | Build + run apps + minimal infra |
| `docker-compose.minimal.yml` | MySQL, Nacos, messaging only |
| `properties/` | `*.application.ini` for token replacement / Docker |
| `scripts/` | Build, start/stop, DB init, `up-docker.sh` |
| `.env` | Local overrides (from `.env.example`) |

> During development, a plain clone of upstream lives as a sibling directory (`../train-ticket/`, outside this repo) purely as a read-only reference for feature parity and API contract checks — it's not part of this repo and isn't needed to build or run anything here.

## Build Java services

```bash
mvn clean package -DskipTests
# or
./scripts/build.sh all
```

## Push images to Docker Hub (manual, local alternative to CI)

```bash
# .env: IMG_REPO=<your-dockerhub-username> IMG_TAG=0.2.0
docker login
./scripts/docker-build-push.sh
```

## Credit

Built on **[FudanSELab/train-ticket](https://github.com/FudanSELab/train-ticket)** (Apache-2.0). This repo is a derivative work — the [`LICENSE`](LICENSE) is carried forward unchanged.
