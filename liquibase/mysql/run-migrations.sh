#!/bin/bash

# ============================================================================
# Liquibase Migration Runner Script
# ============================================================================
# This script runs Liquibase migrations for TrainTicket MySQL databases.
# It handles downloading the MySQL JDBC driver if needed and runs migrations.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
DRIVER_JAR="$LIB_DIR/mysql-connector-java-8.0.25.jar"
DRIVER_URL="https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.25/mysql-connector-java-8.0.25.jar"

# Check if Liquibase is installed
if ! command -v liquibase &> /dev/null; then
    echo "Error: Liquibase is not installed or not in PATH"
    echo "Please install Liquibase from https://www.liquibase.org/download"
    exit 1
fi

# Create lib directory if it doesn't exist
mkdir -p "$LIB_DIR"

# Download MySQL JDBC driver if it doesn't exist
if [ ! -f "$DRIVER_JAR" ]; then
    echo "Downloading MySQL JDBC driver..."
    curl -L -o "$DRIVER_JAR" "$DRIVER_URL" || {
        echo "Error: Failed to download MySQL JDBC driver"
        echo "Please download it manually from: $DRIVER_URL"
        echo "And place it at: $DRIVER_JAR"
        exit 1
    }
fi

# Change to the liquibase/mysql directory
cd "$SCRIPT_DIR"

# Run migrations
echo "Running Liquibase migrations..."
liquibase --classpath="$DRIVER_JAR" update

echo "Migrations completed successfully!"

