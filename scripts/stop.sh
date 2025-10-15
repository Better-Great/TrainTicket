#!/bin/bash

# Train Ticket Microservices - Local Stop Script
# Stops all locally running services

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# PID file to track all started services
PID_FILE="$PROJECT_ROOT/.services.pid"

# Counters
STOPPED_COUNT=0
FAILED_COUNT=0
NOT_RUNNING_COUNT=0

# Function to print section header
print_header() {
    echo -e "\n${CYAN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}\n"
}

# Function to stop a service by PID
stop_service() {
    local pid=$1
    local service_name=$2
    local port=$3
    
    # Check if process is running
    if ! ps -p $pid > /dev/null 2>&1; then
        echo -e "${BLUE}○ $service_name (Port $port): Already stopped${NC}"
        ((NOT_RUNNING_COUNT++))
        return 1
    fi
    
    # Try graceful shutdown first (SIGTERM)
    kill -15 $pid 2>/dev/null
    
    # Wait up to 5 seconds for graceful shutdown
    local count=0
    while [ $count -lt 10 ]; do
        if ! ps -p $pid > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $service_name (Port $port): Stopped gracefully${NC}"
            ((STOPPED_COUNT++))
            return 0
        fi
        sleep 0.5
        ((count++))
    done
    
    # Force kill if still running (SIGKILL)
    if ps -p $pid > /dev/null 2>&1; then
        kill -9 $pid 2>/dev/null
        sleep 0.5
        
        if ! ps -p $pid > /dev/null 2>&1; then
            echo -e "${YELLOW}⚠ $service_name (Port $port): Force killed${NC}"
            ((STOPPED_COUNT++))
            return 0
        else
            echo -e "${RED}✗ $service_name (Port $port): Failed to stop${NC}"
            ((FAILED_COUNT++))
            return 1
        fi
    fi
}

# Function to stop services from PID file
stop_from_pid_file() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}No PID file found. Will search for running processes...${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Stopping services from PID file...${NC}\n"
    
    while IFS=':' read -r pid service_name port; do
        if [ -n "$pid" ] && [ -n "$service_name" ]; then
            stop_service "$pid" "$service_name" "$port"
        fi
    done < "$PID_FILE"
    
    return 0
}

# Function to find and stop any remaining Java services
stop_java_services() {
    echo -e "\n${BLUE}Searching for any remaining Java services...${NC}\n"
    
    # Find Java processes related to train ticket services
    local found_services=false
    
    while IFS= read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local jar_path=$(echo "$line" | grep -o "ts-.*-service.*\.jar" | head -1)
        
        if [ -n "$pid" ] && [ -n "$jar_path" ]; then
            found_services=true
            local service_name=$(echo "$jar_path" | sed 's/.*\/\(ts-[^/]*-service\).*/\1/')
            echo -e "${YELLOW}Found: $service_name (PID: $pid)${NC}"
            kill -15 $pid 2>/dev/null || kill -9 $pid 2>/dev/null
            sleep 0.3
            if ! ps -p $pid > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Stopped $service_name${NC}"
                ((STOPPED_COUNT++))
            fi
        fi
    done < <(ps aux | grep -E "java.*ts-.*-service.*\.jar" | grep -v grep)
    
    if [ "$found_services" = false ]; then
        echo -e "${BLUE}No additional Java services found${NC}"
    fi
}

# Function to find and stop any Python services
stop_python_services() {
    echo -e "\n${BLUE}Searching for Python services...${NC}\n"
    
    local found_services=false
    
    while IFS= read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        local script=$(echo "$line" | grep -o "server\.py\|main\.py" | head -1)
        
        if [ -n "$pid" ] && [ -n "$script" ]; then
            found_services=true
            echo -e "${YELLOW}Found: Python service (PID: $pid)${NC}"
            kill -15 $pid 2>/dev/null || kill -9 $pid 2>/dev/null
            sleep 0.3
            if ! ps -p $pid > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Stopped Python service${NC}"
                ((STOPPED_COUNT++))
            fi
        fi
    done < <(ps aux | grep -E "python3.*(server\.py|main\.py)" | grep -v grep)
    
    if [ "$found_services" = false ]; then
        echo -e "${BLUE}No Python services found${NC}"
    fi
}

# Function to find and stop UI services
stop_ui_services() {
    echo -e "\n${BLUE}Searching for UI services...${NC}\n"
    
    local found_services=false
    
    while IFS= read -r line; do
        local pid=$(echo "$line" | awk '{print $2}')
        
        if [ -n "$pid" ]; then
            found_services=true
            echo -e "${YELLOW}Found: UI service on port 8080 (PID: $pid)${NC}"
            kill -15 $pid 2>/dev/null || kill -9 $pid 2>/dev/null
            sleep 0.3
            if ! ps -p $pid > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Stopped UI service${NC}"
                ((STOPPED_COUNT++))
            fi
        fi
    done < <(ps aux | grep "python3 -m http.server 8080" | grep -v grep)
    
    if [ "$found_services" = false ]; then
        echo -e "${BLUE}No UI services found${NC}"
    fi
}

# Function to show cleanup options
show_cleanup_options() {
    print_header "🧹 Cleanup Options"
    
    echo -e "${YELLOW}Do you want to clean up log files?${NC}\n"
    echo -e "1. ${CYAN}Delete all log files${NC}"
    echo -e "2. ${CYAN}Keep log files${NC}"
    echo ""
    
    read -p "Enter your choice (1-2): " cleanup_choice
    
    case $cleanup_choice in
        1)
            if [ -d "$PROJECT_ROOT/logs" ]; then
                echo -e "\n${YELLOW}Deleting log files...${NC}"
                rm -rf "$PROJECT_ROOT/logs"/*
                echo -e "${GREEN}✓ Log files deleted${NC}"
            else
                echo -e "\n${BLUE}No logs directory found${NC}"
            fi
            ;;
        2|*)
            echo -e "\n${BLUE}Keeping log files${NC}"
            ;;
    esac
}

# Main execution
main() {
    cd "$PROJECT_ROOT"
    
    print_header "🛑 Train Ticket - Local Services Shutdown"
    
    echo -e "${YELLOW}Stopping all locally running services...${NC}\n"
    
    # Stop services from PID file
    stop_from_pid_file
    
    # Search for and stop any remaining services
    stop_java_services
    stop_python_services
    stop_ui_services
    
    print_header "📊 Shutdown Summary"
    
    echo -e "${GREEN}Stopped:${NC} $STOPPED_COUNT"
    echo -e "${BLUE}Not Running:${NC} $NOT_RUNNING_COUNT"
    echo -e "${RED}Failed:${NC} $FAILED_COUNT"
    echo ""
    
    if [ $STOPPED_COUNT -gt 0 ]; then
        echo -e "${GREEN}✓ Services have been stopped${NC}\n"
    else
        echo -e "${BLUE}No services were running${NC}\n"
    fi
    
    # Clean up PID file
    if [ -f "$PID_FILE" ]; then
        rm "$PID_FILE"
        echo -e "${GREEN}✓ Cleaned up PID file${NC}"
    fi
    
    # Ask about log cleanup
    show_cleanup_options
    
    print_header "✅ Shutdown Complete"
    
    echo -e "${CYAN}To start services again: ${GREEN}./scripts/start.sh${NC}"
    echo -e "${CYAN}To check if any services are still running: ${GREEN}ps aux | grep -E 'ts-.*-service'${NC}"
    echo ""
}

# Run main function
main "$@"
