#!/bin/bash

# Build script for Token Replacement Service

echo "=========================================="
echo "Building Token Replacement Service"
echo "=========================================="

# Navigate to the service directory
cd "$(dirname "$0")"

# Clean and build
echo "Cleaning previous build..."
mvn clean

echo ""
echo "Building JAR..."
mvn package

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Build successful!"
    echo "=========================================="
    echo "JAR location: target/token-replacement-service.jar"
    echo ""
    echo "To run the service:"
    echo "  ./run.sh <environment>"
    echo ""
    echo "Example:"
    echo "  ./run.sh dev"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "Build failed!"
    echo "=========================================="
    exit 1
fi

