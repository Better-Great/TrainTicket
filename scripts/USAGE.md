# Quick Usage Guide

## 🚀 Three Simple Steps to Run All Services Locally

### Step 1: Build All Services (First Time Only)
```bash
cd /home/zealot/Devops/TrainTicket
./scripts/build.sh all
```
⏱️ Takes 5-15 minutes

### Step 2: Start All Services
```bash
./scripts/start.sh
```
✅ Services run in background with nohup  
📝 Logs saved to `logs/` directory  
💾 PIDs saved to `.services.pid`

### Step 3: Access Your Application
🌐 **Main UI**: http://localhost:8080

---

## 📊 Check Status Anytime
```bash
./scripts/status.sh
```

Shows:
- ✓ Which services are running
- ✗ Which services are not running
- 📈 Summary statistics
- 🔍 Process details with PIDs

---

## 🛑 Stop All Services
```bash
./scripts/stop.sh
```

Gracefully stops:
- All Java services
- All Python services  
- UI services
- Cleans up PID files

---

## 📝 View Logs
```bash
# View a specific service log
tail -f logs/ts-auth-service.log

# View all errors
grep "ERROR" logs/*.log

# View all logs (if you have multitail)
multitail logs/*.log
```

---

## 🔧 Common Scenarios

### Restart Everything
```bash
./scripts/stop.sh
./scripts/start.sh
```

### Rebuild and Restart a Specific Service
```bash
# Stop all services
./scripts/stop.sh

# Rebuild specific service
./scripts/build.sh auth

# Start all services again
./scripts/start.sh
```

### Check What's Using a Port
```bash
lsof -i :12340
```

### Kill a Specific Service
```bash
# Find the PID
lsof -i :12340

# Kill it
kill -15 <PID>
```

---

## 📍 Service Locations

All services run from their own directories:
```
/home/zealot/Devops/TrainTicket/
├── ts-auth-service/          # Port 12340
├── ts-user-service/          # Port 12342
├── ts-order-service/         # Port 12031
├── ts-payment-service/       # Port 19001
├── ts-voucher-service/       # Port 16101 (Python)
└── ... (41+ more services)
```

---

## ⚡ Pro Tips

1. **First run takes longer** - Services need to initialize databases
2. **Wait 30 seconds** - After starting, services need time to fully boot
3. **Check logs if issues** - All errors go to `logs/[service-name].log`
4. **Port conflicts** - Make sure no other apps are using the ports
5. **Memory hungry** - All services need ~8-10GB RAM total

---

## 🎯 What Each Script Does

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `build.sh` | Compile services | First time, after code changes |
| `start.sh` | Start all services | Every time you want to run |
| `stop.sh` | Stop all services | When done testing |
| `status.sh` | Check what's running | Anytime, to verify status |

---

## 🚨 Troubleshooting

### Problem: Services won't start
**Solution:**
```bash
# Check if built
ls ts-auth-service/target/*.jar

# If not found, build first
./scripts/build.sh all
```

### Problem: Port already in use
**Solution:**
```bash
# Find what's using it
lsof -i :12340

# Kill the process
kill -15 <PID>
```

### Problem: Service crashes immediately
**Solution:**
```bash
# Check the log
cat logs/ts-auth-service.log

# Look for errors
grep "ERROR" logs/ts-auth-service.log
```

### Problem: Out of memory
**Solution:**
- Close other applications
- Edit `start.sh` and comment out services you don't need
- Or increase memory: change `-Xmx200m` to `-Xmx512m`

---

## 📞 Quick Reference

```bash
# Start everything
./scripts/start.sh

# Stop everything  
./scripts/stop.sh

# Check status
./scripts/status.sh

# Build everything
./scripts/build.sh all

# View logs
tail -f logs/*.log

# Clean logs
rm -rf logs/*
```

---

**That's it! 🎉**

You can now test the entire Train Ticket system locally before containerizing!

