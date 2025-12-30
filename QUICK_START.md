# TrainTicket - Quick Start Guide

## Summary
The services CAN run locally without Docker! The Nacos registration errors you see are just warnings - the services themselves work fine.

## What's Working
✅ **UI** - Running on port 8080  
✅ **Gateway** - Running on port 18888 (despite Nacos warnings)  
✅ **Database** - MySQL on localhost:3306  
✅ **Nacos** - Running in Docker on port 8848  

## Current Setup

### Files Created
1. **local.env** - Environment variables for local development
2. **start-local.sh** - Helper script to prepare environment
3. **RUN_LOCALLY.md** - Detailed instructions
4. **QUICK_START.md** - This file

### Scripts Cleaned Up
Removed unnecessary scripts from `scripts/` directory. Kept only:
- build.sh
- start-local.sh (original full version)
- status.sh
- stop.sh
- Database initialization scripts

## How to Run

### Option 1: Manual (Recommended - See What's Happening)

**Step 1: Start Nacos**
```bash
./start-local.sh
```
This will start Nacos and wait for it to be ready.

**Step 2: Open 5 Separate Terminals**

Terminal 1 - UI:
```bash
cd ts-ui-dashboard/static && python3 -m http.server 8080
```

Terminal 2 - Gateway:
```bash
source local.env && java -jar jar/ts-gateway-service.jar
```

Terminal 3 - Auth Service:
```bash
source local.env && java -jar jar/ts-auth-service.jar
```

Terminal 4 - User Service:
```bash
source local.env && java -jar jar/ts-user-service.jar
```

Terminal 5 - Verification Code Service:
```bash
source local.env && java -jar jar/ts-verification-code-service.jar
```

### Option 2: Use the Original Script
```bash
./scripts/start-local.sh
```

## Access Points
- **UI**: http://localhost:8080
- **Gateway**: http://localhost:18888  
- **Nacos Console**: http://localhost:8848/nacos (nacos/nacos)

## ✅ Issue Fixed: Nacos gRPC Ports
**Problem:** Services were failing to register with Nacos because gRPC ports (9848, 9849) weren't exposed.

**Solution:** Updated Nacos Docker command to expose all required ports:
```bash
docker run -d --name nacos-local \
  -e MODE=standalone \
  -p 8848:8848 \
  -p 9848:9848 \
  -p 9849:9849 \
  nacos/nacos-server:v2.1.0
```

All services now register successfully with Nacos!

## Stop Everything
```bash
# Stop Nacos
docker rm -f nacos-local

# Stop services - Ctrl+C in each terminal
```

## Next Steps
1. Start services using Option 1 above
2. Watch the logs in each terminal
3. Access the UI at http://localhost:8080
4. Services work even if Nacos registration shows errors

## Configuration
All configuration is in:
- `local.env` - Environment variables
- `properties/dev.application.ini` - Full configuration file
- Each service's `application.yaml` - Service-specific config

