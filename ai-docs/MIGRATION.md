# New Server Setup

Use this when continuing work on a different machine.

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Git | any | Clone repo |
| Docker + Compose | v2+ | Run stack |
| Java | 17 | Maven builds |
| Maven | 3.6+ | Build Java services |
| Bun | 1.x | **After TT-101** — SPA scaffold |

## 1. Clone and branch

```bash
git clone git@github.com:Better-Great/TrainTicket.git
cd TrainTicket
git checkout feat   # or your working branch
git pull
```

If `ai-docs/` is missing, the pre-migration commit was not pushed — recover from backup or re-read Cursor plan.

## 2. Environment

```bash
cp .env.example .env
# Edit .env if needed — defaults work for local Docker
```

Key ports (from `.env.example`):

| Service | Port |
|---------|------|
| UI | 8080 |
| Gateway | 18888 |
| Nacos | 8848 |
| MySQL | 3307 |
| News | 12862 |

**Note:** `docs/PORTS.md` lists auth as 12340; `.env` uses 12349. Prefer `.env` / compose.

## 3. Build gateway (if not using pre-built image)

```bash
mvn package -pl ts-gateway-service -am -DskipTests
cp ts-gateway-service/target/ts-gateway-service-*.jar jar/ts-gateway-service.jar
docker compose -f docker-compose.build.yml build ts-gateway-service ts-ui-dashboard
```

## 4. Start stack

### Full stack (slow first time — pulls ~46 images)

```bash
./scripts/up-docker.sh
```

### Smoke-test subset (faster)

```bash
docker compose -f docker-compose.build.yml up -d mysql nacos rabbitmq redis \
  ts-gateway-service ts-ui-dashboard ts-news-service ts-voucher-service \
  ts-ticket-office-service ts-wait-order-service ts-food-delivery-service
```

**Wait ~25s** for Nacos healthy, then **~2–3 min** for gateway Spring Boot startup on modest hardware.

## 5. Verify

```bash
./scripts/smoke-test-routes.sh
curl -s http://localhost:18888/actuator/health
curl -s http://localhost:8080/
```

## 6. AI agent onboarding

Read in order:

1. [`HANDOFF.md`](HANDOFF.md)
2. [`AUDIT.md`](AUDIT.md) — honest status
3. [`ARCHITECTURE.md`](ARCHITECTURE.md)
4. [`backlog/EPIC-02-frontend-spa.md`](backlog/EPIC-02-frontend-spa.md) — next work (TT-101)

## Reference repo (read-only)

Sibling clone or path:

```
../train-ticket/    # Original FudanSELab benchmark — DO NOT EDIT
```

## Common issues

| Symptom | Fix |
|---------|-----|
| Gateway exit 1, Sentinel NPE | Fixed in `GatewayConfiguration.java` — ensure latest code |
| Gateway slow / 502 from UI | Wait 2–3 min; check `docker logs ts-gateway-service` |
| Nacos unhealthy | Wait longer; `docker logs nacos-standalone` |
| `log/` permission errors | Sentinel uses `/tmp/sentinel`; ignore or `chmod` host log dirs |
| Polyglot 502 | Check service containers up: `docker ps` |

## Docker Hub images

Compose uses `bettergreat/*:0.2.0` by default (`IMG_REPO`, `IMG_TAG` in `.env`). Gateway/UI with local changes must be **rebuilt** — pulling alone won't include S0 route changes.
