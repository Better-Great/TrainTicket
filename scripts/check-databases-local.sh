#!/bin/bash

# Train Ticket - Check Local Database Status (No Docker)
# Verifies MySQL connectivity and lists all databases

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

MYSQL_ROOT_PASSWORD="root"

print_header() {
    echo -e "\n${CYAN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}\n"
}

# Check MySQL service
check_mysql_service() {
    print_header "🔍 MySQL Service Status"
    
    if sudo service mysql status >/dev/null 2>&1; then
        echo -e "${GREEN}✓ MySQL service is running${NC}"
    else
        echo -e "${RED}✗ MySQL service is not running${NC}"
        echo -e "${YELLOW}Start it with: ${GREEN}sudo service mysql start${NC}"
        return 1
    fi
}

# Check MySQL connectivity
check_mysql_connectivity() {
    if mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ MySQL is responding to queries${NC}"
        
        # Show version
        local version=$(mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT VERSION();" -s -N 2>/dev/null)
        echo -e "${BLUE}MySQL Version:${NC} $version"
        return 0
    else
        echo -e "${RED}✗ Cannot connect to MySQL${NC}"
        echo -e "${YELLOW}Check password or run: ./scripts/install-mysql-local.sh${NC}"
        return 1
    fi
}

# List all databases
list_databases() {
    print_header "📊 TrainTicket Databases"
    
    local db_count=$(mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;" 2>/dev/null | grep -E "^(ts-|voucherservice)" | wc -l)
    
    echo -e "${BLUE}Available databases:${NC}"
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;" 2>/dev/null | grep -E "^(ts-|voucherservice)" | while read db; do
        # Check if database has tables
        local table_count=$(mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "USE \`$db\`; SHOW TABLES;" 2>/dev/null | wc -l)
        if [ $table_count -gt 1 ]; then
            echo -e "  ${GREEN}✓${NC} $db ${BLUE}($(($table_count - 1)) tables)${NC}"
        else
            echo -e "  ${YELLOW}◯${NC} $db ${YELLOW}(empty - will be initialized by services)${NC}"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Total databases:${NC} $db_count"
}

# Check database sizes
check_database_sizes() {
    print_header "💾 Database Sizes"
    
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} <<EOF 2>/dev/null
SELECT 
    table_schema AS 'Database',
    COUNT(table_name) AS 'Tables',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema LIKE 'ts-%' OR table_schema = 'voucherservice'
GROUP BY table_schema
ORDER BY table_schema;
EOF
}

# Check critical databases
check_critical_databases() {
    print_header "🔑 Critical Databases Check"
    
    local critical_dbs=("ts-auth-mysql" "ts-user-mysql" "ts-order-mysql" "voucherservice")
    
    for db in "${critical_dbs[@]}"; do
        if mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "USE \`$db\`;" 2>/dev/null; then
            local table_count=$(mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "USE \`$db\`; SHOW TABLES;" 2>/dev/null | wc -l)
            table_count=$(($table_count - 1))
            
            if [ $table_count -gt 0 ]; then
                echo -e "${GREEN}✓${NC} $db ${GREEN}($table_count tables)${NC}"
            else
                echo -e "${YELLOW}◯${NC} $db ${YELLOW}(exists but empty - tables will be auto-created)${NC}"
            fi
        else
            echo -e "${RED}✗${NC} $db ${RED}(missing)${NC}"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Note:${NC} Empty databases are normal. JPA will auto-create tables when services start."
}

# Check for common issues
check_common_issues() {
    print_header "🔍 Common Issues Check"
    
    # Check if MySQL is listening on 3306
    if sudo netstat -tlnp 2>/dev/null | grep -q ":3306"; then
        echo -e "${GREEN}✓ MySQL is listening on port 3306${NC}"
    else
        echo -e "${RED}✗ MySQL is not listening on port 3306${NC}"
    fi
    
    # Check MySQL error log for recent errors
    echo -e "\n${BLUE}Recent MySQL errors (last 5):${NC}"
    sudo tail -20 /var/log/mysql/error.log 2>/dev/null | grep -i error | tail -5 || echo -e "${GREEN}No recent errors${NC}"
    
    # Check connection limits
    local max_connections=$(mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW VARIABLES LIKE 'max_connections';" -s -N 2>/dev/null | cut -f2)
    echo -e "\n${BLUE}Max connections:${NC} $max_connections"
    
    if [ "$max_connections" -lt 200 ]; then
        echo -e "${YELLOW}⚠ Consider increasing max_connections (current: $max_connections)${NC}"
    fi
}

# Show connection info
show_connection_info() {
    print_header "🔌 Connection Information"
    
    echo -e "${BLUE}For manual connection:${NC}"
    echo -e "  ${GREEN}mysql -uroot -p${MYSQL_ROOT_PASSWORD}${NC}"
    echo ""
    
    echo -e "${BLUE}For services (environment variables):${NC}"
    echo -e "  Host: localhost"
    echo -e "  Port: 3306"
    echo -e "  User: root"
    echo -e "  Password: root"
    echo ""
    
    echo -e "${BLUE}Example query:${NC}"
    echo -e "  ${GREEN}mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'SHOW DATABASES;'${NC}"
}

# Main execution
main() {
    print_header "🚂 Train Ticket - Database Status Check"
    
    if ! check_mysql_service; then
        exit 1
    fi
    
    if ! check_mysql_connectivity; then
        exit 1
    fi
    
    list_databases
    check_critical_databases
    check_database_sizes
    check_common_issues
    show_connection_info
    
    print_header "✨ Database Check Complete"
    
    echo -e "${GREEN}Databases are ready!${NC}\n"
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Start services: ${GREEN}./scripts/start-local.sh${NC}"
    echo -e "  2. View service logs: ${GREEN}tail -f logs/ts-auth-service.log${NC}"
    echo -e "  3. Access UI: ${CYAN}http://localhost:8080${NC}"
    echo ""
}

# Run main function
main "$@"

