# Pre-Migration Audit — Read Before Changing Servers

**Audit date:** 2026-07-09  
**Branch:** `feat` (uncommitted changes — see below)

## Confidence summary

| Area | Confidence | Notes |
|------|------------|-------|
| **Plan & parity checklist** | High | Audited against all 22 HTML pages + reference `train-ticket/` |
| **Architecture direction** | High | Gateway-first routing is correct; matches ADRs |
| **ai-docs completeness** | High | All epics, flaws, parity, sessions structure present |
| **Code changes (S0)** | Medium | In repo, builds, but **not fully verified** by passing smoke tests |
| **Runtime on new server** | Medium | Requires rebuild, `.env`, slow first Docker pull, Nacos warm-up |

**Bottom line:** The **plan is solid** for continuing work. The **S0 implementation is code-complete but not production-verified**. Do not assume smoke tests passed.

---

## What is actually implemented (code in repo)

| Item | File(s) | Verified running? |
|------|---------|-------------------|
| Gateway routes (wait-order, food-delivery, polyglot) | `ts-gateway-service/.../application.yml` | Partial — gateway slow-start; smoke failed on WSL |
| nginx edge proxy | `ts-ui-dashboard/nginx.conf` | Partial — UI :8080 OK; API 502 until gateway up |
| Sentinel startup fix | `GatewayConfiguration.java`, `Dockerfile.Ts.Gateway.Service` | Yes — gateway starts past Sentinel |
| ai-docs tree | `ai-docs/**` | N/A |
| smoke script | `scripts/smoke-test-routes.sh` | Written, not green yet |
| ts-ui-web (Bun SPA) | — | **Not started** |
| CI/CD, k8s | — | **Not started** |

---

## Uncommitted / untracked (MUST commit or copy before server move)

```bash
git status --short
# Modified:
#   dockerfile/Dockerfile.Ts.Gateway.Service
#   ts-gateway-service/.../GatewayConfiguration.java
#   ts-gateway-service/.../application.yml
#   ts-ui-dashboard/nginx.conf
# Untracked:
#   ai-docs/
#   scripts/smoke-test-routes.sh
```

Also rebuilt locally (usually gitignored):

- `jar/ts-gateway-service.jar` — run `mvn package -pl ts-gateway-service -am -DskipTests` on new server OR `docker compose build ts-gateway-service`

---

## Known inaccuracies still in repo (documented, not fixed)

### Port mismatches (TT-006 backlog)

| Source | Auth | News | Wait-order | Food-delivery |
|--------|------|------|------------|---------------|
| `docs/PORTS.md` | 12340 | — | 16804 | — |
| `.env.example` | 12349 | 12862 | (check .env) | (check .env) |
| `docker-compose.build.yml` | 12349 | 12862 | 16804 | 16803 |
| `properties/docker.application.ini` | — | **16900** | **17525** | **18957** |
| Gateway YAML defaults (polyglot) | — | 12862 | — | — |

**Impact:** Gateway polyglot routes use YAML defaults (match compose). East-west `RestTemplate` calls use `docker.application.ini` — **stale ports there can break service-to-service calls** even when gateway routes work.

### Pre-existing issues (not introduced by S0)

| Issue | Detail |
|-------|--------|
| Avatar via `lb://` | `ts-avatar-service` does **not** register Nacos; gateway route may fail |
| JWT secret `"secret"` | `JWTUtil.java` — security debt |
| 46-container stack | Heavy for dev; no lean profile yet (TT-706) |
| No `k8s/` dir | Despite `docs/DEPLOYMENT.md` reference |

### RewritePath — needs runtime confirmation

Ticket-office rewrite uses `$\{segment}` in YAML. Logic is correct per Spring Cloud Gateway docs but **not curl-verified** end-to-end after gateway warm-up.

---

## Parity checklist accuracy

Verified against TrainTicket + train-ticket reference:

- 10 production client pages — correct
- 10 admin pages + security config gap (TT-306) — correct
- 8 missing client flows (TT-213–220) — correct
- `add&delete.html` — early test page; correctly excluded from SPA port
- Test lab `old_index.html` — replace with Playwright, not port — correct

---

## Plan items correct but NOT started

- TT-101–108 Bun + Vue 3 SPA
- TT-201–306 all UI flows
- TT-401–407 UX
- TT-501–532 backend hardening
- TT-601–811 DevOps / research ops
- TT-004 dedicated edge container (optional; nginx-in-UI is transitional)

---

## Recommended actions before server move

1. **Commit everything:**

```bash
cd TrainTicket
git add ai-docs/ scripts/smoke-test-routes.sh \
  ts-gateway-service/ ts-ui-dashboard/nginx.conf dockerfile/
git commit -m "S0: gateway routes, nginx edge, ai-docs, Sentinel fix"
git push origin feat
```

2. **On new server:** follow [`MIGRATION.md`](MIGRATION.md)

3. **First task on new server:** run smoke tests after stack is healthy; update `HANDOFF.md` with results

4. **Do not mark S0 Done** until `./scripts/smoke-test-routes.sh` exits 0

---

## What the next agent should trust

| Trust | Don't trust without verifying |
|-------|-------------------------------|
| `PARITY-CHECKLIST.md` feature list | "S0 complete" in old notes |
| `ARCHITECTURE.md` target design | All gateway routes work without curl |
| `FLAWS-AUDIT.md` | `docker.application.ini` ports match compose |
| `ROADMAP.md` sprint order | Docker images already pulled on new machine |
| `DECISIONS.md` ADRs | Avatar `lb://` works |
