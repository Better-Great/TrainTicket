# Train Ticket Microservices - Domain-Based Grouping

## Overview

This document outlines the recommended domain-driven organization of Train Ticket microservices. Services are grouped by business domain to enable better team ownership, independent scaling, and deployment isolation.

---

## 🎯 Service Groups

### Group 1: Core Booking & Ticketing Domain

**Business Purpose:** Customer-facing ticket operations and transactions

**Group Name:** `BOOKING_DOMAIN`

**Services:**
- `ts-travel-service` - Trip search and management
- `ts-travel2-service` - High-speed rail trips (separate routes)
- `ts-booking-service` - Ticket booking and reservation
- `ts-order-service` - Order creation and management
- `ts-order-other-service` - Non-train orders (flights, hotels)
- `ts-cancel-service` - Order cancellation
- `ts-rebook-service` - Ticket rebooking and changes
- `ts-inside-payment-service` - Internal payment processing
- `ts-payment-service` - Payment gateway integration

**Configuration:**
- **Nacos Group:** `BOOKING_GROUP`
- **K8s Namespace:** `booking-domain`
- **Service Prefix:** `booking-`

---

### Group 2: Customer Management Domain

**Business Purpose:** User profiles, authentication, and customer data

**Group Name:** `CUSTOMER_DOMAIN`

**Services:**
- `ts-user-service` - User registration and profile management
- `ts-auth-service` - Authentication and authorization
- `ts-verification-code-service` - SMS/email verification
- `ts-contacts-service` - Emergency contacts management
- `ts-consign-service` - Consignment and delivery addresses

**Configuration:**
- **Nacos Group:** `CUSTOMER_GROUP`
- **K8s Namespace:** `customer-domain`
- **Service Prefix:** `customer-`

---

### Group 3: Operations & Logistics Domain

**Business Purpose:** Train operations, routes, and infrastructure management

**Group Name:** `OPERATIONS_DOMAIN`

**Services:**
- `ts-train-service` - Train information (types, schedules)
- `ts-route-service` - Route planning and management
- `ts-station-service` - Station information
- `ts-price-service` - Dynamic pricing engine
- `ts-basic-service` - Basic reference data (cities, stations)
- `ts-config-service` - System configuration management
- `ts-seat-service` - Seat inventory management
- `ts-travel-plan-service` - Trip planning and recommendations

**Configuration:**
- **Nacos Group:** `OPERATIONS_GROUP`
- **K8s Namespace:** `operations-domain`
- **Service Prefix:** `ops-`

---

### Group 4: Ancillary Services Domain

**Business Purpose:** Additional services and amenities

**Group Name:** `ANCILLARY_DOMAIN`

**Services:**
- `ts-food-service` - Food ordering (onboard meals)
- `ts-food-map-service` - Restaurant and food location mapping
- `ts-consign-price-service` - Consignment pricing calculation
- `ts-delivery-service` - Food and package delivery

**Configuration:**
- **Nacos Group:** `ANCILLARY_GROUP`
- **K8s Namespace:** `ancillary-domain`
- **Service Prefix:** `ancillary-`

---

### Group 5: Administration & Support Domain

**Business Purpose:** Back-office operations and admin tools

**Group Name:** `ADMIN_DOMAIN`

**Services:**
- `ts-admin-basic-info-service` - Basic administrative data management
- `ts-admin-order-service` - Administrative order operations
- `ts-admin-route-service` - Route administration
- `ts-admin-travel-service` - Travel data administration
- `ts-admin-user-service` - User administration
- `ts-preserve-service` - Ticket preservation and holds
- `ts-preserve-other-service` - Other preservation operations
- `ts-execute-service` - Order execution and fulfillment

**Configuration:**
- **Nacos Group:** `ADMIN_GROUP`
- **K8s Namespace:** `admin-domain`
- **Service Prefix:** `admin-`

---

### Group 6: Security & Compliance Domain

**Business Purpose:** Security screening, insurance, and regulatory compliance

**Group Name:** `SECURITY_DOMAIN`

**Services:**
- `ts-security-service` - Security screening and checks
- `ts-assurance-service` - Insurance and travel assurance
- `ts-voucher-service` - Vouchers and promotional codes

**Configuration:**
- **Nacos Group:** `SECURITY_GROUP`
- **K8s Namespace:** `security-domain`
- **Service Prefix:** `security-`

---

### Group 7: Notifications & Communication Domain

**Business Purpose:** Customer notifications and announcements

**Group Name:** `NOTIFICATION_DOMAIN`

**Services:**
- `ts-notification-service` - Push notifications and alerts
- `ts-news-service` - News and system announcements

**Configuration:**
- **Nacos Group:** `NOTIFICATION_GROUP`
- **K8s Namespace:** `notification-domain`
- **Service Prefix:** `notification-`

---

### Group 8: Infrastructure & Platform

**Business Purpose:** Cross-cutting technical infrastructure

**Group Name:** `INFRASTRUCTURE`

**Services:**
- `ts-gateway-service` - API Gateway and routing
- `ts-ui-dashboard` - Administrative UI dashboard
- Nacos/Eureka - Service discovery and registration
- Database services (MongoDB, MySQL)
- Redis cache services

**Configuration:**
- **Nacos Group:** `INFRA_GROUP`
- **K8s Namespace:** `infrastructure`
- **Service Prefix:** `infra-`

---

## 📁 Configuration Structure

