# Train Ticket Scripts

This directory contains automation scripts for managing the Train Ticket microservices application **locally** (not in Docker).

## 🎯 Purpose

These scripts allow you to run all Train Ticket microservices **locally on your machine** for testing and development before containerization. Services run in the background using `nohup` and can be easily started, stopped, and monitored.

---

## 📜 Available Scripts

### 1. `start.sh` - Start All Services Locally ⭐

Starts all Train Ticket microservices locally in the background using `nohup`.

**Usage:**
```bash
./scripts/start.sh
```

**What it does:**
- 🔍 Checks if JAR files exist (services must be built first)
- 🚀 Starts each Java service with `nohup java -jar` in its directory
- 🐍 Starts Python services with `nohup python3 server.py`
- 🌐 Starts UI dashboard with a simple HTTP server
- 📝 Saves all PIDs to `.services.pid` for easy stopping
- 📊 Creates logs in `logs/` directory for each service
- 🔌 Displays all accessible ports

**Requirements:**
- Services must be built first: `./scripts/build.sh all`
- Java 8+ installed
- Python 3 installed (for Python services)
- Ports must be available (check with `./scripts/status.sh`)

**Example Output:**
```
✓ ts-auth-service → Port 12340 (PID: 12345)
✓ ts-user-service → Port 12342 (PID: 12346)
...
```

---

### 2. `stop.sh` - Stop All Services ⭐

Gracefully stops all locally running Train Ticket services.

**Usage:**
```bash
./scripts/stop.sh
```

**What it does:**
- 🛑 Reads PIDs from `.services.pid` and stops each service
- 🔍 Searches for any remaining Java/Python processes
- ⏳ Attempts graceful shutdown (SIGTERM) first
- ⚡ Force kills (SIGKILL) if needed after 5 seconds
- 🧹 Offers option to delete log files
- 🗑️ Cleans up PID file

**Graceful Shutdown:**
1. Sends SIGTERM (kill -15)
2. Waits up to 5 seconds
3. Force kills with SIGKILL (kill -9) if still running

---

### 3. `status.sh` - Check Service Status ⭐

Checks which services are currently running locally.

**Usage:**
```bash
./scripts/status.sh
```

**What it does:**
- 📊 Shows status of all services by checking ports
- 🔍 Displays running processes with PIDs
- 📈 Provides summary statistics
- 💡 Shows helpful commands

**Example Output:**
```
✓ Auth Service (Port 12340) - RUNNING [PID: 12345]
✗ User Service (Port 12342) - NOT RUNNING

Services Running: 25 / 45 (55%)
```

---

### 4. `build.sh` - Build Services

Builds one or all microservices using Maven.

**Usage:**
```bash
# Build all services
./scripts/build.sh all

# Build a specific service
./scripts/build.sh auth

# Example: Build only the auth service
./scripts/build.sh auth
```

**What it does:**
- 🔨 Compiles Java microservices using Maven
- ⏩ Skips tests for faster builds (`-DskipTests`)
- ✅ Shows build success/failure for each service
- 📊 Displays summary statistics
- ⏰ Shows timestamps for each build

---

## 🚀 Quick Start Guide

### First Time Setup

1. **Build all services:**
   ```bash
   cd /home/zealot/Devops/TrainTicket
   ./scripts/build.sh all
   ```
   *(This will take 5-15 minutes depending on your machine)*

2. **Start all services:**
   ```bash
   ./scripts/start.sh
   ```
   *(Services will start in background)*

3. **Check status:**
   ```bash
   ./scripts/status.sh
   ```

4. **Access the application:**
   - Open your browser and go to http://localhost:8080

5. **View logs (if needed):**
   ```bash
   tail -f logs/ts-auth-service.log
   ```

6. **Stop all services when done:**
   ```bash
   ./scripts/stop.sh
   ```

---

## 📁 Directory Structure

```
TrainTicket/
├── scripts/
│   ├── start.sh          # Start all services locally
│   ├── stop.sh           # Stop all services
│   ├── status.sh         # Check service status
│   ├── build.sh          # Build services
│   ├── README.md         # This file
│   └── PORTS.txt         # Port reference
├── logs/                 # Created when services start
│   ├── ts-auth-service.log
│   ├── ts-user-service.log
│   └── ...
├── .services.pid         # PIDs of running services
├── ts-auth-service/
│   ├── target/
│   │   └── *.jar        # Built JAR file
│   └── src/
├── ts-user-service/
└── ...
```

---

## 🔌 Service Ports Reference

### Main Entry Points
| Service | Port | Access |
|---------|------|--------|
| **UI Dashboard** | **8080** | http://localhost:8080 ⭐ |

### Core Services (44 total)
See `PORTS.txt` for complete list of all service ports.

**Key Services:**
- Auth Service: 12340
- User Service: 12342
- Order Service: 12031
- Payment Service: 19001
- Travel Service: 12346

---

## 📝 How It Works

