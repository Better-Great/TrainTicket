#!/bin/bash

# Train Ticket Microservices - Local Start Script
# Starts all services locally (not in Docker) for testing

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
LOG_DIR="$PROJECT_ROOT/logs"

# Counters
STARTED_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

# Function to print section header
print_header() {
    echo -e "\n${CYAN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}\n"
}

# Function to create logs directory
setup_logs() {
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo -e "${GREEN}✓ Created logs directory${NC}"
    fi
    
    # Clear old PID file
    > "$PID_FILE"
}

# Function to start a Java service
start_java_service() {
    local service_dir=$1
    local service_name=$(basename "$service_dir")
    local port=$2
    
    cd "$PROJECT_ROOT/$service_dir"
    
    # Check if JAR file exists
    local jar_file=$(find target -name "*.jar" -type f 2>/dev/null | head -1)
    
    if [ -z "$jar_file" ]; then
        echo -e "${YELLOW}⊘ $service_name: JAR not found (skipped)${NC}"
        ((SKIPPED_COUNT++))
        return 1
    fi
    
    # Check if already running on this port
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ $service_name: Port $port already in use (skipped)${NC}"
        ((SKIPPED_COUNT++))
        return 1
    fi
    
    # Start the service with nohup
    nohup java -Xmx200m -jar "$jar_file" > "$LOG_DIR/$service_name.log" 2>&1 &
    local pid=$!
    
    # Save PID
    echo "$pid:$service_name:$port" >> "$PID_FILE"
    
    # Wait a moment and check if still running
    sleep 0.5
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $service_name${NC} ${BLUE}→${NC} Port $port ${BLUE}(PID: $pid)${NC}"
        ((STARTED_COUNT++))
        return 0
    else
        echo -e "${RED}✗ $service_name: Failed to start${NC}"
        ((FAILED_COUNT++))
        return 1
    fi
}

# Function to start Python service
start_python_service() {
    local service_dir=$1
    local service_name=$(basename "$service_dir")
    local port=$2
    local script_name=${3:-"server.py"}
    
    cd "$PROJECT_ROOT/$service_dir"
    
    # Check if Python script exists
    if [ ! -f "$script_name" ]; then
        echo -e "${YELLOW}⊘ $service_name: $script_name not found (skipped)${NC}"
        ((SKIPPED_COUNT++))
        return 1
    fi
    
    # Check if already running on this port
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ $service_name: Port $port already in use (skipped)${NC}"
        ((SKIPPED_COUNT++))
        return 1
    fi
    
    # Start the service with nohup
    nohup python3 "$script_name" > "$LOG_DIR/$service_name.log" 2>&1 &
    local pid=$!
    
    # Save PID
    echo "$pid:$service_name:$port" >> "$PID_FILE"
    
    # Wait a moment and check if still running
    sleep 0.5
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $service_name${NC} ${MAGENTA}(Python)${NC} ${BLUE}→${NC} Port $port ${BLUE}(PID: $pid)${NC}"
        ((STARTED_COUNT++))
        return 0
    else
        echo -e "${RED}✗ $service_name: Failed to start${NC}"
        ((FAILED_COUNT++))
        return 1
    fi
}

# Function to start Node.js/UI service
start_ui_service() {
    local service_dir=$1
    local service_name=$(basename "$service_dir")
    local port=$2
    
    cd "$PROJECT_ROOT/$service_dir"
    
    # Check if already running on this port
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ $service_name: Port $port already in use (skipped)${NC}"
        ((SKIPPED_COUNT++))
        return 1
    fi
    
    # For UI dashboard, check if we can start a simple HTTP server
    if [ -d "static" ]; then
        cd static
        nohup python3 -m http.server $port > "$LOG_DIR/$service_name.log" 2>&1 &
        local pid=$!
        
        # Save PID
        echo "$pid:$service_name:$port" >> "$PID_FILE"
        
        sleep 0.5
        if ps -p $pid > /dev/null 2>&1; then
            echo -e "${GREEN}✓ $service_name${NC} ${CYAN}(UI)${NC} ${BLUE}→${NC} Port $port ${BLUE}(PID: $pid)${NC}"
            ((STARTED_COUNT++))
            return 0
        fi
    fi
    
    echo -e "${YELLOW}⊘ $service_name: Cannot start (skipped)${NC}"
    ((SKIPPED_COUNT++))
    return 1
}

