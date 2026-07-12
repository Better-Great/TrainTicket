# Local development (without app containers)

Run microservices as **JARs** or **local processes** on the host, with infrastructure in Docker.

## Scripts

| Script | Purpose |
|--------|---------|
| `./scripts/build.sh all` | Maven build all Java services |
| `./scripts/init-databases-local.sh` | Create DBs on local MySQL |
| `./scripts/start-local.sh` | Start all services (background, writes `.services.pid`) |
| `./scripts/start.sh` | Alternate starter (JAR-based) |
| `./scripts/status.sh` | Check which ports are listening |
| `./scripts/stop.sh` | Stop processes from `.services.pid` |
| `./scripts/check-databases-local.sh` | Verify DB connectivity |

## Typical flow

```bash
# 1. Infrastructure
cp .env.example .env
docker compose -f docker-compose.minimal.yml up -d mysql nacos

# 2. Build
./scripts/build.sh all

# 3. Databases
./scripts/init-databases-local.sh

# 4. Start apps
./scripts/start-local.sh

# 5. UI (if not started by script)
./ts-ui-dashboard/run-local.sh
```

For **minimal login flow** (gateway, auth, user, verification, UI only), start those JARs manually or trim `start-local.sh` — see [PORTS.md](PORTS.md).

## Logs

Background runs log to `logs/<service>.log` when using `start.sh` / `start-local.sh`.

## vs Docker

Prefer **`./scripts/up-lean.sh`** on small hosts, or **`./scripts/up-docker.sh`** when you want the full stack without installing Java/Maven on the host. See [GETTING-STARTED.md](GETTING-STARTED.md).
