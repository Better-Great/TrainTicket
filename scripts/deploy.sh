#!/bin/bash

# Enhanced Deploy script for Train Ticket microservices
# Usage: ./deploy.sh [service-name] or ./deploy.sh all

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

# Function to deploy a single service
deploy_service() {
    local service_name=$1
    local service_dir="ts-$service_name-service"
    
    if [ ! -d "$service_dir" ]; then
        echo -e "${RED}✗ $service_dir: Directory not found${NC}"
        return 1
    fi
    
    # Find the JAR file in target directory
    local jar_file=$(find "$service_dir/target" -name "*.jar" -not -path "*/original-*" 2>/dev/null | head -1)
    
    if [ -z "$jar_file" ] || [ ! -f "$jar_file" ]; then
        echo -e "${RED}✗ $service_name: No JAR file found in target directory${NC}"
        return 1
    fi
    
    # Copy JAR file to jar directory
    if cp "$jar_file" "$JAR_DIR/ts-$service_name-service.jar" 2>/dev/null; then
        echo -e "${GREEN}✓ $service_name: Deployed successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ $service_name: Failed to copy JAR file${NC}"
        return 1
    fi
}

# Function to deploy all services
deploy_all_services() {
    echo -e "${YELLOW}=========================================="
    echo -e "Deploying All Train Ticket Microservices"
    echo -e "==========================================${NC}"
    
    # Get all service directories
    local services=($(ls -d ts-*-service 2>/dev/null))
    
    if [ ${#services[@]} -eq 0 ]; then
        echo -e "${RED}No service directories found!${NC}"
        exit 1
    fi
    
    TOTAL_COUNT=${#services[@]}
    
    for service_dir in "${services[@]}"; do
        # Extract service name (remove ts- prefix and -service suffix)
        local service_name=${service_dir#ts-}
        service_name=${service_name%-service}
        
        if deploy_service "$service_name"; then
            ((SUCCESS_COUNT++))
        else
            ((FAILED_COUNT++))
        fi
    done
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
        ls -1 "$JAR_DIR"/*.jar 2>/dev/null | while read jar_file; do
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

# Function to setup jar directory
setup_jar_directory() {
    JAR_DIR="jar"
    if [ ! -d "$JAR_DIR" ]; then
        echo -e "${BLUE}Creating $JAR_DIR directory...${NC}"
        mkdir -p "$JAR_DIR"
    else
        echo -e "${BLUE}Clearing existing $JAR_DIR directory...${NC}"
        rm -rf "$JAR_DIR"/*
    fi
}

# Main script logic
main() {
    # Check if we're in the right directory
    if [ ! -f "pom.xml" ]; then
        echo -e "${RED}Error: pom.xml not found. Please run this script from the project root directory.${NC}"
        exit 1
    fi
    
    # Setup jar directory
    setup_jar_directory
    
    if [ $# -eq 0 ] || [ "$1" = "all" ]; then
        deploy_all_services
    else
        echo -e "${YELLOW}=========================================="
        echo -e "Deploying Specific Service: $1"
        echo -e "==========================================${NC}"
        TOTAL_COUNT=1
        if deploy_service "$1"; then
            ((SUCCESS_COUNT++))
        else
            ((FAILED_COUNT++))
        fi
    fi
    
    show_summary
}

# Run main function with all arguments
main "$@"