# Main execution
main() {
    cd "$PROJECT_ROOT"
    
    print_header "🚂 Train Ticket - Local Services Startup"
    
    echo -e "${YELLOW}Starting all services locally (not in Docker)${NC}"
    echo -e "${BLUE}Logs will be saved to: $LOG_DIR${NC}\n"
    
    setup_logs
    
    print_header "🔐 Starting Authentication & User Services"
    start_java_service "ts-auth-service" 12340
    start_java_service "ts-user-service" 12342
    start_java_service "ts-verification-code-service" 15678
    start_java_service "ts-contacts-service" 12347
    
    print_header "🎫 Starting Booking Services"
    start_java_service "ts-travel-service" 12346
    start_java_service "ts-travel2-service" 16346
    start_java_service "ts-travel-plan-service" 14322
    start_java_service "ts-preserve-service" 14568
    start_java_service "ts-preserve-other-service" 14569
    start_java_service "ts-order-service" 12031
    start_java_service "ts-order-other-service" 12032
    start_java_service "ts-cancel-service" 18885
    start_java_service "ts-rebook-service" 18886
    
    print_header "💳 Starting Payment Services"
    start_java_service "ts-payment-service" 19001
    start_java_service "ts-inside-payment-service" 18673
    
    print_header "🚆 Starting Train & Route Services"
    start_java_service "ts-train-service" 14567
    start_java_service "ts-route-service" 11178
    start_java_service "ts-route-plan-service" 14578
    start_java_service "ts-station-service" 12345
    start_java_service "ts-seat-service" 18898
    start_java_service "ts-config-service" 15679
    
    print_header "💰 Starting Pricing Services"
    start_java_service "ts-price-service" 16579
    start_java_service "ts-basic-service" 15680
    start_java_service "ts-assurance-service" 18888
    
    print_header "🍔 Starting Food Services"
    start_java_service "ts-food-service" 18856
    start_java_service "ts-station-food-service" 18855
    start_java_service "ts-train-food-service" 19999
    start_java_service "ts-food-delivery-service" 18957
    
    print_header "🔧 Starting Additional Services"
    start_java_service "ts-security-service" 11188
    start_java_service "ts-execute-service" 12386
    start_java_service "ts-notification-service" 17853
    start_java_service "ts-consign-service" 16111
    start_java_service "ts-consign-price-service" 16110
    start_java_service "ts-news-service" 12862
    start_java_service "ts-ticket-office-service" 16108
    start_java_service "ts-delivery-service" 18808
    start_java_service "ts-wait-order-service" 17525
    start_java_service "ts-gateway-service" 18888
    
    print_header "🐍 Starting Python Services"
    start_python_service "ts-voucher-service" 16101 "server.py"
    
    print_header "👨‍💼 Starting Admin Services"
    start_java_service "ts-admin-basic-info-service" 18767
    start_java_service "ts-admin-order-service" 16112
    start_java_service "ts-admin-route-service" 16113
    start_java_service "ts-admin-travel-service" 16114
    start_java_service "ts-admin-user-service" 16115
    
    print_header "🌐 Starting UI Dashboard"
    start_ui_service "ts-ui-dashboard" 8080
    
    print_header "📊 Startup Summary"
    
    local total=$((STARTED_COUNT + FAILED_COUNT + SKIPPED_COUNT))
    echo -e "${GREEN}Successfully Started:${NC} $STARTED_COUNT"
    echo -e "${RED}Failed:${NC} $FAILED_COUNT"
    echo -e "${YELLOW}Skipped:${NC} $SKIPPED_COUNT"
    echo -e "${BLUE}Total:${NC} $total"
    echo ""
    
    if [ $STARTED_COUNT -gt 0 ]; then
        echo -e "${GREEN}✓ Services are starting up!${NC}"
        echo -e "${CYAN}Main UI: ${GREEN}http://localhost:8080${NC}\n"
    else
        echo -e "${RED}✗ No services were started${NC}"
        echo -e "${YELLOW}Make sure services are built first: ./scripts/build.sh all${NC}\n"
    fi
    
    print_header "📝 Important Notes"
    echo -e "${YELLOW}1.${NC} Services are running in the background with nohup"
    echo -e "${YELLOW}2.${NC} Logs are in: ${BLUE}$LOG_DIR/${NC}"
    echo -e "${YELLOW}3.${NC} To stop all services: ${GREEN}./scripts/stop.sh${NC}"
    echo -e "${YELLOW}4.${NC} To check status: ${GREEN}./scripts/status.sh${NC}"
    echo -e "${YELLOW}5.${NC} View a service log: ${GREEN}tail -f logs/[service-name].log${NC}"
    echo -e "${YELLOW}6.${NC} PIDs saved to: ${BLUE}.services.pid${NC}"
    echo -e "${YELLOW}7.${NC} Services may take 10-30 seconds to fully initialize"
    echo ""
    
    if [ $FAILED_COUNT -gt 0 ]; then
        echo -e "${RED}⚠ Some services failed to start. Check logs in $LOG_DIR/${NC}\n"
    fi
    
    print_header "✨ Startup Complete"
}

# Run main function
main "$@"
