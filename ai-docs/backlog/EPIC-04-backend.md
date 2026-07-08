# EPIC-04 — Backend Hardening

**Status:** Backlog  
**Sprint:** S6

## Goal

Fix 2017-era security, schema, saga, and dependency debt.

## Security (TT-501–516)

| ID | Title | Priority |
|----|-------|----------|
| TT-501 | Gateway JWT filter (centralize auth) | P1 |
| TT-504 | Replace fastjson with Jackson | P0 |
| TT-509 | Gateway CORS, request ID, legacy rewrite | P1 |
| TT-511 | JWT secret from env/vault | P0 |
| TT-512 | CORS allowlist | P1 |
| TT-513 | Lock Swagger to dev profile | P2 |
| TT-514 | Remove default credentials | P2 |
| TT-515 | Secrets via Docker secrets | P1 |
| TT-516 | SPA token storage hardening | P1 |

## Platform (TT-505–532)

| ID | Title | Priority |
|----|-------|----------|
| TT-502 | Preserve/cancel async RabbitMQ | P1 |
| TT-503 | Wait-list PollThread complete | P2 |
| TT-505 | Spring Boot 2.7 bridge | P1 |
| TT-506 | springdoc-openapi | P1 |
| TT-507 | Liquibase in Docker (disable ddl-auto) | P1 |
| TT-508 | Real news service | P3 |
| TT-510 | prod compose: expose :8080 only | P2 |
| TT-517–521 | WebClient, Nacos lb, circuit breaker, idempotency, trace ID | P1–P2 |
| TT-522–531 | Java 17, Kafka/Redis, config, contracts, SBOM, actuator | P2–P3 |
| TT-532 | Search/booking BFF (hide G/D split) | P1 |

See `FLAWS-AUDIT.md` for full mapping.
