# Non-Java Services – Run & Verify Guide

This document covers **ts-voucher-service** (Python), **ts-ui-dashboard** (static/nginx), and **ts-ticket-office-service** (Node.js).

---

## 1. ts-voucher-service (Python/Tornado)

**Type:** Python 3 with Tornado  
**Port:** 16101  
**Database:** MySQL `ts-voucher-mysql`  
**Dependencies:** tornado, pymysql, cryptography  

### Run locally

```bash
cd ts-voucher-service

# Activate virtual environment
source .venv/bin/activate   # Linux/macOS
# or: .venv\Scripts\activate  # Windows

# Dependencies already installed in .venv (or: pip install -r requirements.txt)

# Set env if MySQL is on different host (e.g. Docker on localhost:3307)
export VOUCHER_MYSQL_HOST=127.0.0.1
export VOUCHER_MYSQL_PORT=3307
export VOUCHER_MYSQL_USER=root
export VOUCHER_MYSQL_PASSWORD=root
export VOUCHER_MYSQL_DATABASE=ts-voucher-mysql

python server.py
```

### Verify

```bash
curl -X POST http://localhost:16101/getVoucher -H "Content-Type: application/json" \
  -d '{"orderId":"test-id","type":"0"}' 
```

### Unit tests

No automated unit tests (no pytest/test_*.py).

---

## 2. ts-ui-dashboard (Static + Nginx)

**Type:** Static HTML/CSS/JS served by OpenResty/nginx  
**Port:** 8080  
**Dependencies:** None (static files)  

### Run via Docker

```bash
docker compose -f docker-compose.minimal.yml up -d ts-ui-dashboard
```

### Run locally

```bash
cd ts-ui-dashboard
./run-local.sh
# or: python3 -m http.server 8080 --directory static
```

Serves static files on http://localhost:8080. For `/api/v1/` proxy to gateway, use Docker or nginx.

### Verify

Open http://localhost:8080 – dashboard should load.  
`/api/v1/` is proxied to ts-gateway-service (only works when gateway is running).

### Unit tests

No unit tests (static frontend).

---

## 3. ts-ticket-office-service (Node.js/Express)

**Type:** Node.js with Express  
**Port:** 16108  
**Database:** MySQL `ts-ticket-office-mysql`  

### Run locally

```bash
cd ts-ticket-office-service
npm install

# Copy .env.example and edit, or set env vars (defaults in .env for local dev)
# TICKET_OFFICE_MYSQL_HOST=127.0.0.1 TICKET_OFFICE_MYSQL_PORT=3307 etc.

npm start
```

For local dev, a `.env` file (gitignored) with MySQL config is used if present. In Docker/K8s, env vars are set by the orchestrator.

### Verify

```bash
# Welcome
curl http://localhost:16108/office

# Get region list
curl http://localhost:16108/office/getRegionList
```

### Manual test (test.sh)

```bash
./test.sh  # curl POST to updateOffice endpoint
```

### Unit tests

No automated unit tests (no `npm test` in package.json).

---

## Database setup

`ts-voucher-mysql` and `ts-ticket-office-mysql` are created by `docker/mysql-init.sql` when MySQL starts.

If MySQL was already running before these were added, create them manually:

```sql
CREATE DATABASE IF NOT EXISTS `ts-voucher-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `ts-ticket-office-mysql` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `ts-voucher-mysql`.* TO 'beta'@'%';
GRANT ALL PRIVILEGES ON `ts-ticket-office-mysql`.* TO 'beta'@'%';
```

---

## Java unit tests (reference)

For Java services, unit tests run during build:

```bash
mvn test -pl ts-user-service
# or for all
mvn test
```
