#!/bin/bash

# Run script for Token Replacement Service

if [ $# -lt 1 ]; then
    echo "Usage: ./run.sh <environment> [project-root]"
    echo ""
    echo "Arguments:"
    echo "  environment  - The environment name (e.g., dev, qa, prod)"
    echo "  project-root - Optional. Root directory of the TrainTicket project"
    echo ""
    echo "Example:"
    echo "  ./run.sh dev"
    echo "  ./run.sh qa /path/to/TrainTicket"
    exit 1
fi

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JAR_FILE="$SCRIPT_DIR/target/token-replacement-service.jar"

# Check if JAR exists
if [ ! -f "$JAR_FILE" ]; then
    echo "ERROR: JAR file not found: $JAR_FILE"
    echo ""
    echo "Please build the project first:"
    echo "  ./build.sh"
    exit 1
fi

# Determine project root
if [ $# -ge 2 ]; then
    PROJECT_ROOT="$2"
else
    # Default to parent directory of this service
    PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Run the service
echo "Running Token Replacement Service..."
echo "Environment: $1"
echo "Project Root: $PROJECT_ROOT"
echo ""

java -jar "$JAR_FILE" "$1" "$PROJECT_ROOT"