```
config/
├── booking-domain/
│   ├── common.properties
│   ├── ts-booking-service.yml
│   ├── ts-order-service.yml
│   └── ts-travel-service.yml
├── customer-domain/
│   ├── common.properties
│   ├── ts-user-service.yml
│   └── ts-auth-service.yml
├── operations-domain/
│   ├── common.properties
│   └── ...
├── ancillary-domain/
│   └── ...
├── admin-domain/
│   └── ...
├── security-domain/
│   └── ...
├── notification-domain/
│   └── ...
├── infrastructure/
│   └── ...
└── environments/
    ├── dev.env
    ├── staging.env
    └── prod.env
```

---

## 🌍 Environment Configuration

### Development Environment (`dev.env`)

```bash
# Service Discovery
NACOS_ADDRS=localhost:8848
NACOS_NAMESPACE=dev

# Booking Domain
BOOKING_DB_HOST=localhost
BOOKING_DB_PORT=3306
BOOKING_DB_NAME=ts_booking_dev

# Customer Domain
CUSTOMER_DB_HOST=localhost
CUSTOMER_DB_PORT=3306
CUSTOMER_DB_NAME=ts_customer_dev

# Common
LOG_LEVEL=DEBUG
REDIS_HOST=localhost
REDIS_PORT=6379
```

### Staging Environment (`staging.env`)

```bash
# Service Discovery
NACOS_ADDRS=nacos.staging.internal:8848
NACOS_NAMESPACE=staging

# Booking Domain
BOOKING_DB_HOST=mysql-booking.staging.internal
BOOKING_DB_PORT=3306
BOOKING_DB_NAME=ts_booking_staging

# Customer Domain
CUSTOMER_DB_HOST=mysql-customer.staging.internal
CUSTOMER_DB_PORT=3306
CUSTOMER_DB_NAME=ts_customer_staging

# Common
LOG_LEVEL=INFO
REDIS_HOST=redis.staging.internal
REDIS_PORT=6379
```

### Production Environment (`prod.env`)

```bash
# Service Discovery
NACOS_ADDRS=nacos-0.nacos-headless.prod.svc.cluster.local,nacos-1.nacos-headless.prod.svc.cluster.local,nacos-2.nacos-headless.prod.svc.cluster.local
NACOS_NAMESPACE=production
NACOS_USERNAME=prod_user
NACOS_PASSWORD=${NACOS_PROD_PASSWORD}

# Booking Domain
BOOKING_DB_HOST=mysql-booking.prod.svc.cluster.local
BOOKING_DB_PORT=3306
BOOKING_DB_NAME=ts_booking_prod
BOOKING_DB_USERNAME=booking_user
BOOKING_DB_PASSWORD=${BOOKING_DB_PROD_PASSWORD}

# Customer Domain
CUSTOMER_DB_HOST=mysql-customer.prod.svc.cluster.local
CUSTOMER_DB_PORT=3306
CUSTOMER_DB_NAME=ts_customer_prod
CUSTOMER_DB_USERNAME=customer_user
CUSTOMER_DB_PASSWORD=${CUSTOMER_DB_PROD_PASSWORD}

# Common
LOG_LEVEL=WARN
REDIS_HOST=redis.prod.svc.cluster.local
REDIS_PORT=6379
```

---

## 🎯 Benefits of Domain-Based Grouping

### 1. **Business Alignment**
- Clear mapping to business capabilities
- Easy for product teams to understand ownership
- Facilitates domain-driven design discussions

### 2. **Independent Scaling**
- Scale booking services separately during peak booking hours
- Scale admin services independently based on operational needs
- Optimize resource allocation per domain

### 3. **Team Ownership**
- Different teams can own different domains
- Clear boundaries of responsibility
- Reduces cross-team dependencies

### 4. **Deployment Isolation**
- Deploy booking changes without affecting operations
- Reduce blast radius of failures
- Enable independent release cycles

### 5. **Security Boundaries**
- Apply different security policies per domain
- Isolate sensitive customer data
- Implement fine-grained access controls

---

## 🚀 Migration Strategy

### Phase 1: Configuration Parameterization
1. Identify all hardcoded values in `application.yml` files
2. Replace with environment variables
3. Test in local development environment

### Phase 2: Domain Grouping
1. Create domain-specific configuration directories
2. Migrate services to new Nacos groups
3. Update service discovery configurations

### Phase 3: Environment Separation
1. Create environment-specific configuration files
2. Set up CI/CD pipelines for each environment
3. Validate deployments in staging

### Phase 4: Production Rollout
1. Deploy infrastructure components first
2. Roll out domain by domain
3. Monitor and validate each domain

---

## 📋 Service Registry Example

### Nacos Configuration

```yaml
# booking-domain services register to BOOKING_GROUP
spring:
  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_ADDRS}
        namespace: ${NACOS_NAMESPACE}
        group: BOOKING_GROUP
        
# customer-domain services register to CUSTOMER_GROUP
spring:
  cloud:
    nacos:
      discovery:
        server-addr: ${NACOS_ADDRS}
        namespace: ${NACOS_NAMESPACE}
        group: CUSTOMER_GROUP
```

---

## 🔧 Maintenance

### Adding New Services
1. Identify the appropriate domain group
2. Follow naming conventions: `ts-{domain}-{service}-service`
3. Register to the correct Nacos group
4. Update this documentation

### Refactoring Services
1. Document the business justification
2. Plan migration path
3. Update dependent services
4. Communicate changes to all teams

---

## 📞 Support

For questions or issues related to service grouping and configuration:
- Create an issue in the project repository
- Contact the platform team
- Review the Train Ticket documentation

---

**Last Updated:** October 2025  
**Maintained By:** Platform Engineering Team