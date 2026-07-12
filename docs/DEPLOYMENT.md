# Deployment overview

```
Local JARs  →  Docker Compose (lean or full)  →  Kubernetes (planned)
```

| Mode | When | Entry |
|------|------|--------|
| **Lean Docker** | Day-to-day on ≤8 GiB | `./scripts/up-lean.sh` — [GETTING-STARTED.md](GETTING-STARTED.md) |
| **Full Docker** | Bigger hosts / full matrix | `./scripts/up-docker.sh` |
| **Local JARs** | Debugging one service | [LOCAL-DEVELOPMENT.md](LOCAL-DEVELOPMENT.md) |
| **Kubernetes** | Clusters | Planned (Helm next on the roadmap) |

## Docker (what we actually run)

```bash
cp .env.example .env          # set JWT_SECRET
./scripts/build.sh all && ./scripts/deploy.sh all
docker compose -f docker-compose.build.yml build
./scripts/up-lean.sh
./scripts/smoke-java-core.sh
```

Why lean exists (heap vs cgroup, Nacos, gateway routes): [DOCKER.md](DOCKER.md).

## Config at runtime

Containers do **not** need a pre-generated `application.properties` on the host. The shared entrypoint runs `ts-token-replacement-service` against `properties/<env>.application.ini` on every start.

For a one-off local expand (IDE / jar on host):

```bash
./ts-token-replacement-service/replace-tokens.sh docker
```

## Minimal dependency chain

```
MySQL → Nacos → microservices → Gateway (18888) → UI (8080)
```
