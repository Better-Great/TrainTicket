# TT-001 — Gateway routes for missing services

**Status:** Done  
**Date:** 2026-07-08

## What

Added Spring Cloud Gateway routes in `ts-gateway-service/src/main/resources/application.yml`:

- `waitorderservice` — Nacos `lb://`
- `fooddeliveryservice` — Nacos `lb://`
- `voucherservice` — direct HTTP + rewrite to `/getVoucher`
- `ticketofficeservice` — direct HTTP + rewrite to `/office/`
- `newsservice` — direct HTTP + rewrite to `/`
- Legacy paths: `/getVoucher`, `/office/**`, `/news-service/**`

## Why

Polyglot and wait-order services were unreachable from UI port 8080. Gateway is the single API entry.

## Verify

```bash
curl http://localhost:18888/api/v1/waitorderservice/welcome
curl http://localhost:18888/news-service/news
```
