#!/bin/bash

# Train Ticket - Initialize Local Databases (No Docker)
# Creates all required databases in local MySQL installation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# MySQL Configuration
MYSQL_ROOT_PASSWORD="root"
MYSQL_HOST="localhost"
MYSQL_PORT=3306

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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
    "voucherservice"
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

# Check if MySQL is running
check_mysql() {
    print_header "🔍 Checking MySQL Service"
    
    if ! sudo service mysql status >/dev/null 2>&1; then
        echo -e "${RED}✗ MySQL service is not running${NC}"
        echo -e "${YELLOW}Starting MySQL...${NC}"
        sudo service mysql start
        sleep 2
    fi
    
    if mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ MySQL is running and accessible${NC}"
        return 0
    else
        echo -e "${RED}✗ Cannot connect to MySQL${NC}"
        echo -e "${YELLOW}Please run: ./scripts/install-mysql-local.sh${NC}"
        return 1
    fi
}

# Create all databases
create_databases() {
    print_header "📊 Creating Databases"
    
    local success_count=0
    local total=${#DATABASES[@]}
    
    for db in "${DATABASES[@]}"; do
        echo -n "Creating database: $db ... "
        
        if mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
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

# Initialize voucher service database with schema
init_voucher_database() {
    print_header "🎫 Initializing Voucher Service Database"
    
    local sql_file="$PROJECT_ROOT/ts-voucher-service/db.sql"
    
    if [ -f "$sql_file" ]; then
        echo -e "${BLUE}Running voucher database initialization...${NC}"
        
        # Create the database if it doesn't exist
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} \
            -e "CREATE DATABASE IF NOT EXISTS voucherservice;" 2>/dev/null
        
        # Run the SQL file
        mysql -uroot -p${MYSQL_ROOT_PASSWORD} voucherservice < "$sql_file" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Voucher database initialized${NC}"
        else
            echo -e "${YELLOW}⚠ Voucher database initialization had issues (may be OK if table already exists)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Voucher SQL file not found at $sql_file${NC}"
    fi
}

# Display database list
list_databases() {
    print_header "📋 Database List"
    
    echo -e "${BLUE}TrainTicket databases:${NC}"
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;" 2>/dev/null | grep -E "^(ts-|voucherservice)" | while read db; do
        echo -e "  ${GREEN}✓${NC} $db"
    done
}

# Create a test user (optional)
create_test_user() {
    print_header "👤 Creating Test Database User (Optional)"
    
    echo -e "${BLUE}Creating 'trainticket' user for services...${NC}"
    
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<EOF 2>/dev/null
CREATE USER IF NOT EXISTS 'trainticket'@'localhost' IDENTIFIED BY 'trainticket123';
GRANT ALL PRIVILEGES ON \`ts-%\`.* TO 'trainticket'@'localhost';
GRANT ALL PRIVILEGES ON \`voucherservice\`.* TO 'trainticket'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Test user created (optional)${NC}"
        echo -e "${BLUE}You can use either root or trainticket user${NC}"
    else
        echo -e "${YELLOW}⚠ Could not create test user (root user will work fine)${NC}"
    fi
}

# Show connection information
show_connection_info() {
    print_header "📝 Database Connection Information"
    
    echo -e "${BLUE}MySQL Server:${NC}"
    echo -e "  Host: ${MYSQL_HOST}"
    echo -e "  Port: ${MYSQL_PORT}"
    echo -e "  Root User: root"
    echo -e "  Root Password: ${MYSQL_ROOT_PASSWORD}"
    echo -e "  Total Databases: ${#DATABASES[@]}"
    echo ""
    
    echo -e "${YELLOW}Connect manually:${NC}"
    echo -e "  ${GREEN}mysql -uroot -p${MYSQL_ROOT_PASSWORD}${NC}"
    echo ""
    
    echo -e "${YELLOW}View databases:${NC}"
    echo -e "  ${GREEN}mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'SHOW DATABASES;'${NC}"
    echo ""
    
    echo -e "${YELLOW}Environment variables for services:${NC}"
    echo -e "  All services will connect to localhost:3306"
    echo -e "  Username: root"
    echo -e "  Password: root"
    echo ""
}

# Main execution
main() {
    print_header "🚂 Train Ticket - Local Database Initialization"
    
    echo -e "${YELLOW}Initializing all databases in local MySQL${NC}"
    echo -e "${BLUE}No Docker required!${NC}\n"
    
    # Check MySQL
    if ! check_mysql; then
        exit 1
    fi
    
    # Create all databases
    create_databases
    
    # Initialize voucher database with schema
    init_voucher_database
    
    # Create test user (optional)
    create_test_user
    
    # List all databases
    list_databases
    
    # Show connection information
    show_connection_info
    
    print_header "✨ Database Initialization Complete"
    
    echo -e "${GREEN}All databases are ready!${NC}\n"
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Start services: ${GREEN}./scripts/start-local.sh${NC}"
    echo -e "  2. Check status: ${GREEN}./scripts/check-databases-local.sh${NC}"
    echo -e "  3. Access UI: ${CYAN}http://localhost:8080${NC}"
    echo ""
}

# Run main function
main "$@"

