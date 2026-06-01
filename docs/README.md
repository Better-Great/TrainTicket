# TrainTicket documentation

| Doc | Use when |
|-----|----------|
| [GETTING-STARTED.md](GETTING-STARTED.md) | **Start here** — Docker stack or local JARs |
| [DOCKER.md](DOCKER.md) | Build, push (`bettergreat/*`), and run with Compose |
| [NON-JAVA-SERVICES.md](NON-JAVA-SERVICES.md) | UI, news, avatar, voucher, ticket-office |
| [LOCAL-DEVELOPMENT.md](LOCAL-DEVELOPMENT.md) | `scripts/start.sh`, `stop.sh`, `status.sh` (no Docker) |
| [PORTS.md](PORTS.md) | Port reference |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Local → Docker → Kubernetes overview |
| [info/services.md](info/services.md) | Service catalogue |

Root config: copy `.env.example` → `.env`, then use `scripts/up-docker.sh` or `./scripts/docker-build-push.sh`.
