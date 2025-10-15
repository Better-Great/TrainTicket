#!/bin/bash

# Convenience script to build and run Token Replacement Service in one command

if [ $# -lt 1 ]; then
    echo "Usage: ./replace-tokens.sh <environment> [project-root]"
    echo ""
    echo "This script will build the service (if needed) and run the token replacement."
    echo ""
    echo "Arguments:"
    echo "  environment  - The environment name (e.g., dev, qa, prod)"
    echo "  project-root - Optional. Root directory of the TrainTicket project"
    echo ""
    echo "Example:"
    echo "  ./replace-tokens.sh dev"
    echo "  ./replace-tokens.sh qa /path/to/TrainTicket"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

JAR_FILE="$SCRIPT_DIR/target/token-replacement-service.jar"

# Build if JAR doesn't exist
if [ ! -f "$JAR_FILE" ]; then
    echo "JAR not found. Building..."
    ./build.sh
    
    if [ $? -ne 0 ]; then
        echo "Build failed. Exiting."
        exit 1
    fi
fi

# Run the service
./run.sh "$@"

