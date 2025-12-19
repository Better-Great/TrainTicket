# Local Deployment Guide

Complete step-by-step guide to deploy TrainTicket microservices locally using the existing scripts.

## 📋 Prerequisites

- **Java 8+**
- **Maven 3.x**
- **Docker & Docker Compose** (for infrastructure)
- **Python 3.6+** (for config generation)
- **MySQL** (via Docker or local installation)
- **Nacos** (via Docker or local installation)
- **RabbitMQ** (via Docker or local installation)

## 🚀 Deployment Steps

### Step 1: Generate Configuration Files

Before deploying, generate environment-specific configurations using the token replacement service:

```bash
# Build token replacement service (first time only)
cd ts-token-replacement-service
./build.sh
cd ..

# Generate configurations for development environment
./replace-tokens.sh dev
```

**Expected Output**:
```
========================================
Token Replacement Service
========================================
Environment: dev
Project Root: /path/to/TrainTicket
========================================

Loading properties from: .../properties/dev.application.ini
Loaded 235 properties

[PROCESSING] ts-auth-service
  ✓ Generated: .../ts-auth-service/src/main/resources/application.properties
... (40 more services)

Summary:
  Processed: 41
  Skipped:   7
  Total:     48
========================================
Token replacement completed successfully!
========================================
```

**Verify Configurations**:
```bash
# Check that application.properties files were generated
find ts-*/src/main/resources -name "application.properties" | wc -l
# Should show: 41

# Verify no unreplaced tokens
grep -r '\${' ts-*/src/main/resources/application.properties
# Should return empty (no matches)
```

### Step 2: Initialize Databases (If Using Local MySQL)

If you're using local MySQL (not Docker), initialize the databases:

```bash
# Initialize all databases locally
./scripts/init-databases-local.sh

# Or check if databases exist first
./scripts/check-databases-local.sh
```

### Step 3: Build All Services

Build all microservices using the build script:

```bash
# Build all services
./scripts/build.sh all
```

**Expected Output**:
```
Building all services...
✓ Building ts-auth-service...
✓ Building ts-user-service...
...
Build Summary: 45/45 services built successfully
```

**Note**: This will take 5-15 minutes depending on your machine.

### Step 4: Start Infrastructure Services

**Note**: Your `docker-compose.yml` is configured with MongoDB instances. The infrastructure services available are:

```bash
# Start Redis (infrastructure service)
docker compose up -d redis

# Start all MongoDB instances (if needed)
docker compose up -d ts-auth-mongo ts-user-mongo ts-order-mongo

# Or start all MongoDB instances at once
docker compose up -d $(docker compose config --services | grep mongo)

# Start MySQL for voucher service (if needed)
docker compose up -d ts-voucher-mysql

# Check service status
docker compose ps
```

**Available Infrastructure Services**:
- `redis` - Redis cache
- `ts-*-mongo` - MongoDB instances (one per service)
- `ts-voucher-mysql` - MySQL for voucher service

**Note**: If your services use Nacos, you'll need to:
1. Install Nacos separately, OR
2. Add Nacos to your docker-compose.yml, OR
3. Use service discovery configuration without Nacos

**Note**: If you have Docker Compose v2 (check with `docker compose version`), use `docker compose` (with space). For v1, use `docker-compose` (with hyphen).

### Step 5: Start All Microservices

Use the start script to launch all services:

```bash
# Start all services locally
./scripts/start.sh
```

**Expected Output**:
```
Starting TrainTicket Microservices...
✓ ts-auth-service → Port 12340 (PID: 12345)
✓ ts-user-service → Port 12342 (PID: 12346)
✓ ts-order-service → Port 12031 (PID: 12347)
... (38 more services)

All services started!
Check status: ./scripts/status.sh
```

### Step 6: Check Service Status

Verify all services are running:

```bash
# Check which services are running
./scripts/status.sh
```

