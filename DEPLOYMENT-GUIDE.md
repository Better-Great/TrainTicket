# TrainTicket Deployment Guide

Complete guide for deploying TrainTicket from local development to Kubernetes.

## Deployment Progression

```
Local (JARs) → Docker Compose → Kubernetes
```

---

## 1. Local Development (JARs)

**Best for:** Development, debugging, quick testing

### Minimal Setup (Login/Registration Only)

```bash
# Start 5 essential services
./scripts/start-minimal.sh

# Access
# - UI: http://localhost:8080
# - Gateway: http://localhost:18888
# - Nacos: http://localhost:8848/nacos

# Stop
./scripts/stop-minimal.sh
```

**Services:** Gateway, Auth, User, Verification-Code, UI

### Full Setup (All 40+ Services)

```bash
# Initialize databases
./scripts/init-databases-local.sh

# Start all services
./scripts/start-local.sh

# Stop all services
./scripts/stop.sh
```

**Requirements:**
- Java 8+
- MySQL 8.0 (local)
- Python 3
- Docker (for Nacos)

---

## 2. Docker Compose

**Best for:** Testing, isolated environments, CI/CD

### Minimal Setup

```bash
# Start
./scripts/docker-minimal-start.sh

# View logs
docker-compose -f docker-compose.minimal.yml logs -f

# Stop
./scripts/docker-minimal-stop.sh
```

**Includes:** MySQL, Nacos, Gateway, Auth, User, Verification-Code, UI

### Full Setup

```bash
# Set environment variables
export IMG_REPO=trainticket
export IMG_TAG=latest

# Start all services
docker-compose up -d

# Stop
docker-compose down
```

**Requirements:**
- Docker
- Docker Compose

---

## 3. Kubernetes

**Best for:** Production, scalability, high availability

### Prerequisites

```bash
# Install kubectl
# Install helm (optional)
# Have a Kubernetes cluster ready
```

### Deploy

```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/

# Check status
kubectl get pods
kubectl get services

# Access via NodePort or LoadBalancer
kubectl get svc ts-ui-dashboard
```

**Features:**
- Auto-scaling
- Service mesh
- Load balancing
- Health checks
- Rolling updates

---

## Architecture Comparison

| Aspect | Local JARs | Docker Compose | Kubernetes |
|--------|-----------|----------------|------------|
| Setup Time | Fast | Medium | Slow |
| Resource Usage | Low | Medium | High |
| Isolation | None | Container | Pod |
| Scalability | Manual | Limited | Auto |
| Production Ready | No | No | Yes |
| Debugging | Easy | Medium | Hard |

---

## Service Dependencies

### Minimal Setup Dependencies

```
MySQL (databases)
  ↓
Nacos (service discovery)
  ↓
Gateway ← Auth, User, Verification-Code
  ↓
UI Dashboard
```

### Required Databases (Minimal)

- `ts-auth-mysql` - Authentication data
- `ts-user-mysql` - User profiles

---

## Port Reference (Minimal Setup)

| Service | Port | Protocol |
|---------|------|----------|
| UI Dashboard | 8080 | HTTP |
| Gateway | 18888 | HTTP |
| Auth | 12340 | HTTP |
| User | 12342 | HTTP |
| Verification Code | 15678 | HTTP |
| Nacos | 8848 | HTTP |
| MySQL | 3306 | TCP |

---

## Quick Start Decision Tree

```
Do you need all services?
├─ No → Use minimal setup
│   ├─ Have Docker? → ./scripts/docker-minimal-start.sh
│   └─ No Docker? → ./scripts/start-minimal.sh
│
└─ Yes → Use full setup
    ├─ Production? → Kubernetes
    ├─ Testing? → docker-compose up
    └─ Development? → ./scripts/start-local.sh
```

---

## Next Steps

1. **Start with minimal setup** to verify login/registration works
2. **Add services incrementally** as needed
3. **Move to Docker** for better isolation
4. **Deploy to K8s** for production

---

## Troubleshooting

See [GETTING-STARTED.md](GETTING-STARTED.md) for detailed troubleshooting steps.

---

## Files Reference

```
TrainTicket/
├── jar/                              # Pre-built JARs
├── scripts/
│   ├── start-minimal.sh              # Local minimal
│   ├── stop-minimal.sh               # Stop local minimal
│   ├── docker-minimal-start.sh       # Docker minimal
│   ├── docker-minimal-stop.sh        # Stop Docker minimal
│   ├── start-local.sh                # Local full
│   ├── stop.sh                       # Stop local full
│   └── init-databases-local.sh       # Setup MySQL
├── docker-compose.minimal.yml        # Docker minimal config
├── docker-compose.yml                # Docker full config
└── k8s/                              # Kubernetes manifests
```

