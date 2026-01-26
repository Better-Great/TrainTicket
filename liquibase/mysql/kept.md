# Train Ticket - Liquibase Setup & Execution Guide

A comprehensive guide to set up and run database migrations with Liquibase 5.0.1 and the Train Ticket application without common pitfalls.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Java Setup (Dual Version)](#java-setup-dual-version)
- [Liquibase Installation](#liquibase-installation)
- [MySQL Database Setup](#mysql-database-setup)
- [Liquibase Configuration](#liquibase-configuration)
- [Running Migrations](#running-migrations)
- [Running Train Ticket Application](#running-train-ticket-application)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Ubuntu/Debian-based Linux system
- MySQL 8.0+ running on port 3307
- Maven installed
- Git (for cloning Train Ticket repository)

---

## Java Setup (Dual Version)

Train Ticket requires **Java 8**, but Liquibase 5.0.1 requires **Java 17**. We'll install both and configure them to coexist.

### Install Both Java Versions

```bash
# Install Java 8 (for Train Ticket)
sudo apt-get update
sudo apt-get install openjdk-8-jdk

# Install Java 17 (for Liquibase)
sudo apt-get install openjdk-17-jdk

# Verify both are installed
update-alternatives --list java
```

You should see both:
```
/usr/lib/jvm/java-8-openjdk-amd64/bin/java
/usr/lib/jvm/java-17-openjdk-amd64/bin/java
```

### Configure Bash Aliases

Edit your `~/.bashrc` file:

```bash
nano ~/.bashrc
```

Add these lines at the end:

```bash
# Default to Java 8 for Train Ticket and general use
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Create alias for Liquibase with Java 17
alias liquibase17='JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 /usr/bin/liquibase'

# Optional: Maven with Java 8 (for clarity)
alias mvn8='JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 mvn'
```

Save and reload:

```bash
source ~/.bashrc
```

### Verify Setup

```bash
# Should show Java 8
java -version

# Should show Java 17 with Liquibase 5.0.1
liquibase17 --version

# Should show Maven with Java 8
mvn8 --version
```

---

## Liquibase Installation

### Add Liquibase Repository

```bash
# Download and add GPG key
wget -O- https://repo.liquibase.com/liquibase.asc | gpg --dearmor > liquibase-keyring.gpg && \
cat liquibase-keyring.gpg | sudo tee /usr/share/keyrings/liquibase-keyring.gpg > /dev/null

# Add repository
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/liquibase-keyring.gpg] https://repo.liquibase.com stable main' | sudo tee /etc/apt/sources.list.d/liquibase.list
```

### Install Liquibase

```bash
# Update and install
sudo apt-get update
sudo apt-get install liquibase

# Verify installation
liquibase17 --version
```

Expected output:
```
Starting Liquibase at ... using Java 17.0.17 (version 5.0.1 ...)
Liquibase Version: 5.0.1
```

---

## MySQL Database Setup

### Create MySQL User

```bash
# Connect to MySQL
mysql -h 127.0.0.1 -P 3307 -u root -p

# Create user and grant privileges
CREATE USER 'beta'@'%' IDENTIFIED BY 'beta123';
GRANT ALL PRIVILEGES ON *.* TO 'beta'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit;
```

### Create Liquibase Tracking Database

This database stores Liquibase's changelog history and should be separate from your application databases.

```bash
# Create dedicated Liquibase tracking database
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 -e "CREATE DATABASE IF NOT EXISTS liquibase_tracking CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

**Why a separate database?**
- Keeps Liquibase tracking isolated from application data
- Prevents conflicts with MySQL system tables
- Makes it easy to reset migrations without affecting MySQL system configuration

---

## Liquibase Configuration

### Navigate to Liquibase Directory

```bash
cd ~/Devops/TrainTicket/liquibase/mysql
```

### Configure liquibase.properties

Edit the `liquibase.properties` file:

```bash
nano liquibase.properties
```

Ensure it contains:

```properties
# ============================================================================
# Liquibase Configuration for TrainTicket MySQL Databases
# ============================================================================

driver: com.mysql.cj.jdbc.Driver
url: jdbc:mysql://localhost:3307/liquibase_tracking?useSSL=false&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8
username: beta
password: beta123
changeLogFile: master-changelog.yaml
classpath: lib/mysql-connector-java-8.0.33.jar

# Note: Liquibase creates DATABASECHANGELOG and DATABASECHANGELOGLOCK tables 
# automatically in the liquibase_tracking database
```

**Key Points:**
- URL points to `liquibase_tracking` database (NOT `mysql` system database)
- This database only stores Liquibase's tracking tables
- Application databases (`ts-auth-mysql`, `ts-order-mysql`, etc.) are created by the changesets

### Verify MySQL Connector

Ensure the MySQL connector JAR exists:

```bash
ls -l lib/mysql-connector-java-8.0.33.jar
```

If missing, download it:

```bash
mkdir -p lib
cd lib
wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.33/mysql-connector-java-8.0.33.jar
cd ..
```

---

## Running Migrations

### First-Time Setup (Clean Database)

```bash
cd ~/Devops/TrainTicket/liquibase/mysql

# Run all migrations
liquibase17 update
```

Expected output:
```
Running Changeset: ts-auth/001-create-database.yaml::create-ts-auth-database::devops
Running Changeset: ts-auth/002-create-tables.yaml::create-auth-user-table::devops
...
UPDATE SUMMARY
Run:                         28
Previously run:               0
Filtered out:                 0
-------------------------------
Total change sets:           28

Liquibase: Update has been successful.
```

### Reset Everything (Nuclear Option)

If you need to start completely fresh:

```bash
cd ~/Devops/TrainTicket/liquibase/mysql

# 1. Clear Liquibase tracking
liquibase17 clear-checksums
liquibase17 drop-all

# 2. Drop all Train Ticket databases
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 -e "
DROP DATABASE IF EXISTS \`ts-auth-mysql\`;
DROP DATABASE IF EXISTS \`ts-assurance-mysql\`;
DROP DATABASE IF EXISTS \`ts-admin-basic-info-mysql\`;
DROP DATABASE IF EXISTS \`ts-admin-order-mysql\`;
DROP DATABASE IF EXISTS \`ts-admin-route-mysql\`;
DROP DATABASE IF EXISTS \`ts-admin-travel-mysql\`;
DROP DATABASE IF EXISTS \`ts-admin-user-mysql\`;
DROP DATABASE IF EXISTS \`ts-basic-mysql\`;
DROP DATABASE IF EXISTS \`ts-config-mysql\`;
DROP DATABASE IF EXISTS \`ts-contacts-mysql\`;
DROP DATABASE IF EXISTS \`ts-consign-mysql\`;
DROP DATABASE IF EXISTS \`ts-consign-price-mysql\`;
DROP DATABASE IF EXISTS \`ts-food-mysql\`;
DROP DATABASE IF EXISTS \`ts-food-delivery-mysql\`;
DROP DATABASE IF EXISTS \`ts-inside-payment-mysql\`;
DROP DATABASE IF EXISTS \`ts-news-mysql\`;
DROP DATABASE IF EXISTS \`ts-notification-mysql\`;
DROP DATABASE IF EXISTS \`ts-order-mysql\`;
DROP DATABASE IF EXISTS \`ts-order-other-mysql\`;
DROP DATABASE IF EXISTS \`ts-payment-mysql\`;
DROP DATABASE IF EXISTS \`ts-preserve-mysql\`;
DROP DATABASE IF EXISTS \`ts-preserve-other-mysql\`;
DROP DATABASE IF EXISTS \`ts-price-mysql\`;
DROP DATABASE IF EXISTS \`ts-route-mysql\`;
DROP DATABASE IF EXISTS \`ts-security-mysql\`;
DROP DATABASE IF EXISTS \`ts-station-mysql\`;
DROP DATABASE IF EXISTS \`ts-ticket-office-mysql\`;
DROP DATABASE IF EXISTS \`ts-train-mysql\`;
DROP DATABASE IF EXISTS \`ts-travel-mysql\`;
DROP DATABASE IF EXISTS \`ts-user-mysql\`;
DROP DATABASE IF EXISTS \`ts-voucher-mysql\`;
" 2>/dev/null

# 3. Run migrations fresh
liquibase17 update
```

### Useful Liquibase Commands

```bash
# Check what changesets will run
liquibase17 status --verbose

# Mark all changesets as executed (without running them)
liquibase17 changelog-sync

# Release stuck locks
liquibase17 release-locks

# Rollback last changeset
liquibase17 rollback-count 1

# Generate SQL instead of executing
liquibase17 update-sql > migration.sql
```

---

## Running Train Ticket Application

### Using Java 8 Explicitly

```bash
# Navigate to a microservice
cd ~/Devops/TrainTicket/ts-auth-service

# Run with Java 8
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 mvn spring-boot:run

# Or use the alias
mvn8 spring-boot:run
```

### Verify Database Connections

Check that the application is connecting to the correct databases:

```bash
# List all Train Ticket databases
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 -e "SHOW DATABASES LIKE 'ts-%';"

# Check tables in a specific database
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 ts-auth-mysql -e "SHOW TABLES;"
```

---

## Troubleshooting

### Issue: "Waiting for changelog lock..."

**Cause:** Previous Liquibase process didn't release the lock (crash or Ctrl+C).

**Solution:**
```bash
# Option 1: Use Liquibase command
liquibase17 release-locks

# Option 2: Manual release via MySQL
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 liquibase_tracking -e "UPDATE DATABASECHANGELOGLOCK SET LOCKED=0, LOCKGRANTED=NULL, LOCKEDBY=NULL WHERE ID=1;"
```

---

### Issue: "Table 'DATABASECHANGELOG' already exists"

**Cause:** Mixing old Liquibase 3.x with new Liquibase 5.x, or running migrations on wrong database.

**Solution:**
```bash
# Clear the tracking database and start fresh
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 liquibase_tracking -e "DROP TABLE IF EXISTS DATABASECHANGELOG, DATABASECHANGELOGLOCK;"

liquibase17 update
```

---

### Issue: "LocalDateTime cannot be cast to String"

**Cause:** Using old Liquibase 3.10.3 instead of 5.0.1.

**Solution:** Verify you're using `liquibase17` alias (not `liquibase`):
```bash
liquibase17 --version  # Should show 5.0.1 with Java 17
```

If showing wrong version:
```bash
# Reinstall Liquibase
sudo apt-get install --reinstall liquibase

# Verify
liquibase17 --version
```

---

### Issue: "ERROR: The JVM version is 8. Liquibase requires Java 17"

**Cause:** Running `liquibase` command instead of `liquibase17` alias.

**Solution:** Always use `liquibase17` for Liquibase commands:
```bash
# Wrong (uses Java 8)
liquibase update

# Correct (uses Java 17)
liquibase17 update
```

---

### Issue: "Unknown database 'ts-auth-mysql'"

**Cause:** Database creation changeset was skipped because DATABASECHANGELOG said it already ran.

**Solution:**
```bash
# Clear changelog and run fresh
liquibase17 drop-all
liquibase17 update
```

---

### Issue: Application can't connect to database

**Symptoms:**
```
com.mysql.cj.jdbc.exceptions.CommunicationsException: Communications link failure
```

**Solution:**
1. Verify MySQL is running on port 3307:
   ```bash
   netstat -tlnp | grep 3307
   ```

2. Check database exists:
   ```bash
   mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 -e "SHOW DATABASES LIKE 'ts-%';"
   ```

3. Verify application.yml has correct connection string:
   ```yaml
   spring:
     datasource:
       url: jdbc:mysql://localhost:3307/ts-auth-mysql?useSSL=false
       username: beta
       password: beta123
   ```

---

## Quick Reference Commands

### Liquibase Operations
```bash
liquibase17 update              # Run all pending migrations
liquibase17 status              # Check migration status
liquibase17 changelog-sync      # Mark all as executed
liquibase17 rollback-count 1    # Rollback last changeset
liquibase17 clear-checksums     # Clear checksum cache
liquibase17 release-locks       # Release stuck locks
liquibase17 drop-all            # Drop all database objects
```

### MySQL Operations
```bash
# List all Train Ticket databases
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 -e "SHOW DATABASES LIKE 'ts-%';"

# Check Liquibase tracking
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 liquibase_tracking -e "SELECT COUNT(*) FROM DATABASECHANGELOG;"

# View applied changesets
mysql -h 127.0.0.1 -P 3307 -u beta -pbeta123 liquibase_tracking -e "SELECT ID, AUTHOR, FILENAME, DATEEXECUTED FROM DATABASECHANGELOG ORDER BY DATEEXECUTED DESC LIMIT 10;"
```

### Application Operations
```bash
# Run with Java 8
mvn8 spring-boot:run

# Or with explicit JAVA_HOME
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 mvn spring-boot:run
```

---

## Best Practices

1. **Always use `liquibase17`** for Liquibase operations (not `liquibase`)
2. **Use `mvn8` or explicit JAVA_HOME** for Train Ticket application
3. **Never manually modify DATABASECHANGELOG tables** unless troubleshooting
4. **Test migrations on development first** before production
5. **Backup your databases** before running `drop-all`
6. **Use `changelog-sync`** when schema is already correct
7. **Keep `liquibase_tracking` database separate** from application databases

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Train Ticket System                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Liquibase 5.0.1 (Java 17)                                  │
│  └── Connects to: liquibase_tracking DB                     │
│      └── Tracks: DATABASECHANGELOG, DATABASECHANGELOGLOCK   │
│                                                               │
│  Creates & Manages:                                          │
│  ├── ts-auth-mysql                                          │
│  ├── ts-order-mysql                                         │
│  ├── ts-payment-mysql                                       │
│  ├── ts-user-mysql                                          │
│  └── ... (24 more microservice databases)                   │
│                                                               │
│  Train Ticket App (Java 8)                                  │
│  └── Connects to: Individual ts-* databases                 │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary

You now have:
- ✅ Java 8 for Train Ticket application
- ✅ Java 17 for Liquibase 5.0.1
- ✅ Isolated Liquibase tracking database
- ✅ All Train Ticket microservice databases
- ✅ Working migration system
- ✅ No hanging issues
- ✅ No casting errors

**Happy coding!** 🚀