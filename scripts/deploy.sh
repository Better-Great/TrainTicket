#!/bin/bash
# Copy built JARs from each service target/ into jar/ (or a custom path).
# Usage: ./scripts/deploy.sh [service-name|all] [output-dir]
#   - service-name|all: which service(s) to deploy; default "all"
#   - output-dir: where to place JARs; default is jar/ in project root
# Examples:
#   ./scripts/deploy.sh              → all services → jar/
#   ./scripts/deploy.sh all          → all services → jar/
#   ./scripts/deploy.sh all /tmp/jars → all services → /tmp/jars
#   ./scripts/deploy.sh user /opt/deploy → ts-user-service → /opt/deploy
# Run from project root, or script will cd to project root automatically.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# JAR_DIR is set in main() from args; default jar/

SUCCESS_COUNT=0
FAILED_COUNT=0
TOTAL_COUNT=0

deploy_service() {
    local service_name=$1
    local service_dir="$PROJECT_ROOT/ts-$service_name-service"

    if [ ! -d "$service_dir" ]; then
        echo -e "${RED}✗ ts-$service_name-service: Directory not found${NC}"
        return 1
    fi

    [ ! -f "$service_dir/pom.xml" ] && echo -e "${YELLOW}⊘ ts-$service_name-service: Not a Java service (no pom.xml), skipping${NC}" && return 0

    local jar_file
    jar_file=$(find "$service_dir/target" -maxdepth 1 -name "*.jar" ! -name "original-*" -type f 2>/dev/null | head -1)

    if [ -z "$jar_file" ] || [ ! -f "$jar_file" ]; then
        echo -e "${RED}✗ $service_name: No JAR in target/ (build first: mvn clean install)${NC}"
        return 1
    fi

    mkdir -p "$JAR_DIR"
    if cp "$jar_file" "$JAR_DIR/ts-$service_name-service.jar"; then
        echo -e "${GREEN}✓ $service_name → $JAR_DIR/ts-$service_name-service.jar${NC}"
        return 0
    else
        echo -e "${RED}✗ $service_name: Failed to copy${NC}"
        return 1
    fi
}

deploy_all_services() {
    echo -e "${YELLOW}Deploying all Java service JARs into $JAR_DIR/${NC}"
    echo ""

    mkdir -p "$JAR_DIR"
    rm -f "$JAR_DIR"/*.jar 2>/dev/null || true

    local count=0
    for dir in "$PROJECT_ROOT"/ts-*-service; do
        [ -d "$dir" ] || continue
        [ -f "$dir/pom.xml" ] || continue
        local base
        base=$(basename "$dir")
        local service_name="${base#ts-}"
        service_name="${service_name%-service}"
        count=$((count + 1))
        TOTAL_COUNT=$count
        if deploy_service "$service_name"; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    done

    if [ $count -eq 0 ]; then
        echo -e "${RED}No Java service directories (ts-*-service with pom.xml) found.${NC}"
        exit 1
    fi
}

# Function to show deployment summary
show_summary() {
    echo -e "\n${YELLOW}=========================================="
    echo -e "Deployment Summary"
    echo -e "==========================================${NC}"
    echo -e "Total Services: $TOTAL_COUNT"
    echo -e "${GREEN}Successfully Deployed: $SUCCESS_COUNT${NC}"
    echo -e "${RED}Failed: $FAILED_COUNT${NC}"
    
    if [ $SUCCESS_COUNT -gt 0 ]; then
        echo -e "\n${BLUE}Deployed JAR files in $JAR_DIR/:${NC}"
        ls -1 "$JAR_DIR"/*.jar 2>/dev/null | while read -r jar_file; do
            [ -f "$jar_file" ] || continue
            local filename=$(basename "$jar_file")
            local size=$(ls -lh "$jar_file" | awk '{print $5}')
            echo -e "  ${GREEN}✓${NC} $filename ($size)"
        done
    fi
    
    if [ $FAILED_COUNT -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All deployments completed successfully!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some deployments failed. Check the output above.${NC}"
        exit 1
    fi
}

main() {
    cd "$PROJECT_ROOT"
    if ! ls -d ts-*-service 1>/dev/null 2>&1; then
        echo -e "${RED}Error: No ts-*-service directories found. Run from TrainTicket project root.${NC}"
        exit 1
    fi

    # Parse args: [service-name|all] [output-dir]
    local target="all"
    local output_arg=""

    if [ $# -ge 1 ] && [ "$1" != "all" ]; then
        target="$1"
    fi
    if [ $# -ge 2 ]; then
        output_arg="$2"
    fi

    # Resolve JAR_DIR: default jar/, or custom path (relative to project root or absolute)
    if [ -n "$output_arg" ]; then
        if [[ "$output_arg" == /* ]]; then
            JAR_DIR="$output_arg"
        else
            JAR_DIR="$PROJECT_ROOT/$output_arg"
        fi
    else
        JAR_DIR="$PROJECT_ROOT/jar"
    fi
    mkdir -p "$JAR_DIR"
    JAR_DIR="$(cd "$JAR_DIR" && pwd)"

    if [ "$target" = "all" ]; then
        deploy_all_services
    else
        echo -e "${YELLOW}Deploying: $target → $JAR_DIR/ts-$target-service.jar${NC}"
        echo ""
        TOTAL_COUNT=1
        if deploy_service "$target"; then
            SUCCESS_COUNT=1
        else
            FAILED_COUNT=1
        fi
    fi

    show_summary
}

main "$@"