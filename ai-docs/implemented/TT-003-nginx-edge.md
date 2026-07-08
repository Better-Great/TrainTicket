# TT-003 — nginx edge proxy via gateway

**Status:** Done  
**Date:** 2026-07-08

## What

Updated `ts-ui-dashboard/nginx.conf` so all API traffic routes through the gateway. Static files only for `/`.

## Changes

- `/api/` → `ts-gateway-service:18888` (was `/api/v1/` only)
- `/getVoucher`, `/office/`, `/news-service/` → gateway (legacy compat)
- `try_files` for SPA fallback readiness
- Proxy headers: Host, X-Real-IP, X-Forwarded-*

## Why

nginx must not be a second API router to individual services. Single north-south entry at gateway (ADR-001).

## Verify

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/          # 200
curl -s http://localhost:8080/news-service/news                         # JSON news
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/v1/verifycode/generate
```

Requires gateway healthy (may take 2–3 min after start).
