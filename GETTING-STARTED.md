# TrainTicket - Getting Started Guide

This guide shows you how to run TrainTicket locally for account creation and login functionality.

## Three Deployment Options

### Option 1: Local with JARs (Recommended for Development)
Run services directly on your machine using pre-built JAR files.

**Prerequisites:**
- Java 8+
- MySQL 8.0 (local installation)
- Python 3 (for UI)

**Steps:**
```bash
# 1. Initialize databases
./scripts/init-databases-local.sh

# 2. Start minimal services (gateway, auth, user, verification-code, UI)
./scripts/start-minimal.sh

# 3. Access the application
# UI: http://localhost:8080
# Gateway: http://localhost:18888

# 4. Stop services
./scripts/stop-minimal.sh
```

**Pros:** Fast startup, easy debugging, direct log access
**Cons:** Requires local MySQL installation

---

### Option 2: Docker Compose (Recommended for Testing)
Run everything in containers including MySQL and Nacos.

**Prerequisites:**
- Docker & Docker Compose

**Steps:**
```bash
# 1. Start all services
./scripts/docker-minimal-start.sh

# 2. Access the application
# UI: http://localhost:8080
# Nacos: http://localhost:8848/nacos (nacos/nacos)

# 3. View logs
docker-compose -f docker-compose.minimal.yml logs -f

# 4. Stop services
./scripts/docker-minimal-stop.sh
```

**Pros:** No local dependencies, isolated environment
**Cons:** Slower startup, requires Docker

---

### Option 3: Full Local Deployment (All Services)
Run all 40+ services locally.

**Steps:**
```bash
# 1. Initialize all databases
./scripts/init-databases-local.sh

# 2. Start all services
./scripts/start-local.sh

# 3. Stop all services
./scripts/stop.sh
```

---

## Services in Minimal Setup

| Service | Port | Purpose |
|---------|------|---------|
| ts-ui-dashboard | 8080 | Web UI |
| ts-gateway-service | 18888 | API Gateway |
| ts-auth-service | 12340 | Authentication & Login |
| ts-user-service | 12342 | User Registration |
| ts-verification-code-service | 15678 | Verification Codes |
| nacos (Docker only) | 8848 | Service Discovery |
| mysql | 3306 | Database |

---

## Testing Account Creation & Login

1. **Open UI**: http://localhost:8080
2. **Register**: Click "Register" and create an account
3. **Login**: Use your credentials to login
4. **Verify**: You should see the dashboard

---

## Troubleshooting

### Local JAR Deployment

**Services won't start:**
```bash
# Check if JARs exist
ls -la jar/

# Check MySQL
mysql -uroot -proot -e "SHOW DATABASES;"

# View logs
tail -f logs/ts-auth-service.log
```

**Port already in use:**
```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>
```

### Docker Deployment

**Services not starting:**
```bash
# Check Docker
docker ps

# View logs
docker logs ts-auth-service

# Restart specific service
docker-compose -f docker-compose.minimal.yml restart ts-auth-service
```

**Database connection issues:**
```bash
# Check MySQL
docker exec trainticket-mysql mysql -uroot -proot -e "SHOW DATABASES;"

# Recreate databases
docker exec trainticket-mysql mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS ts_auth_mysql;"
```

---

## Next Steps

Once the minimal setup works:
1. Add more services as needed
2. Configure for production
3. Deploy to Kubernetes (see k8s/ directory)

---

## File Structure

```
TrainTicket/
├── jar/                          # Pre-built JAR files
├── scripts/
│   ├── start-minimal.sh          # Start minimal local services
│   ├── stop-minimal.sh           # Stop minimal local services
│   ├── docker-minimal-start.sh   # Start minimal Docker services
│   ├── docker-minimal-stop.sh    # Stop minimal Docker services
│   ├── init-databases-local.sh   # Initialize local MySQL
│   ├── start-local.sh            # Start all local services
│   └── stop.sh                   # Stop all local services
├── docker-compose.minimal.yml    # Minimal Docker Compose
└── docker-compose.yml            # Full Docker Compose
```

