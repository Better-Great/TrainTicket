# EPIC-09 — Research Benchmark Ops Parity

**Status:** Backlog  
**Sprint:** S7+

## Goal

Port reference `train-ticket/deployment/` capabilities so TrainTicket remains usable as a microservice research benchmark.

## Tickets

| ID | Title | Reference source | Status |
|----|-------|------------------|--------|
| TT-801 | SkyWalking APM | `kubernetes-manifests/skywalking/` | Backlog |
| TT-802 | Prometheus + Grafana | `kubernetes-manifests/prometheus/` | Backlog |
| TT-803 | Jaeger Docker Compose | `docker-compose-with-jaeger.yml` | Backlog |
| TT-804 | Istio service mesh | `k8s-with-istio/` | Backlog |
| TT-805 | Fault injection (delay, abort, gray) | `fault-inject-deployment/` | Backlog |
| TT-806 | EFK logging | `efk-deployment/` | Backlog |
| TT-807 | Jenkins CI (or replace with GH Actions) | `jenkins-ci/` | Backlog |
| TT-808 | Helm charts (Nacos, MySQL, RabbitMQ) | `quickstart-k8s/charts/` | Backlog |
| TT-809 | `make deploy` equivalent scripts | `hack/deploy/deploy.sh` | Backlog |
| TT-810 | train-ticket-auto-query CI gate | external repo | Backlog |
| TT-811 | Independent-DB-per-service K8s mode | `--independent-db` | Backlog |

## Makefile reference flags

```bash
make deploy                                    # quick start
make deploy DeployArgs="--independent-db"
make deploy DeployArgs="--with-monitoring"
make deploy DeployArgs="--with-tracing"
make deploy DeployArgs="--all"
```
