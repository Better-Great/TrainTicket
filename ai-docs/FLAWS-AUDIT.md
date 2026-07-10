# Architectural Flaws Audit

2017–2021 FudanSELab benchmark → 2026 modernization targets.

**Legend:** `Open` | `In Progress` | `Fixed` | `Won't Fix` (intentional benchmark design)

---

## Critical — security / data integrity

| Flaw | Evidence | Ticket | Status |
|------|----------|--------|--------|
| Hardcoded JWT secret `"secret"` | `ts-common/.../JWTUtil.java:31` | TT-511 | Open |
| fastjson 1.2.31 (CVE history) | `pom.xml` | TT-504 | Open |
| CORS `allowedOrigins("*")` | per-service `SecurityConfig.java` | TT-512 | Open |
| Swagger UI `permitAll()` | per-service SecurityConfig | TT-513 | Open |
| Default passwords in docs/UI | `fdse_microservice` / `111111` | TT-406, TT-514 | Open |
| Secrets in plaintext `.env` / `application.ini` | `properties/` | TT-515 | Open |
| JWT in `sessionStorage` (XSS) | `client_common.js` | TT-516 | Open |

---

## High — architecture / reliability

| Flaw | Evidence | Ticket | Status |
|------|----------|--------|--------|
| Split API routing (nginx + gateway) | `nginx.conf` | TT-001–004, TT-007 | In Progress |
| Auth duplicated in 40+ services | per-service `JWTFilter` | TT-501 | Open |
| Blocking `RestTemplate` saga chains | `PreserveServiceImpl.java` | TT-517 | Open |
| East-west hardcoded host:port | `@Value` in service impls | TT-518 | Open |
| No circuit breaker (Sentinel on 1 route) | `GatewayConfiguration.java` | TT-519 | Open |
| `ddl-auto=update` despite Liquibase | `application.properties.ini` | TT-507 | Open |
| Preserve/cancel sync TODOs | preserve, cancel services | TT-502 | Open |
| No idempotency on preserve/pay | preserve flow | TT-520 | Open |
| No request ID / trace correlation | — | TT-521 | Open |
| Incomplete wait-list poller | `PollThread.java` TODO | TT-503 | Open |
| Gateway Sentinel init crash | `GatewayConfiguration.java` | — | Fixed (catch + `/tmp/sentinel`) |
| Log bind mount permission denied | `log/ts-gateway-service/` | TT-526 | In Progress |

---

## Medium — ops / maintainability

| Flaw | Evidence | Ticket | Status |
|------|----------|--------|--------|
| Spring Boot 2.3 + Springfox EOL | `pom.xml` | TT-505, TT-506 | Open |
| Java 8 compile / Java 17 runtime | `pom.xml` vs Dockerfiles | TT-522 | Open |
| 46 containers, no lean dev profile | `docker-compose.build.yml` | TT-706 | Open |
| Kafka + Redis barely used | `docker-compose.minimal.yml` | TT-523 | Open |
| Token-replacement JAR config | container entrypoint | TT-524 | Open |
| Every service port on host | compose file | TT-510 | Open |
| No CI/CD, E2E, contract tests | repo root | TT-601, TT-606, TT-525 | Open |
| K8s docs, no `k8s/` dir | `docs/DEPLOYMENT.md` | TT-604 | Open |
| Three UI frameworks | `ts-ui-web/legacy/` (was ts-ui-dashboard) | TT-101–407 | In Progress |
| G/D split leaks to client | `index.js` | TT-532 | Open |
| No OpenAPI → TS client | manual JS | TT-527 | Open |
| `Response<T>` no error codes | `ts-common` | TT-528 | Open |

---

## Low — quality / future

| Flaw | Ticket | Status |
|------|--------|--------|
| News hardcoded JSON | TT-508 | Open |
| No pagination on admin lists | TT-529 | Open |
| No SBOM / dependency scanning | TT-530 | Open |
| `ts-delivery-service` MQ-only | TT-531 | Open |

---

## Intentional (Won't Fix)

- Database-per-service (40+ MySQL schemas)
- Dual G/D travel/order service split
- RabbitMQ notification side-effects
- Nacos service discovery
- Polyglot services (heterogeneity benchmark)
