#!/bin/bash

# Enhanced Build script for Train Ticket microservices
# Usage: ./build.sh [service-name] or ./build.sh all

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
SUCCESS_COUNT=0
FAILED_COUNT=0
TOTAL_COUNT=0

# Function to build a single service (Java only; skips if no pom.xml)
build_service() {
    local service_name=$1
    local service_dir="ts-$service_name-service"
    
    if [ ! -d "$service_dir" ]; then
        echo -e "${RED}✗ $service_dir: Directory not found${NC}"
        return 1
    fi
    
    if [ ! -f "$service_dir/pom.xml" ]; then
        echo -e "${YELLOW}⊘ $service_dir: Not a Java service (no pom.xml), skipping${NC}"
        return 0
    fi
    
    echo -e "${BLUE}[$(date '+%H:%M:%S')] Building $service_dir...${NC}"
    
    # Build the service with minimal output
    cd "$service_dir"
    if mvn clean install -DskipTests -q > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $service_dir: Build successful${NC}"
        cd ..
        return 0
    else
        echo -e "${RED}✗ $service_dir: Build failed${NC}"
        echo -e "${YELLOW}  → Run 'cd $service_dir && mvn clean install' for detailed error${NC}"
        cd ..
        return 1
    fi
}

# Function to build all services (Java only; skips ts-*-service dirs without pom.xml)
build_all_services() {
    echo -e "${YELLOW}=========================================="
    echo -e "Building All Train Ticket Microservices (Java)"
    echo -e "==========================================${NC}"
    
    local count=0
    for service_dir in ts-*-service; do
        [ -d "$service_dir" ] || continue
        [ -f "$service_dir/pom.xml" ] || continue
        local service_name=${service_dir#ts-}
        service_name=${service_name%-service}
        count=$((count + 1))
        TOTAL_COUNT=$count
        if build_service "$service_name"; then
            ((SUCCESS_COUNT++))
        else
            ((FAILED_COUNT++))
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${RED}No Java service directories (ts-*-service with pom.xml) found.${NC}"
        exit 1
    fi
}

# Function to show build summary
show_summary() {
    echo -e "\n${YELLOW}=========================================="
    echo -e "Build Summary"
    echo -e "==========================================${NC}"
    echo -e "Total Services: $TOTAL_COUNT"
    echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
    echo -e "${RED}Failed: $FAILED_COUNT${NC}"
    
    if [ $FAILED_COUNT -eq 0 ]; then
        echo -e "\n${GREEN}🎉 All builds completed successfully!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some builds failed. Check the output above.${NC}"
        exit 1
    fi
}

# Main script logic
main() {
    # Check if we're in the right directory
    if [ ! -f "pom.xml" ]; then
        echo -e "${RED}Error: pom.xml not found. Please run this script from the project root directory.${NC}"
        exit 1
    fi
    
    if [ $# -eq 0 ] || [ "$1" = "all" ]; then
        build_all_services
    else
        echo -e "${YELLOW}=========================================="
        echo -e "Building Specific Service: $1"
        echo -e "==========================================${NC}"
        TOTAL_COUNT=1
        if build_service "$1"; then
            ((SUCCESS_COUNT++))
        else
            ((FAILED_COUNT++))
        fi
    fi
    
    show_summary
}

# Run main function with all arguments
main "$@"
