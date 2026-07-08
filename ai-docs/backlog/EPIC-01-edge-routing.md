# EPIC-01 — Edge Routing & Gateway

**Status:** In Progress — code merged locally; **smoke tests not green yet**  
**Sprint:** S0

## Goal

Single north-south API entry via `ts-gateway-service`. UI nginx proxies to gateway only; static files for `/`.

## Tickets

| ID | Title | Status |
|----|-------|--------|
| TT-001 | Add wait-order, food-delivery, voucher, news, ticket-office routes | Done |
| TT-002 | Normalize `/api/v1/` paths + legacy rewrites | Done |
| TT-003 | nginx: `/api/` + legacy → gateway; static for `/` | Done |
| TT-004 | Optional dedicated edge container on :8080 | Backlog |
| TT-006 | Port docs vs `.env` alignment | Backlog |

## Route map

### Java (Nacos lb://)

- `/api/v1/waitorderservice/**`
- `/api/v1/fooddeliveryservice/**`

### Polyglot (direct http://)

| Path | Backend |
|------|---------|
| `/api/v1/voucherservice/voucher` → `/getVoucher` | ts-voucher-service:16101 |
| `/getVoucher` (legacy) | ts-voucher-service |
| `/api/v1/ticketofficeservice/**` → `/office/**` | ts-ticket-office-service:16108 |
| `/office/**` (legacy) | ts-ticket-office-service |
| `/api/v1/newsservice/**` → `/` | ts-news-service:12862 |
| `/news-service/**` (legacy) | ts-news-service |

## nginx (transitional)

File: `ts-ui-dashboard/nginx.conf`

- `/api/` → gateway
- `/getVoucher`, `/office/`, `/news-service/` → gateway
- `/` → static

## Verify

```bash
./scripts/smoke-test-routes.sh
```

## Implemented

- [TT-001-gateway-routes.md](../implemented/TT-001-gateway-routes.md)
- [TT-003-nginx-edge.md](../implemented/TT-003-nginx-edge.md)
