# Local Deployment Guide

Complete step-by-step guide to deploy TrainTicket microservices locally with token replacement configuration.

## 📋 Prerequisites

- **Java 8+**
- **Maven 3.x**
- **Docker & Docker Compose**
- **Python 3.6+** (for config generation)
- **MySQL** (if not using Docker)
- **Nacos** (if not using Docker)
- **RabbitMQ** (if not using Docker)

## 🚀 Deployment Steps

### Step 1: Clone and Navigate

```bash
cd /path/to/TrainTicket
# Ensure you're in the project root
pwd  # Should show TrainTicket directory
```

### Step 2: Build Token Replacement Service

```bash
# Build the Java token replacement service
cd ts-token-replacement-service
./build.sh

# Verify JAR was created
ls -lh target/token-replacement-service.jar
# Should see the JAR file

cd ..
```

**Expected Output**:
```
==========================================
Building Token Replacement Service
==========================================
...
BUILD SUCCESS
JAR location: target/token-replacement-service.jar
```

### Step 3: Generate Configuration Files

#### Option A: Quick Method (Recommended)

```bash
# Generate all configurations for dev environment
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
[PROCESSING] ts-travel-service
  ✓ Generated: .../ts-travel-service/src/main/resources/application.properties
... (39 more services)

Summary:
  Processed: 41
  Skipped:   7
  Total:     48
========================================
Token replacement completed successfully!
========================================
```

#### Option B: Manual Method

```bash
# If you need to regenerate templates first
cd config-generator
python3 analyze-and-generate.py
python3 generate-dev-properties.py

# Then run token replacement
cd ..
./replace-tokens.sh dev
```

### Step 4: Verify Generated Configurations

```bash
# Check that application.properties files were generated
find ts-*/src/main/resources -name "application.properties" | wc -l
# Should show: 41

# Verify a sample configuration
cat ts-auth-service/src/main/resources/application.properties | head -5
# Should show actual values, not ${tokens}
```

**Expected Sample Output**:
```properties
server.port=12340
spring.cloud.nacos.discovery.server-addr=nacos-0.nacos-headless.default.svc.cluster.local,...
spring.application.name=ts-auth-service
spring.datasource.url=jdbc:mysql://ts-auth-mysql:3306/ts-auth-mysql?useSSL=false
spring.datasource.username=root
```

### Step 5: Start Infrastructure Services

Start MySQL, Nacos, RabbitMQ, and other dependencies:

```bash
# Start all infrastructure services
docker-compose up -d mysql nacos rabbitmq

# Or start specific services
docker-compose up -d mysql
docker-compose up -d nacos
docker-compose up -d rabbitmq

# Wait for services to be ready (especially Nacos)
sleep 30

# Check service status
docker-compose ps
```

**Verify Services**:
```bash
# Check MySQL
docker-compose exec mysql mysql -uroot -proot -e "SELECT 1"

# Check Nacos (web UI at http://localhost:8848/nacos)
curl http://localhost:8848/nacos

# Check RabbitMQ
docker-compose exec rabbitmq rabbitmqctl status
```

### Step 6: Start Microservices

#### Option A: Start All Services via Docker Compose

```bash
# Start all services at once
docker-compose up -d

# Or start specific services
docker-compose up -d ts-auth-service
docker-compose up -d ts-user-service
docker-compose up -d ts-order-service
# ... etc
```

#### Option B: Start Services Individually (Development)

```bash
# Start services one by one for debugging
cd ts-auth-service
mvn spring-boot:run

# In another terminal
cd ts-user-service
mvn spring-boot:run

# ... etc
```

### Step 7: Verify Service Registration

```bash
# Check Nacos console for registered services
open http://localhost:8848/nacos
# Login: nacos/nacos
# Navigate to: Service Management → Service List

# Or check via API
curl http://localhost:8848/nacos/v1/ns/service/list
```

**Expected**: You should see services like:
- ts-auth-service
- ts-user-service
- ts-order-service
- ts-travel-service
- ... (41 services total)

### Step 8: Check Service Health

```bash
# Check gateway service
curl http://localhost:18888/actuator/health

# Check auth service
curl http://localhost:12340/actuator/health

# Check user service
curl http://localhost:12342/actuator/health

# List all running services
docker-compose ps | grep "Up"
```

### Step 9: Access the Application

#### Web Interface

```bash
# Open in browser
open http://localhost:8080

# Or manually navigate to:
# http://localhost:8080
```

#### API Gateway

```bash
# Gateway endpoint
curl http://localhost:18888

# Example API call
curl http://localhost:18888/api/v1/userservice/users
```

#### Service Direct Access

```bash
# Access services directly
curl http://localhost:12340  # Auth service
curl http://localhost:12342  # User service
curl http://localhost:12031  # Order service
```

### Step 10: View Logs

```bash
# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f ts-auth-service

# View last 100 lines
docker-compose logs --tail=100 ts-auth-service

# View logs for multiple services
docker-compose logs -f ts-auth-service ts-user-service ts-order-service
```

## 🔧 Configuration Verification

### Verify Configuration Files Exist

```bash
# List all generated application.properties
find ts-*/src/main/resources -name "application.properties" | sort

# Check a specific service
cat ts-auth-service/src/main/resources/application.properties

# Verify no unreplaced tokens
grep -r '\${' ts-*/src/main/resources/application.properties
# Should return empty (no matches)
```

