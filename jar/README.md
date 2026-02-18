# JAR Files Directory

This directory contains all the compiled JAR files for the Train Ticket microservices.

## Purpose

All microservice JAR files are automatically deployed to this directory when you run:
```bash
./scripts/build.sh
./scripts/deploy.sh
```

For Docker builds (ts-auth-service etc.), also deploy the token replacement service:
```bash
cd ts-token-replacement-service && ./build.sh && cd ..
./scripts/deploy.sh auth
./scripts/deploy.sh token-replacement
# Or: ./scripts/deploy.sh all
```

## File Naming Convention

JAR files are named using the pattern: `ts-{service-name}-service.jar`

Examples:
- `ts-auth-service.jar` - Authentication service
- `ts-token-replacement-service.jar` - Token replacement (used at runtime for config generation)
- `ts-user-service.jar` - User management service
- `ts-order-service.jar` - Order management service
- `ts-payment-service.jar` - Payment processing service

## Usage

These JAR files can be used to:
- Deploy individual services to servers
- Run services with `java -jar ts-{service-name}-service.jar`
- Package services for Docker containers (dockerfile/Dockerfile.Ts.Auth.Service expects jar/ts-auth-service.jar and jar/ts-token-replacement-service.jar)
- Distribute services across different environments

## Auto-Generated

**Note:** This directory and its contents are automatically managed by the deployment scripts. Do not manually modify JAR files here as they will be overwritten on the next deployment.