### Java Services
Each Java service is started with:
```bash
cd ts-[service-name]-service
nohup java -Xmx200m -jar target/*.jar > ../logs/ts-[service]-service.log 2>&1 &
```

- **nohup**: Keeps running after terminal closes
- **-Xmx200m**: Limits memory to 200MB per service
- **Background**: `&` runs in background
- **Logs**: Both stdout and stderr go to log file

### Python Services
```bash
cd ts-voucher-service
nohup python3 server.py > ../logs/ts-voucher-service.log 2>&1 &
```

### PID Tracking
Each service's PID is saved to `.services.pid`:
```
12345:ts-auth-service:12340
12346:ts-user-service:12342
...
```

---

## 🔧 Troubleshooting

### Services won't start

1. **Check if already running:**
   ```bash
   ./scripts/status.sh
   ```

2. **Check if services are built:**
   ```bash
   ls ts-auth-service/target/*.jar
   ```
   If no JAR found, build first:
   ```bash
   ./scripts/build.sh all
   ```

3. **Check for port conflicts:**
   ```bash
   lsof -i :12340  # Check specific port
   ```

4. **View service logs:**
   ```bash
   tail -f logs/ts-auth-service.log
   ```

### Build failures

1. **Check Java version:**
   ```bash
   java -version  # Need Java 8+
   ```

2. **Check Maven:**
   ```bash
   mvn --version
   ```

3. **Clean and rebuild:**
   ```bash
   cd ts-auth-service
   mvn clean install
   ```

### Port already in use

1. **Find what's using the port:**
   ```bash
   lsof -i :12340
   ```

2. **Kill the process:**
   ```bash
   kill -15 <PID>
   ```

### Services crash immediately

1. **Check logs:**
   ```bash
   cat logs/ts-[service-name].log
   ```

2. **Common issues:**
   - Missing dependencies (MongoDB, Redis)
   - Database connection failures
   - Port already in use
   - Insufficient memory

### Memory issues

If you have limited RAM, start services in groups:
```bash
# Edit start.sh and comment out services you don't need
# Or start services individually
cd ts-auth-service
nohup java -Xmx200m -jar target/*.jar > ../logs/ts-auth-service.log 2>&1 &
```

---

## 📊 Resource Usage

**Per Service:**
- Memory: ~200MB (configurable with `-Xmx`)
- CPU: Varies by load
- Disk: Logs grow over time

**Total for All Services:**
- Memory: ~8-10GB
- Disk: ~5GB (JARs + logs)

**Recommended System:**
- RAM: 16GB+
- CPU: 4+ cores
- Disk: 20GB+ free

---

## 🐛 Common Commands

### View logs
```bash
# Single service
tail -f logs/ts-auth-service.log

# All services (requires multitail)
multitail logs/*.log

# Search logs
grep "ERROR" logs/*.log
```

### Check what's running
```bash
# All Java services
ps aux | grep "ts-.*-service.*\.jar"

# All Python services
ps aux | grep "python3.*server.py"

# Specific port
lsof -i :12340
```

### Kill specific service
```bash
# Find PID
lsof -i :12340

# Kill gracefully
kill -15 <PID>

# Force kill
kill -9 <PID>
```

### Clean up logs
```bash
# Delete all logs
rm -rf logs/*

# Delete old logs (older than 7 days)
find logs/ -name "*.log" -mtime +7 -delete

# View log sizes
du -sh logs/*
```

### Restart a specific service
```bash
# Stop the service
kill -15 <PID>

# Start it again
cd ts-auth-service
nohup java -Xmx200m -jar target/*.jar > ../logs/ts-auth-service.log 2>&1 &
```

---

## ⚙️ Advanced Usage

### Start only specific services

Edit `start.sh` and comment out services you don't need:
```bash
# Comment out like this:
# start_java_service "ts-admin-user-service" 16115
```

### Change memory limits

Edit `start.sh` and modify `-Xmx200m` to your needs:
```bash
nohup java -Xmx512m -jar "$jar_file" ...  # 512MB instead of 200MB
```

### Run services on different ports

Edit each service's `src/main/resources/application.yml`:
```yaml
server:
  port: 12340  # Change this
```

Then rebuild:
```bash
./scripts/build.sh [service-name]
```

---

## 📚 Notes

1. **Not for production**: These scripts are for local testing only
2. **Dependencies**: Some services need MongoDB, Redis, MySQL (not included)
3. **Startup time**: Services need 10-30 seconds to fully initialize
4. **Logs location**: All logs go to `./logs/` directory
5. **PID file**: `.services.pid` tracks running services
6. **Background execution**: Services keep running after terminal closes
7. **Containerization**: Use docker-compose.yml for containerized deployment

---

## 🆘 Need Help?

- **Check status**: `./scripts/status.sh`
- **View logs**: `tail -f logs/[service-name].log`
- **Port reference**: See `PORTS.txt`
- **Service info**: See `/docs/info/services.md`

---

**Last Updated:** October 2025  
**Target Environment:** Local development (pre-containerization)
