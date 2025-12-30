# TrainTicket Quick Reference

## 🚀 Quick Start (Minimal - Login/Registration)

### Option 1: Local with JARs
```bash
./scripts/start-minimal.sh    # Start
./scripts/stop-minimal.sh     # Stop
```

### Option 2: Docker
```bash
./scripts/docker-minimal-start.sh    # Start
./scripts/docker-minimal-stop.sh     # Stop
```

## 🌐 Access URLs

| Service | URL |
|---------|-----|
| **UI Dashboard** | http://localhost:8080 |
| **API Gateway** | http://localhost:18888 |
| **Nacos Console** | http://localhost:8848/nacos |

**Nacos Credentials:** `nacos` / `nacos`

## 📦 Services in Minimal Setup

- ✅ ts-gateway-service (18888)
- ✅ ts-auth-service (12340)
- ✅ ts-user-service (12342)
- ✅ ts-verification-code-service (15678)
- ✅ ts-ui-dashboard (8080)
- ✅ nacos (8848)
- ✅ mysql (3306)

## 🔧 Common Commands

### Local JARs
```bash
# View logs
tail -f logs/ts-auth-service.log

# Check running services
ps aux | grep "ts-.*-service"

# Check ports
lsof -i :8080
```

### Docker
```bash
# View logs
docker-compose -f docker-compose.minimal.yml logs -f ts-auth-service

# Check status
docker-compose -f docker-compose.minimal.yml ps

# Restart service
docker-compose -f docker-compose.minimal.yml restart ts-auth-service

# Remove everything
docker-compose -f docker-compose.minimal.yml down -v
```

### Database
```bash
# Local MySQL
mysql -uroot -proot -e "SHOW DATABASES;"

# Docker MySQL
docker exec trainticket-mysql mysql -uroot -proot -e "SHOW DATABASES;"
```

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Find process
lsof -i :8080

# Kill process
kill -9 <PID>
```

### Service Won't Start
```bash
# Check logs
tail -f logs/<service-name>.log

# Check if JAR exists
ls -la jar/ts-auth-service.jar

# Check MySQL
mysql -uroot -proot -e "SELECT 1;"
```

### Docker Issues
```bash
# Check Docker
docker ps

# View service logs
docker logs ts-auth-service

# Restart Docker
sudo systemctl restart docker
```

## 📁 Important Directories

```
jar/          # Pre-built JAR files
logs/         # Service logs
scripts/      # Deployment scripts
k8s/          # Kubernetes manifests
```

## 🔑 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| MySQL | root | root |
| Nacos | nacos | nacos |

## 📊 Resource Requirements

### Minimal Setup
- **RAM:** 2GB minimum, 4GB recommended
- **CPU:** 2 cores
- **Disk:** 5GB

### Full Setup
- **RAM:** 8GB minimum, 16GB recommended
- **CPU:** 4+ cores
- **Disk:** 20GB

## 🎯 Testing Workflow

1. Start services
2. Open http://localhost:8080
3. Click "Register"
4. Create account
5. Login with credentials
6. Verify dashboard loads

## 📚 Documentation

- [GETTING-STARTED.md](GETTING-STARTED.md) - Detailed setup guide
- [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) - Full deployment options
- [scripts/README.md](scripts/README.md) - Script documentation