**Expected Output**:
```
Service Status:
✓ Auth Service (Port 12340) - RUNNING [PID: 12345]
✓ User Service (Port 12342) - RUNNING [PID: 12346]
✓ Order Service (Port 12031) - RUNNING [PID: 12347]
...

Services Running: 41 / 45 (91%)
```

### Step 7: Verify Service Health

Check that services are running and healthy:

```bash
# Check if services are responding
curl http://localhost:12340  # Auth service
curl http://localhost:12342  # User service
curl http://localhost:12031  # Order service

# Check service logs
docker compose logs ts-auth-service | tail -20

# Or if running locally (not Docker)
./scripts/status.sh
```

**Note**: If your services use Nacos for service discovery:
- Ensure Nacos is installed and running (port 8848)
- Check Nacos console: http://localhost:8848/nacos (login: nacos/nacos)
- Verify services are registered in Service Management → Service List

### Step 8: Access the Application

```bash
# UI Dashboard
open http://localhost:8080

# API Gateway
curl http://localhost:18888

# Individual services
curl http://localhost:12340  # Auth service
curl http://localhost:12342  # User service
curl http://localhost:12031  # Order service
```

### Step 9: View Logs

View service logs for debugging:

```bash
# View specific service log
tail -f logs/ts-auth-service.log

# View all logs (if multitail installed)
multitail logs/*.log

# Search for errors
grep -i "error" logs/*.log

# List all log files
ls -lh logs/
```

## 🛑 Stopping Services

### Stop All Services

```bash
# Stop all services gracefully
./scripts/stop.sh
```

**What it does**:
- Reads PIDs from `.services.pid`
- Sends SIGTERM to each service
- Waits up to 5 seconds
- Force kills if needed (SIGKILL)
- Cleans up PID file
- Optionally removes log files

**Expected Output**:
```
Stopping TrainTicket Microservices...
✓ Stopped ts-auth-service (PID: 12345)
✓ Stopped ts-user-service (PID: 12346)
...
All services stopped.
```

### Stop Infrastructure Services

```bash
# Stop specific infrastructure
docker compose down redis ts-voucher-mysql

# Stop all MongoDB instances
docker compose down $(docker compose config --services | grep mongo)

# Or stop all Docker services
docker compose down
```

## 🔄 Complete Restart Workflow

If you need to restart everything:

```bash
# 1. Stop all services
./scripts/stop.sh

# 2. Regenerate configs (if properties changed)
./replace-tokens.sh dev

# 3. Rebuild services (if code changed)
./scripts/build.sh all

# 4. Restart infrastructure
docker compose up -d redis $(docker compose config --services | grep mongo)
sleep 30

# 5. Start all services
./scripts/start.sh

# 6. Check status
./scripts/status.sh
```

## 🐛 Troubleshooting

### Issue: Services Not Starting

```bash
# 1. Check if already running
./scripts/status.sh

# 2. Check if services are built
ls ts-auth-service/target/*.jar
# If no JAR, build first:
./scripts/build.sh all

# 3. Check for port conflicts
lsof -i :12340

# 4. View service logs
tail -f logs/ts-auth-service.log
```

### Issue: Configuration Not Applied

```bash
# 1. Regenerate configurations
./replace-tokens.sh dev

# 2. Verify application.properties exists
ls -la ts-auth-service/src/main/resources/application.properties

# 3. Check for unreplaced tokens
grep '\${' ts-auth-service/src/main/resources/application.properties
# Should be empty

# 4. Rebuild service
./scripts/build.sh auth
```

### Issue: Services Not Starting

```bash
# 1. Check if required infrastructure is running
docker compose ps redis ts-auth-mongo ts-user-mongo

# 2. Check service configuration
grep -E "nacos|datasource|mongo" ts-auth-service/src/main/resources/application.properties

# 3. Check service logs for errors
docker compose logs ts-auth-service | tail -50

# 4. Verify MongoDB/MySQL connections
docker compose exec ts-auth-mongo mongo --eval "db.adminCommand('ping')"
# Or for MySQL:
docker compose exec ts-voucher-mysql mysql -uroot -proot -e "SELECT 1"
```

