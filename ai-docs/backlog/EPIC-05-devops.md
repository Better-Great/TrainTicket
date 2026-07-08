# EPIC-05 — DevOps & CI/CD

**Status:** Backlog  
**Sprint:** S7

## Goal

GitHub Actions, Docker matrix, K8s manifests, Playwright E2E.

## Tickets

| ID | Title | Status |
|----|-------|--------|
| TT-601 | GitHub Actions (Maven + Bun) | Backlog |
| TT-602 | Docker build matrix (Java + Bun) | Backlog |
| TT-603 | Tag-triggered image push | Backlog |
| TT-604 | `k8s/` or Helm manifests | Backlog |
| TT-605 | `docker-compose.dev.yml` hot-reload UI | Backlog |
| TT-606 | Playwright E2E (auto-query scenarios) | Backlog |

## CI shape

```yaml
- uses: oven-sh/setup-bun@v2
- run: cd ts-ui-web && bun install && bun run build && bun test
- run: mvn -B test
```

## Reference

Port Jenkins from `train-ticket/jenkins-ci/` or fully replace with GitHub Actions (TT-807).
