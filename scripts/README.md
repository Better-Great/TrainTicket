# Scripts

| Script | Purpose |
|--------|---------|
| **`up-lean.sh`** | Infra + booking-path apps (~8 GiB hosts) |
| **`up-docker.sh`** | Full stack from `docker-compose.build.yml` |
| **`down-docker.sh`** | Stop the Compose stack |
| **`docker-build-push.sh`** | Build + push images (`IMG_REPO` / `IMG_TAG` in `.env`) |
| `build.sh` | Maven-build service JARs |
| `deploy.sh` | Copy `target/*.jar` → `jar/ts-*-service.jar` for Docker |
| `quality-scan.sh` | Test Java/UI, start isolated local SonarQube, scan, and wait for its quality gate |
| `smoke-java-core.sh` | Direct + gateway welcome paths + JWT 401 gates |
| `init-databases.sh` | Create schemas in the Docker MySQL |
| `init-databases-local.sh` | Same for a host MySQL |
| `start-java-core-local.sh` / `start-gateway-local.sh` | Run core JARs on the host |
| `start-local.sh` / `start.sh` / `stop.sh` / `status.sh` | Broader local process helpers |

For a local quality scan, export non-empty `SONAR_DB_PASSWORD` and a `SONAR_TOKEN`
created in the local SonarQube UI, then run `./scripts/quality-scan.sh`. The quality
Compose file starts only PostgreSQL and SonarQube; stop them with
`docker compose -f docker-compose.quality.yml down`.

Guides: [docs/GETTING-STARTED.md](../docs/GETTING-STARTED.md), [docs/DOCKER.md](../docs/DOCKER.md), [docs/PORTS.md](../docs/PORTS.md).
