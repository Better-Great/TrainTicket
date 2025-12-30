# MySQL Liquibase Migrations

This directory contains version-controlled database migrations for all TrainTicket MySQL databases using Liquibase.

## Structure

```
liquibase/mysql/
├── master-changelog.yaml          # Main changelog that includes all services
├── liquibase.properties           # Liquibase configuration
├── ts-auth/                       # Auth service migrations
│   ├── changelog.yaml
│   └── 001-create-database.yaml
├── ts-assurance/                  # Assurance service migrations
│   ├── changelog.yaml
│   └── 001-create-database.yaml
├── ts-user/                       # User service migrations
│   ├── changelog.yaml
│   └── 001-create-database.yaml
├── ts-consign-price/              # Consign Price service migrations
│   ├── changelog.yaml
│   ├── 001-create-database.yaml
│   └── 002-create-tables.yaml
└── ts-consign/                    # Consign service migrations
    ├── changelog.yaml
    ├── 001-create-database.yaml
    └── 002-create-tables.yaml
```

## Prerequisites

1. **Install Liquibase**: 
   ```bash
   # Download from https://www.liquibase.org/download
   # Or use package manager
   wget https://github.com/liquibase/liquibase/releases/download/v4.24.0/liquibase-4.24.0.tar.gz
   tar -xzf liquibase-4.24.0.tar.gz
   export PATH=$PATH:$(pwd)/liquibase
   ```

2. **MySQL JDBC Driver**: Download `mysql-connector-java-8.0.25.jar` and place it in `liquibase/mysql/lib/` directory

3. **MySQL Running**: Ensure MySQL is running on `localhost:3307` (or update `liquibase.properties`)

## Usage

### Run All Migrations
```bash
cd liquibase/mysql
liquibase --classpath=lib/mysql-connector-java-8.0.25.jar update
```

### Check Migration Status
```bash
cd liquibase/mysql
liquibase --classpath=lib/mysql-connector-java-8.0.25.jar status
```

### Rollback Last Migration
```bash
cd liquibase/mysql
liquibase --classpath=lib/mysql-connector-java-8.0.25.jar rollback-count 1
```

### Generate SQL (Preview Changes)
```bash
cd liquibase/mysql
liquibase --classpath=lib/mysql-connector-java-8.0.25.jar update-sql
```

## Adding New Migrations

1. **For a new service**: Create a new directory (e.g., `ts-contacts/`)
2. **Create changelog.yaml**: Include your migration files
3. **Create migration files**: Number them sequentially (001-, 002-, etc.)
4. **Add to master-changelog.yaml**: Include the new service's changelog

Example:
```yaml
# In master-changelog.yaml
- include:
    file: ts-contacts/changelog.yaml
    relativeToChangelogFile: true
```

## Database Naming Convention

- Database names use **hyphens** (e.g., `ts-consign-mysql`)
- All database names are wrapped in backticks in SQL for MySQL compatibility
- Character set: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`

## Best Practices

1. **One changeSet per logical change**: Each migration file should contain related changes
2. **Sequential numbering**: Use 001-, 002-, etc. for ordering
3. **Descriptive comments**: Always include comments explaining the change
4. **Test migrations**: Always test on a development database first
5. **Version control**: All changelog files should be committed to git

## Troubleshooting

- **Connection issues**: Check `liquibase.properties` for correct MySQL connection details
- **Driver not found**: Ensure MySQL JDBC driver is in `lib/` directory
- **Migration already applied**: Liquibase tracks applied migrations in `DATABASECHANGELOG` table
