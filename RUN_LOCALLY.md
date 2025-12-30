# Running TrainTicket Locally (Without Docker)

## Prerequisites
1. Java 8 installed
2. MySQL running locally on port 3306
3. Nacos running (we'll use Docker for this)

## Quick Start

### 1. Start Nacos
```bash
docker run -d --name nacos-local -p 8848:8848 -e MODE=standalone nacos/nacos-server:v2.1.0
```

Wait ~30 seconds for Nacos to fully start, then verify:
```bash
curl http://localhost:8848/nacos
```

### 2. Load Environment Variables
```bash
source local.env
```

### 3. Start Services One by One

**Terminal 1 - Gateway Service:**
```bash
java -jar jar/ts-gateway-service.jar
```

**Terminal 2 - Auth Service:**
```bash
java -jar jar/ts-auth-service.jar
```

**Terminal 3 - User Service:**
```bash
java -jar jar/ts-user-service.jar
```

**Terminal 4 - Verification Code Service:**
```bash
java -jar jar/ts-verification-code-service.jar
```

**Terminal 5 - UI Dashboard:**
```bash
cd ts-ui-dashboard/static && python3 -m http.server 8080
```

## Access Points
- **UI**: http://localhost:8080
- **Gateway**: http://localhost:18888
- **Nacos Console**: http://localhost:8848/nacos (username: nacos, password: nacos)

## Troubleshooting

### Check if Nacos is ready
```bash
curl http://localhost:8848/nacos/v1/console/health
```

### Check service logs
Services will output logs directly to the terminal where they're running.

### Stop Everything
```bash
# Stop Nacos
docker rm -f nacos-local

# Stop services - Ctrl+C in each terminal
```

## Database Setup
The databases should already exist. If not:
```bash
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS \`ts-auth-mysql\`;"
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS \`ts-user-mysql\`;"
```

