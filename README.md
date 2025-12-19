# TrainTicket - Microservices Application

A comprehensive train ticket booking system built with microservices architecture.

## 🏗️ Architecture

- **41 Java Microservices** - Spring Boot/Cloud
- **4 Non-Java Services** - Node.js, Python, Static Web
- **Service Registry** - Nacos
- **Databases** - MySQL (25 services)
- **Message Queue** - RabbitMQ
- **Gateway** - API Gateway service

## 📋 Prerequisites

- Java 8+
- Maven 3.x
- Docker & Docker Compose
- Node.js (for ticket-office)
- Python 3.x (for avatar & voucher services)
- MySQL
- Nacos
- RabbitMQ

## 🚀 Quick Start

### Complete Local Deployment

For detailed step-by-step deployment instructions, see **[scripts/DEPLOYMENT.md](scripts/DEPLOYMENT.md)**

**Quick Commands**:

```bash
# 1. Build token replacement service
cd ts-token-replacement-service && ./build.sh && cd ..

# 2. Generate configurations for development
./replace-tokens.sh dev

# 3. Start infrastructure services
# Note: Check docker-compose.yml for actual service names
docker compose up -d redis

# For MongoDB instances (if needed):
docker compose up -d $(docker compose config --services | grep mongo)

# 4. Wait for infrastructure (30 seconds)
sleep 30

# Note: Use 'docker compose' (space) for v2, or 'docker-compose' (hyphen) for v1

# 5. Start all microservices
docker compose up -d

# 6. Access the application
# UI Dashboard: http://localhost:8080
# Gateway: http://localhost:18888
# Nacos Console: http://localhost:8848/nacos (nacos/nacos)
```

### Generate Environment-Specific Configurations

The project uses **Token Replacement Service** to generate environment-specific configurations from templates. This makes the application **environment-agnostic**.

```bash
# Generate configurations for development environment
./replace-tokens.sh dev

# Generate configurations for QA environment
./replace-tokens.sh qa

# Generate configurations for production environment
./replace-tokens.sh prod
```

This will:
- Generate `application.properties` for all 41 Java services
- Replace all `${VariableName}` tokens with actual environment values
- Create ready-to-use configuration files

## 📂 Project Structure

```
TrainTicket/
├── README.md                           # This file - How to run application
├── replace-tokens.sh                   # Quick script to generate configs
├── docker-compose.yml                  # Docker orchestration
│
├── config-generator/                   # Python scripts for config generation
│   ├── README.md                      # Generator scripts documentation
│   ├── analyze-and-generate.py        # Analyze yml → generate templates
│   ├── generate-dev-properties.py     # Generate property files
│   └── generate-env-files.py          # Generate .env for non-Java
│
├── properties/                         # Environment-specific properties
│   ├── dev.application.ini            # Development (232+ properties)
│   ├── qa.application.ini             # QA/Testing
│   └── prod.application.ini           # Production
│
├── ts-token-replacement-service/      # Java token replacement service
│   ├── README.md                      # Service documentation
│   ├── pom.xml                        # Maven configuration
│   ├── build.sh, run.sh               # Build and run scripts
│   └── src/main/java/...              # Java source code
│
├── ts-{service-name}/                 # 41 Java microservices
│   ├── application.properties.ini     # Template with ${tokens}
│   └── src/main/resources/
│       ├── application.yml            # Base config (defaults)
│       └── application.properties     # Generated (env-specific)
│
├── ts-ticket-office-service/          # Node.js service
│   └── .env                           # Environment variables (generated/Docker)
│
├── ts-voucher-service/                # Python service
│   └── .env                           # Environment variables (generated/Docker)
│
└── ts-ui-dashboard/                   # Frontend (static)
    └── nginx.conf                     # Nginx configuration
```

## 🔧 Configuration Management

### How It Works

The project uses a **template-based configuration system** that separates:

1. **Templates** (`application.properties.ini`, `.env.template`) - With `${VariableName}` placeholders
2. **Environment Files** (`properties/dev.application.ini`) - Actual values per environment
3. **Generated Configs** (`application.properties`, `.env`) - Final configs after token replacement

### Spring Boot Configuration Priority

For Java services:
```
application.properties  ← HIGHER PRIORITY (generated, env-specific)
         ↓
application.yml        ← LOWER PRIORITY (defaults)
```

Spring Boot loads **both** files, but `.properties` **overrides** `.yml` values.

### Why This Approach?

✅ **Environment Agnostic** - Single codebase, multiple environments  
✅ **Security** - No secrets in source code  
✅ **Flexibility** - Easy to add new environments  
✅ **Consistency** - Same pattern for all services  
✅ **CI/CD Ready** - One command to generate all configs

## 🛠️ Services Overview

### Java Microservices (41 services)

| Category | Services |
|----------|----------|
| **Admin** | admin-basic-info, admin-order, admin-route, admin-travel, admin-user |
| **Core** | auth, basic, user, travel, travel2, order, order-other |
| **Booking** | preserve, preserve-other, seat, price, cancel, rebook |
| **Food** | food, food-delivery, station-food, train-food |
| **Payment** | payment, inside-payment, assurance, voucher |
| **Infrastructure** | config, gateway, notification, verification-code |
| **Security** | security, contacts |
| **Transport** | train, station, route, route-plan, travel-plan |
| **Logistics** | consign, consign-price, delivery, execute |
| **Monitoring** | wait-order |