### Verify Database Connections

```bash
# Check if services can connect to MySQL
docker-compose logs ts-auth-service | grep -i "datasource\|mysql\|connected"

# Test MySQL connection
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"
```

### Verify Nacos Connection

```bash
# Check Nacos connectivity in service logs
docker-compose logs ts-auth-service | grep -i "nacos\|service discovery"

# Check Nacos web UI
curl http://localhost:8848/nacos
```

## 🐛 Troubleshooting

### Issue: Token Replacement Not Working

```bash
# Re-run token replacement
./replace-tokens.sh dev

# Verify properties file exists
ls -la ts-auth-service/src/main/resources/application.properties

# Check for errors
java -jar ts-token-replacement-service/target/token-replacement-service.jar dev 2>&1 | grep ERROR
```

### Issue: Services Not Starting

```bash
# Check logs for errors
docker-compose logs ts-auth-service

# Common issues:
# 1. Missing application.properties - run ./replace-tokens.sh dev
# 2. Nacos not ready - wait 30 seconds after starting
# 3. MySQL not accessible - check docker-compose ps mysql
# 4. Port conflicts - check netstat -tulpn | grep :12340
```

### Issue: Services Not Registering with Nacos

```bash
# 1. Ensure Nacos is running
docker-compose ps nacos

# 2. Check Nacos configuration in application.properties
grep nacos ts-auth-service/src/main/resources/application.properties

# 3. Verify network connectivity
docker-compose exec ts-auth-service ping nacos

# 4. Check Nacos logs
docker-compose logs nacos | tail -50
```

### Issue: Database Connection Errors

```bash
# 1. Verify MySQL is running
docker-compose ps mysql

# 2. Check database configuration
grep datasource ts-auth-service/src/main/resources/application.properties

# 3. Test MySQL connection
docker-compose exec mysql mysql -uroot -proot -e "SELECT 1"

# 4. Check if database exists
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES LIKE 'ts-auth-mysql';"
```

### Issue: Port Already in Use

```bash
# Find what's using the port
lsof -i :12340  # For auth service
lsof -i :18888  # For gateway

# Kill the process or change port in properties file
kill -9 <PID>

# Or update properties/dev.application.ini and regenerate
# AuthServicePort=12341
# Then: ./replace-tokens.sh dev
```

## 📊 Service Status Check

### Quick Health Check Script

```bash
#!/bin/bash
# Save as check-services.sh

echo "=== Infrastructure Services ==="
docker-compose ps mysql nacos rabbitmq | grep -E "Name|Up|Exit"

echo -e "\n=== Microservices ==="
docker-compose ps | grep "ts-" | grep "Up" | wc -l | xargs echo "Running services:"

echo -e "\n=== Service Endpoints ==="
echo "Nacos Console: http://localhost:8848/nacos (nacos/nacos)"
echo "Gateway: http://localhost:18888"
echo "UI Dashboard: http://localhost:8080"
echo "Auth Service: http://localhost:12340"
echo "User Service: http://localhost:12342"
echo "Order Service: http://localhost:12031"
```

```bash
chmod +x check-services.sh
./check-services.sh
```

## 🎯 Complete Deployment Checklist

- [ ] **Step 1**: Cloned repository and navigated to project root
- [ ] **Step 2**: Built token replacement service (`./build.sh`)
- [ ] **Step 3**: Generated configurations (`./replace-tokens.sh dev`)
- [ ] **Step 4**: Verified 41 `application.properties` files generated
- [ ] **Step 5**: Started infrastructure (MySQL, Nacos, RabbitMQ)
- [ ] **Step 6**: Started microservices (Docker Compose or individually)
- [ ] **Step 7**: Verified services registered in Nacos
- [ ] **Step 8**: Checked service health endpoints
- [ ] **Step 9**: Accessed web UI at http://localhost:8080
- [ ] **Step 10**: Verified logs for errors

## 🔄 Quick Restart

If you need to restart everything:

```bash
# Stop all services
docker-compose down

# Regenerate configs (if properties changed)
./replace-tokens.sh dev

# Restart infrastructure
docker-compose up -d mysql nacos rabbitmq
sleep 30

# Restart all services
docker-compose up -d

# Check status
docker-compose ps
```

## 🎓 Next Steps

Once everything is running:

1. **Test the API**: Try accessing endpoints via Gateway
2. **Monitor Logs**: Watch service logs for any issues
3. **Check Nacos**: Verify all services are registered
4. **Test Functionality**: Create users, book tickets, etc.
5. **Generate QA Configs**: `./replace-tokens.sh qa` for different environment

## 📝 Notes

- **First Start**: Infrastructure services (Nacos, MySQL) may take 30-60 seconds to fully start
- **Memory**: Ensure you have enough RAM (8GB+ recommended for all services)
- **Docker Resources**: Adjust Docker Desktop memory limits if needed
- **Network**: Services communicate via Docker network names (e.g., `ts-auth-mysql`)

---

**Troubleshooting Help**: Check logs first, then verify configurations, then check infrastructure connectivity.

**Status**: All services running? Check http://localhost:8080 to see the TrainTicket application! 🎉

