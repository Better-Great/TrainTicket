#!/bin/bash

# Train Ticket - Database Initialization Script
# Starts MySQL in Docker and creates all required databases for local development

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# MySQL Configuration
MYSQL_ROOT_PASSWORD="root"
MYSQL_PORT=3306
MYSQL_CONTAINER_NAME="trainticket-mysql"

# List of all databases required by services
DATABASES=(
    "ts-auth-mysql"
    "ts-user-mysql"
    "ts-contacts-mysql"
    "ts-order-mysql"
    "ts-order-other-mysql"
    "ts-config-mysql"
    "ts-station-mysql"
    "ts-train-mysql"
    "ts-travel-mysql"
    "ts-travel2-mysql"
    "ts-route-mysql"
    "ts-price-mysql"
    "ts-security-mysql"
    "ts-inside-payment-mysql"
    "ts-payment-mysql"
    "ts-rebook-mysql"
    "ts-assurance-mysql"
    "ts-food-mysql"
    "ts-food-delivery-mysql"
    "ts-consign-mysql"
    "ts-consign-price-mysql"
    "ts-ticket-office-mysql"
    "ts-news-mysql"
    "ts-voucher-mysql"
    "ts-delivery-mysql"
    "ts-train-food-mysql"
    "ts-station-food-mysql"
    "ts-wait-order-mysql"
)

print_header() {
    echo -e "\n${CYAN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}\n"
}

# Function to check if MySQL container is running
check_mysql_container() {
    if docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER_NAME}$"; then
        return 0
    fi
    return 1
}

# Function to start MySQL container
start_mysql_container() {
    print_header "🐬 Starting MySQL Container"
    
    # Check if container exists but is stopped
    if docker ps -a --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER_NAME}$"; then
        echo -e "${YELLOW}Found existing MySQL container. Starting it...${NC}"
        docker start $MYSQL_CONTAINER_NAME
    else
        echo -e "${BLUE}Creating new MySQL container...${NC}"
        docker run -d \
            --name $MYSQL_CONTAINER_NAME \
            -p $MYSQL_PORT:3306 \
            -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
            mysql:8.0 \
            --default-authentication-plugin=mysql_native_password
    fi
    
    # Wait for MySQL to be ready
    echo -e "${YELLOW}Waiting for MySQL to be ready...${NC}"
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker exec $MYSQL_CONTAINER_NAME mysqladmin ping -uroot -p$MYSQL_ROOT_PASSWORD --silent 2>/dev/null; then
            echo -e "${GREEN}✓ MySQL is ready!${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    echo -e "\n${RED}✗ MySQL failed to start in time${NC}"
    return 1
}

# Function to create all databases
create_databases() {
    print_header "📊 Creating Databases"
    
    local success_count=0
    local total=${#DATABASES[@]}
    
    for db in "${DATABASES[@]}"; do
        echo -n "Creating database: $db ... "
        
        if docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD \
            -e "CREATE DATABASE IF NOT EXISTS \`$db\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
            ((success_count++))
        else
            echo -e "${RED}✗${NC}"
        fi
    done
    
    echo ""
    echo -e "${GREEN}Successfully created: $success_count/$total databases${NC}"
}

# Function to initialize voucher service database
init_voucher_database() {
    print_header "🎫 Initializing Voucher Service Database"
    
    local sql_file="../ts-voucher-service/db.sql"
    
    if [ -f "$sql_file" ]; then
        echo -e "${BLUE}Running voucher database initialization...${NC}"
        
        # First create the database if it doesn't exist
        docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD \
            -e "CREATE DATABASE IF NOT EXISTS voucherservice;" 2>/dev/null
        
        # Run the SQL file
        docker exec -i $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD voucherservice < "$sql_file"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Voucher database initialized${NC}"
        else
            echo -e "${YELLOW}⚠ Voucher database initialization had issues (may be OK if table already exists)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Voucher SQL file not found at $sql_file${NC}"
    fi
}

# Function to display connection information
show_connection_info() {
    print_header "📝 Database Connection Information"
    
    echo -e "${BLUE}MySQL Container Name:${NC} $MYSQL_CONTAINER_NAME"
    echo -e "${BLUE}Host:${NC} localhost"
    echo -e "${BLUE}Port:${NC} $MYSQL_PORT"
    echo -e "${BLUE}Root Password:${NC} $MYSQL_ROOT_PASSWORD"
    echo -e "${BLUE}Total Databases:${NC} ${#DATABASES[@]}"
    echo ""
    echo -e "${YELLOW}To connect manually:${NC}"
    echo -e "  docker exec -it $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD"
    echo ""
    echo -e "${YELLOW}To stop MySQL:${NC}"
    echo -e "  docker stop $MYSQL_CONTAINER_NAME"
    echo ""
    echo -e "${YELLOW}To view MySQL logs:${NC}"
    echo -e "  docker logs $MYSQL_CONTAINER_NAME"
    echo ""
}

# Main execution
main() {
    cd "$(dirname "$0")"
    
    print_header "🚂 Train Ticket - Database Initialization"
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker is not running. Please start Docker first.${NC}"
        exit 1
    fi
    
    # Check if MySQL is already running
    if check_mysql_container; then
        echo -e "${GREEN}✓ MySQL container is already running${NC}"
    else
        # Start MySQL
        if ! start_mysql_container; then
            echo -e "${RED}Failed to start MySQL container${NC}"
            exit 1
        fi
    fi
    
    # Create all databases
    create_databases
    
    # Initialize voucher database with schema
    init_voucher_database
    
    # Show connection information
    show_connection_info
    
    print_header "✨ Database Initialization Complete"
    
    echo -e "${GREEN}All databases are ready!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Run: ${GREEN}./scripts/start-local.sh${NC} (or restart services with: ./scripts/stop.sh && ./scripts/start-local.sh)"
    echo -e "  2. Access UI at: ${CYAN}http://localhost:8080${NC}"
    echo ""
}

# Run main function
main "$@"

