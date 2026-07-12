# TrainTicket documentation

| Doc | Use when |
|-----|----------|
| [GETTING-STARTED.md](GETTING-STARTED.md) | First run — prefer `up-lean.sh` on small hosts |
| [DOCKER.md](DOCKER.md) | Why lean defaults exist; build / Hub / compose |
| [NON-JAVA-SERVICES.md](NON-JAVA-SERVICES.md) | UI, news, avatar, voucher, ticket-office |
| [LOCAL-DEVELOPMENT.md](LOCAL-DEVELOPMENT.md) | JARs on the host without full Compose |
| [PORTS.md](PORTS.md) | Port reference |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Local → Docker → (planned) Kubernetes |
| [info/services.md](info/services.md) | Service catalogue |

Root story and roadmap: **[../README.md](../README.md)**.

Config: copy `.env.example` → `.env`, set `JWT_SECRET`, then `./scripts/up-lean.sh` or `./scripts/up-docker.sh`.
