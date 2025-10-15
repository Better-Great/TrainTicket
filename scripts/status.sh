#!/bin/bash

# Train Ticket Microservices - Status Checker (Local)
# This script checks the status of all locally running services

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
PID_FILE="$PROJECT_ROOT/.services.pid"

# Function to print section header
print_header() {
    echo -e "\n${CYAN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}\n"
}

# Function to check if a port is in use
check_port() {
    local port=$1
    local service_name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        local pid=$(lsof -Pi :$port -sTCP:LISTEN -t 2>/dev/null | head -1)
        echo -e "${GREEN}✓${NC} $service_name ${BLUE}(Port $port)${NC} - ${GREEN}RUNNING${NC} ${BLUE}[PID: $pid]${NC}"
        return 0
    else
        echo -e "${RED}✗${NC} $service_name ${BLUE}(Port $port)${NC} - ${RED}NOT RUNNING${NC}"
        return 1
    fi
}

# Function to show process details
show_process_info() {
    echo -e "${YELLOW}Java Processes:${NC}"
    local java_count=$(ps aux | grep -E "java.*ts-.*-service.*\.jar" | grep -v grep | wc -l)
    if [ $java_count -gt 0 ]; then
        ps aux | grep -E "java.*ts-.*-service.*\.jar" | grep -v grep | awk '{print $2, $11, $12, $13}' | while read line; do
            echo -e "  ${BLUE}PID:${NC} $line"
        done
    else
        echo -e "  ${RED}No Java services running${NC}"
    fi
    
    echo -e "\n${YELLOW}Python Processes:${NC}"
    local python_count=$(ps aux | grep -E "python3.*(server\.py|main\.py)" | grep -v grep | wc -l)
    if [ $python_count -gt 0 ]; then
        ps aux | grep -E "python3.*(server\.py|main\.py)" | grep -v grep | awk '{print $2, $11, $12}' | while read line; do
            echo -e "  ${BLUE}PID:${NC} $line"
        done
    else
        echo -e "  ${RED}No Python services running${NC}"
    fi
    
    echo -e "\n${YELLOW}UI Processes:${NC}"
    local ui_count=$(ps aux | grep "python3 -m http.server" | grep -v grep | wc -l)
    if [ $ui_count -gt 0 ]; then
        ps aux | grep "python3 -m http.server" | grep -v grep | awk '{print $2, $11, $12, $13, $14}' | while read line; do
            echo -e "  ${BLUE}PID:${NC} $line"
        done
    else
        echo -e "  ${RED}No UI services running${NC}"
    fi
}

