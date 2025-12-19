# TrainTicket - Current Status

## ✅ FULLY WORKING - Running Locally Without Docker!

**Date:** 2025-12-18  
**Status:** All services running and registered with Nacos

---

## Running Services

| Service | Port | Status | Nacos Registration |
|---------|------|--------|-------------------|
| UI Dashboard | 8080 | ✅ Running | N/A |
| Gateway | 18888 | ✅ Running | ✅ Registered |
| Auth Service | 12340 | ✅ Running | ✅ Registered |
| User Service | 12342 | ✅ Running | ✅ Registered |
| Verification Code | 15678 | ✅ Running | ✅ Registered |
| Nacos (Docker) | 8848, 9848, 9849 | ✅ Running | N/A |
| MySQL (Local) | 3306 | ✅ Running | N/A |

---

## Test Results

### Direct Service Access
```bash
# Auth Service
curl http://localhost:12340/api/v1/auth/hello
# Response: hello ✅

# User Service  
curl http://localhost:12342/api/v1/userservice/users/hello
# Response: Hello ✅

# Verification Code Service
curl http://localhost:15678/api/v1/verifycode/generate
# Response: (verification code) ✅
```

### Gateway Routing
```bash
# Gateway routing to Auth Service
curl http://localhost:18888/api/v1/auth/hello
# Response: hello ✅
```

### UI Access
```bash
# UI Dashboard
curl http://localhost:8080
# Response: TrainTicket Admin page ✅
```

---

## Issue Resolved: Nacos gRPC Connection

### Problem
Services were failing to register with Nacos with error:
```
ERROR c.a.c.n.registry.NacosServiceRegistry : nacos registry failed
Caused by: com.alibaba.nacos.api.exception.NacosException: Client not connected
```

### Root Cause
Nacos gRPC ports (9848, 9849) were not exposed in the Docker container. Services use gRPC for registration, not just HTTP.

### Solution
Updated Nacos Docker command to expose all required ports:
```bash
docker run -d --name nacos-local \
  -e MODE=standalone \
  -p 8848:8848 \   # HTTP API
  -p 9848:9848 \   # gRPC client-server
  -p 9849:9849 \   # gRPC server-server
  nacos/nacos-server:v2.1.0
```

### Result
All services now successfully register with Nacos on startup! ✅

---

## How to Access

### Web Interfaces
- **Application UI**: http://localhost:8080
- **Nacos Console**: http://localhost:8848/nacos (username: nacos, password: nacos)

### API Endpoints
- **Gateway**: http://localhost:18888
- **Auth Service**: http://localhost:12340
- **User Service**: http://localhost:12342
- **Verification Code**: http://localhost:15678

---

## Process Information

### Running Processes
```bash
# Check Java processes
ps aux | grep "ts-.*-service.jar"

# Check Nacos
docker ps | grep nacos-local

# Check UI
ps aux | grep "http.server"
```

### Terminal IDs (Current Session)
- Terminal 56: UI Dashboard (Python HTTP server)
- Terminal 65: Auth Service
- Terminal 67: User Service
- Terminal 68: Verification Code Service
- Terminal 69: Gateway Service

---

## Configuration Files

### Environment Variables
- **local.env** - All environment variables for local development

### Application Config
- Each service uses `src/main/resources/application.yaml`
- Environment variables override default values
- Database connections configured via env vars

### Databases
- `ts-auth-mysql` - Auth service database ✅
- `ts-user-mysql` - User service database ✅

---

## Next Steps

1. ✅ All core services running
2. ✅ Nacos service discovery working
3. ✅ Gateway routing working
4. ✅ Database connections working
5. ✅ UI accessible

### To Add More Services
Simply build the JAR and run:
```bash
source local.env
java -jar jar/ts-<service-name>.jar
```

The service will automatically register with Nacos!

---

## Stop Everything

```bash
# Stop Java services (Ctrl+C in each terminal)
# Or kill all at once:
pkill -f "ts-.*-service.jar"

# Stop UI
pkill -f "http.server"

# Stop Nacos
docker rm -f nacos-local
```

---

## Files Created/Modified

### New Files
- `local.env` - Environment variables
- `start-local.sh` - Startup helper script
- `QUICK_START.md` - Quick start guide
- `RUN_LOCALLY.md` - Detailed instructions
- `STATUS.md` - This file

### Modified Files
- `start-local.sh` - Updated with correct Nacos ports

### Scripts Cleaned
Removed unnecessary scripts from `scripts/` directory.