### Non-Java Services

| Service | Technology | Purpose |
|---------|------------|---------|
| `ts-ticket-office-service` | Node.js/Express | Ticket office management |
| `ts-avatar-service` | Python/Flask | Avatar processing |
| `ts-voucher-service` | Python/Tornado | Voucher generation |
| `ts-ui-dashboard` | Static/Nginx | Web frontend |

## 📝 Configuration Examples

### Java Service Configuration

**Template** (`ts-auth-service/application.properties.ini`):
```properties
server.port=${AuthServicePort}
spring.datasource.url=jdbc:mysql://${AuthMysqlHost}:${AuthMysqlPort}/${AuthMysqlDatabase}
spring.datasource.username=${AuthMysqlUser}
spring.datasource.password=${AuthMysqlPassword}
```

**Environment File** (`properties/dev.application.ini`):
```ini
AuthServicePort=12340
AuthMysqlHost=ts-auth-mysql
AuthMysqlPort=3306
AuthMysqlDatabase=ts-auth-mysql
AuthMysqlUser=root
AuthMysqlPassword=root
```

**Generated** (`ts-auth-service/src/main/resources/application.properties`):
```properties
server.port=12340
spring.datasource.url=jdbc:mysql://ts-auth-mysql:3306/ts-auth-mysql
spring.datasource.username=root
spring.datasource.password=root
```

### Non-Java Service Configuration

**Python Service** (ts-voucher-service):
```bash
# .env.template
ORDER_SERVICE_URL=${OrderServiceUrl}
VOUCHER_MYSQL_HOST=${VoucherMysqlHost}
VOUCHER_MYSQL_PORT=${VoucherMysqlPort}

# Generated .env
ORDER_SERVICE_URL=http://ts-order-service:12031
VOUCHER_MYSQL_HOST=ts-voucher-mysql
VOUCHER_MYSQL_PORT=3306
```

## 🔄 Development Workflow

### Adding a New Service

1. **Create service** following microservices pattern
2. **Create template** file with `${tokens}`:
   ```bash
   # For Java
   vi ts-your-service/application.properties.ini
   
   # For Python/Node.js
   vi ts-your-service/.env.template
   ```

3. **Add properties** to environment files:
   ```bash
   vi properties/dev.application.ini
   vi properties/qa.application.ini
   vi properties/prod.application.ini
   ```

4. **Generate configs**:
   ```bash
   ./replace-tokens.sh dev
   ```

### Switching Environments

```bash
# Switch to QA
./replace-tokens.sh qa
docker compose restart

# Switch back to dev
./replace-tokens.sh dev
docker compose restart
```

### Local Development

```bash
# 1. Generate dev configs
./replace-tokens.sh dev

# 2. Start infrastructure
docker compose up -d mysql nacos rabbitmq

# 3. Start services you're working on
cd ts-auth-service
mvn spring-boot:run

# 4. Or start all via Docker
docker compose up -d
```

## 📊 Statistics

- **Total Services**: 45 (41 Java + 4 non-Java)
- **Total Configurations**: 220+ properties
- **Database Services**: 25
- **Lines of Configuration**: Generated automatically ✅

## 🐛 Troubleshooting

### Services Not Starting

**Check configurations**:
```bash
# Verify configs were generated
ls ts-auth-service/src/main/resources/application.properties

# Check for tokens that weren't replaced
grep '\${' ts-auth-service/src/main/resources/application.properties
```

### Database Connection Issues

**Verify database properties**:
```bash
# Check database host/port
grep -i mysql properties/dev.application.ini

# Ensure MySQL is running
docker compose ps mysql
```

### Configuration Not Applied

**Remember**: For Java services, `application.properties` overrides `application.yml`.

**Verify**:
1. File exists: `ts-*/src/main/resources/application.properties`
2. No syntax errors in template
3. All tokens have values in `properties/dev.application.ini`

## 🔒 Security Best Practices

1. **Never commit** `application.properties` or `.env` files (add to `.gitignore`)
2. **Never commit** `properties/prod.application.ini` with real credentials
3. **Use secrets management** for production (e.g., Vault, AWS Secrets Manager)
4. **Rotate passwords** regularly
5. **Use strong passwords** in production

## 📚 Documentation

- **Main README**: `README.md` (this file) - How to run the application
- **Token Replacement Service**: `ts-token-replacement-service/README.md` - Java service docs
- **Configuration Generators**: `config-generator/README.md` - Python scripts docs
- **API Documentation**: Access Swagger UI at `http://localhost:{port}/swagger-ui.html`

## 🚀 CI/CD Integration

```bash
#!/bin/bash
# Example CI/CD pipeline

# 1. Generate configs for target environment
./replace-tokens.sh ${CI_ENVIRONMENT}

# 2. Build services
mvn clean package

# 3. Build Docker images
docker compose build

# 4. Deploy
docker compose up -d
```

## 🆘 Support

For issues:
1. Check logs: `docker-compose logs [service-name]`
2. Verify configuration: `cat ts-*/src/main/resources/application.properties`
3. Check service health: `curl http://localhost:{port}/actuator/health`

## 📜 License

[Your License]

---

**Status**: ✅ Production Ready  
**Configuration**: ✅ Environment Agnostic  
**Services**: 45/45 Configured