# Main execution
main() {
    cd "$PROJECT_ROOT"
    
    print_header "📊 Train Ticket Services Status Check (Local)"
    
    # Check if PID file exists
    if [ -f "$PID_FILE" ]; then
        echo -e "${GREEN}PID file found:${NC} $PID_FILE"
        echo -e "${BLUE}Tracked services:${NC}"
        while IFS=':' read -r pid service_name port; do
            if [ -n "$pid" ]; then
                if ps -p $pid > /dev/null 2>&1; then
                    echo -e "  ${GREEN}✓${NC} $service_name (PID: $pid, Port: $port)"
                else
                    echo -e "  ${RED}✗${NC} $service_name (PID: $pid, Port: $port) - ${RED}Not running${NC}"
                fi
            fi
        done < "$PID_FILE"
    else
        echo -e "${YELLOW}No PID file found${NC}"
        echo -e "${BLUE}Services may have been started manually${NC}"
    fi
    
    print_header "🔌 Port Status Check"
    
    local running_count=0
    local total_count=0
    
    echo -e "${MAGENTA}═══ Main Entry Points ═══${NC}"
    check_port 8080 "UI Dashboard" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Authentication & User Services ═══${NC}"
    check_port 12340 "Auth Service" && ((running_count++)); ((total_count++))
    check_port 12342 "User Service" && ((running_count++)); ((total_count++))
    check_port 15678 "Verification Code Service" && ((running_count++)); ((total_count++))
    check_port 12347 "Contacts Service" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Booking Services ═══${NC}"
    check_port 12346 "Travel Service" && ((running_count++)); ((total_count++))
    check_port 16346 "Travel2 Service" && ((running_count++)); ((total_count++))
    check_port 14322 "Travel Plan Service" && ((running_count++)); ((total_count++))
    check_port 14568 "Preserve Service" && ((running_count++)); ((total_count++))
    check_port 14569 "Preserve Other Service" && ((running_count++)); ((total_count++))
    check_port 12031 "Order Service" && ((running_count++)); ((total_count++))
    check_port 12032 "Order Other Service" && ((running_count++)); ((total_count++))
    check_port 18885 "Cancel Service" && ((running_count++)); ((total_count++))
    check_port 18886 "Rebook Service" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Payment Services ═══${NC}"
    check_port 19001 "Payment Service" && ((running_count++)); ((total_count++))
    check_port 18673 "Inside Payment Service" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Train & Route Services ═══${NC}"
    check_port 14567 "Train Service" && ((running_count++)); ((total_count++))
    check_port 11178 "Route Service" && ((running_count++)); ((total_count++))
    check_port 14578 "Route Plan Service" && ((running_count++)); ((total_count++))
    check_port 12345 "Station Service" && ((running_count++)); ((total_count++))
    check_port 18898 "Seat Service" && ((running_count++)); ((total_count++))
    check_port 15679 "Config Service" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Pricing Services ═══${NC}"
    check_port 16579 "Price Service" && ((running_count++)); ((total_count++))
    check_port 15680 "Basic Service" && ((running_count++)); ((total_count++))
    check_port 18888 "Assurance/Gateway Service" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Food Services ═══${NC}"
    check_port 18856 "Food Service" && ((running_count++)); ((total_count++))
    check_port 18855 "Station Food/Food Map Service" && ((running_count++)); ((total_count++))
    check_port 19999 "Train Food Service" && ((running_count++)); ((total_count++))
    check_port 18957 "Food Delivery Service" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Additional Services ═══${NC}"
    check_port 11188 "Security Service" && ((running_count++)); ((total_count++))
    check_port 12386 "Execute Service" && ((running_count++)); ((total_count++))
    check_port 17853 "Notification Service" && ((running_count++)); ((total_count++))
    check_port 16111 "Consign Service" && ((running_count++)); ((total_count++))
    check_port 16110 "Consign Price Service" && ((running_count++)); ((total_count++))
    check_port 12862 "News Service" && ((running_count++)); ((total_count++))
    check_port 16108 "Ticket Office Service" && ((running_count++)); ((total_count++))
    check_port 16101 "Voucher Service (Python)" && ((running_count++)); ((total_count++))
    check_port 17001 "Avatar Service" && ((running_count++)); ((total_count++))
    check_port 18808 "Delivery Service" && ((running_count++)); ((total_count++))
    check_port 17525 "Wait Order Service" && ((running_count++)); ((total_count++))
    echo ""
    
    echo -e "${MAGENTA}═══ Admin Services ═══${NC}"
    check_port 18767 "Admin Basic Info Service" && ((running_count++)); ((total_count++))
    check_port 16112 "Admin Order Service" && ((running_count++)); ((total_count++))
    check_port 16113 "Admin Route Service" && ((running_count++)); ((total_count++))
    check_port 16114 "Admin Travel Service" && ((running_count++)); ((total_count++))
    check_port 16115 "Admin User Service" && ((running_count++)); ((total_count++))
    echo ""
    
    print_header "📈 Summary"
    
    local percentage=$((running_count * 100 / total_count))
    echo -e "Services Running: ${GREEN}$running_count${NC} / ${BLUE}$total_count${NC} (${YELLOW}$percentage%${NC})"
    echo ""
    
    if [ $running_count -eq $total_count ]; then
        echo -e "${GREEN}✓ All services are running!${NC}"
    elif [ $running_count -eq 0 ]; then
        echo -e "${RED}✗ No services are running${NC}"
        echo -e "${YELLOW}Start services with: ./scripts/start.sh${NC}"
    else
        echo -e "${YELLOW}⚠ Some services are not running${NC}"
        echo -e "${YELLOW}Check logs in ./logs/ directory${NC}"
    fi
    
    print_header "🔍 Process Details"
    show_process_info
    
    print_header "🔧 Quick Commands"
    echo -e "Start services:  ${GREEN}./scripts/start.sh${NC}"
    echo -e "Stop services:   ${GREEN}./scripts/stop.sh${NC}"
    echo -e "View a log:      ${GREEN}tail -f logs/[service-name].log${NC}"
    echo -e "View this again: ${GREEN}./scripts/status.sh${NC}"
    echo -e "Kill a process:  ${GREEN}kill -15 <PID>${NC}"
    echo ""
}

# Run main function
main "$@"
