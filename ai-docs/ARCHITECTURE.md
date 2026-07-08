# TrainTicket Architecture

**Reference (read-only):** `../train-ticket/`  
**Working tree:** `../TrainTicket/`

## Current state (transitional)

```
Browser :8080
    └── ts-ui-dashboard (nginx)
            ├── /api/**           → ts-gateway-service:18888
            ├── /getVoucher       → gateway (legacy)
            ├── /office/**        → gateway (legacy)
            ├── /news-service/**  → gateway (legacy)
            └── /*                → static HTML (Vue2 + jQuery + AngularJS)
```

```
ts-gateway-service :18888
    ├── lb://{service}     → 41 Java microservices (Nacos)
    └── http://host:port   → voucher, ticket-office, news (no Nacos)
```

```
Service-to-service (east-west)
    └── RestTemplate → hostname:port from properties/docker.application.ini
```

## Target state

```
Browser :8080
    └── Edge (Caddy or nginx-static)
            ├── /api/**  → ts-gateway-service (internal)
            └── /*       → ts-ui-web dist/ (Bun + Vue 3 SPA)

Dev: bun run dev :5173 → Vite proxy /api → gateway :18888
```

## Routing rules

1. **Browser never calls service ports directly** in production.
2. **Gateway owns all north-south API routing.**
3. **Static server never proxies to individual services** — only to gateway.
4. **East-west** stays direct (RestTemplate) — gateway is north-south only.

## G/D train split (intentional benchmark design)

| Trip ID prefix | Travel | Preserve | Order |
|----------------|--------|----------|-------|
| G or D | `travelservice` | `preserveservice` | `orderservice` |
| Other | `travel2service` | `preserveotherservice` | `orderOtherService` |

**Target (TT-532):** Hide this in a gateway BFF — `POST /api/v1/search/trips/left`.

## Polyglot path map

| Legacy path | Normalized path | Service |
|-------------|-----------------|---------|
| `POST /getVoucher` | `POST /api/v1/voucherservice/voucher` | ts-voucher-service |
| `GET /office/**` | `/api/v1/ticketofficeservice/**` | ts-ticket-office-service |
| `GET /news-service/**` | `/api/v1/newsservice/**` | ts-news-service |

## Service inventory (46 deployable)

| Category | Count | Examples |
|----------|-------|----------|
| Java microservices | 41 | preserve, order, travel, admin BFFs |
| Gateway | 1 | ts-gateway-service |
| UI | 1 | ts-ui-dashboard → ts-ui-web (planned) |
| Polyglot | 4 | news (Go), voucher (Python), ticket-office (Node→Bun), avatar (Python) |
| Shared lib | 1 | ts-common (not deployed) |
| Config tooling | 1 | ts-token-replacement-service |

## Infrastructure (Docker Compose)

| Component | Purpose |
|-----------|---------|
| MySQL 8 | Database-per-service (~25 schemas) |
| Nacos | Service discovery |
| RabbitMQ | Async notifications, delivery |
| Redis | Provisioned, lightly used |
| Kafka | Provisioned, lightly used |
| Zipkin | Tracing infra, lightly used |

## API contract

Standard envelope from `ts-common`:

```json
{ "status": 1, "msg": "Success", "data": { } }
```

`status`: 1 = success, 0 = failure.

## Key files

| File | Role |
|------|------|
| `ts-gateway-service/src/main/resources/application.yml` | Route table |
| `ts-ui-dashboard/nginx.conf` | Edge proxy (transitional) |
| `properties/docker.application.ini` | Docker network config |
| `docker-compose.build.yml` | Full stack compose |
| `docker-compose.minimal.yml` | Infra only |
