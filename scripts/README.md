# Scripts

| Script | Purpose |
|--------|---------|
| **`up-docker.sh`** | Start full stack (`docker-compose.build.yml`) |
| **`down-docker.sh`** | Stop full stack |
| **`docker-build-push.sh`** | Build + push images (`IMG_REPO` / `IMG_TAG` in `.env`) |
| `build.sh` | Maven build JARs |
| `start-local.sh` / `start.sh` | Run JARs on host |
| `stop.sh` / `status.sh` | Stop / check local processes |
| `init-databases-local.sh` | Local MySQL schemas |
| `init-databases.sh` | Docker MySQL init helper |
| `start-java-core-local.sh` | Local Stage B/C Java (search + booking + auth) |
| `start-gateway-local.sh` | Gateway with HTTP URI overrides |
| `start-polyglot-local.sh` | News / office / voucher |
| `smoke-java-core.sh` | Core + booking welcome + JWT gate smoke |

Full documentation: **[../docs/GETTING-STARTED.md](../docs/GETTING-STARTED.md)** and **[../docs/LOCAL-DEVELOPMENT.md](../docs/LOCAL-DEVELOPMENT.md)**.

Port list: **[../docs/PORTS.md](../docs/PORTS.md)**.
