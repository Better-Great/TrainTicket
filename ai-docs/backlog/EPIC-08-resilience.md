# EPIC-08 — Resilience & Sagas

**Status:** Backlog  
**Sprint:** S6

## Goal

Async sagas, circuit breakers, idempotency, east-west via Nacos.

## Tickets

| ID | Title | Status |
|----|-------|--------|
| TT-502 | Preserve/cancel → async RabbitMQ | Backlog |
| TT-517 | WebClient + resilience4j (replace RestTemplate) | Backlog |
| TT-518 | East-west via Nacos `lb://` | Backlog |
| TT-519 | Sentinel/circuit breaker on all routes | Backlog |
| TT-520 | Idempotency keys on preserve/pay | Backlog |
| TT-521 | Request ID propagation (gateway → MDC → Zipkin) | Backlog |
| TT-525 | Contract tests (preserve → order → seat) | Backlog |

## Preserve saga (current)

Sync chain in `PreserveServiceImpl`: security → contacts → trip → seat → order → assurance/food/consign → notify.

**Target:** Async side-effects via RabbitMQ; resilient HTTP via WebClient + retry/circuit breaker.