### Issue: Database Connection Errors

```bash
# 1. Verify MongoDB/MySQL is running
docker compose ps ts-auth-mongo ts-voucher-mysql

# 2. Check database configuration
grep -E "datasource|mongo" ts-auth-service/src/main/resources/application.properties

# 3. Test MongoDB connection
docker compose exec ts-auth-mongo mongo --eval "db.adminCommand('ping')"

# 4. Test MySQL connection (for voucher service)
docker compose exec ts-voucher-mysql mysql -uroot -proot -e "SELECT 1"

# 5. Initialize databases if needed
./scripts/init-databases-local.sh
```

### Issue: Build Failures

```bash
# 1. Check Java version
java -version  # Need Java 8+

# 2. Check Maven
mvn --version

# 3. Clean Maven cache
./scripts/maven-cleanup.sh

# 4. Rebuild specific service
./scripts/build.sh auth
```

### Issue: Port Already in Use

```bash
# Find what's using the port
lsof -i :12340

# Kill the process
kill -15 <PID>

# Or change port in properties/dev.application.ini
# AuthServicePort=12341
# Then: ./replace-tokens.sh dev && ./scripts/build.sh auth
```

## 📊 Quick Reference

### Essential Commands

```bash
# Generate configs
./replace-tokens.sh dev

# Build all services
./scripts/build.sh all

# Start all services
./scripts/start.sh

# Check status
./scripts/status.sh

# Stop all services
./scripts/stop.sh

# View logs
tail -f logs/ts-auth-service.log
```

### Service Endpoints

| Service | Port | URL |
|---------|------|-----|
| UI Dashboard | 8080 | http://localhost:8080 |
| API Gateway | 18888 | http://localhost:18888 |
| Nacos Console | 8848 | http://localhost:8848/nacos |
| Auth Service | 12340 | http://localhost:12340 |
| User Service | 12342 | http://localhost:12342 |
| Order Service | 12031 | http://localhost:12031 |

### Script Reference

| Script | Purpose |
|--------|---------|
| `./replace-tokens.sh dev` | Generate configurations |
| `./scripts/build.sh all` | Build all services |
| `./scripts/start.sh` | Start all services |
| `./scripts/stop.sh` | Stop all services |
| `./scripts/status.sh` | Check service status |
| `./scripts/init-databases-local.sh` | Initialize databases |
| `./scripts/check-databases-local.sh` | Check database status |

## ✅ Deployment Checklist

- [ ] **Step 1**: Generated configurations (`./replace-tokens.sh dev`)
- [ ] **Step 2**: Initialized databases (if local MySQL)
- [ ] **Step 3**: Built all services (`./scripts/build.sh all`)
- [ ] **Step 4**: Started infrastructure (Docker: mysql, nacos, rabbitmq)
- [ ] **Step 5**: Started all services (`./scripts/start.sh`)
- [ ] **Step 6**: Verified status (`./scripts/status.sh`)
- [ ] **Step 7**: Checked Nacos registration
- [ ] **Step 8**: Accessed UI at http://localhost:8080
- [ ] **Step 9**: Verified logs for errors

## 📝 Notes

- **First Start**: Services may take 30-60 seconds to fully initialize
- **Memory**: Ensure 8GB+ RAM available (200MB per service × 41 services)
- **Startup Time**: Initial build takes 5-15 minutes
- **Logs Location**: All logs in `./logs/` directory
- **PID File**: `.services.pid` tracks running services
- **Background Execution**: Services keep running after terminal closes

## 🎓 Additional Resources

- **Scripts Documentation**: See `scripts/README.md`
- **Service Ports**: See `scripts/PORTS.txt`
- **Main README**: See `../README.md`
- **Token Replacement Service**: See `../ts-token-replacement-service/README.md`

---

**Quick Start**: Run `./replace-tokens.sh dev`, then `./scripts/build.sh all`, then `./scripts/start.sh` 🚀
