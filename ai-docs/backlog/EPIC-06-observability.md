# EPIC-06 — Observability & Performance

**Status:** Backlog  
**Sprint:** S7

## Goal

Tracing, metrics, structured logging, lean dev compose.

## Tickets

| ID | Title | Status |
|----|-------|--------|
| TT-701 | Zipkin + SkyWalking tracing | Backlog |
| TT-702 | Prometheus + Grafana compose profile | Backlog |
| TT-703 | Structured JSON logging + optional EFK | Backlog |
| TT-704 | Gateway rate limits (expand Sentinel) | Backlog |
| TT-705 | UI latency indicators, retry on 503 | Backlog |
| TT-706 | Lean dev compose (~12 core services) | Backlog |

## Reference parity

- `train-ticket/deployment/kubernetes-manifests/prometheus/`
- `train-ticket/deployment/kubernetes-manifests/skywalking/`
- `train-ticket/deployment/docker-compose-manifests/docker-compose-with-jaeger.yml`

See EPIC-09 for full research benchmark ops.
