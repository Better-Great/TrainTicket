# JAR Files Directory

This directory contains all the compiled JAR files for the Train Ticket microservices.

## Purpose

All microservice JAR files are automatically deployed to this directory when you run:
```bash
./scripts/deploy.sh
```

## File Naming Convention

JAR files are named using the pattern: `ts-{service-name}-service.jar`

Examples:
- `ts-auth-service.jar` - Authentication service
- `ts-user-service.jar` - User management service
- `ts-order-service.jar` - Order management service
- `ts-payment-service.jar` - Payment processing service

## Usage

These JAR files can be used to:
- Deploy individual services to servers
- Run services with `java -jar ts-{service-name}-service.jar`
- Package services for Docker containers
- Distribute services across different environments

## Auto-Generated

**Note:** This directory and its contents are automatically managed by the deployment scripts. Do not manually modify JAR files here as they will be overwritten on the next deployment.
