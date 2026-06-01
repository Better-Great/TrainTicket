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

Full documentation: **[../docs/GETTING-STARTED.md](../docs/GETTING-STARTED.md)** and **[../docs/LOCAL-DEVELOPMENT.md](../docs/LOCAL-DEVELOPMENT.md)**.

Port list: **[../docs/PORTS.md](../docs/PORTS.md)**.
