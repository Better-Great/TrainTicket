#!/bin/bash

# Train Ticket - Database Status Check Script
# Verifies MySQL connectivity and lists all databases

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

MYSQL_CONTAINER_NAME="trainticket-mysql"
MYSQL_ROOT_PASSWORD="root"

print_header() {
    echo -e "\n${CYAN}=========================================="
    echo -e "$1"
    echo -e "==========================================${NC}\n"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}✗ Docker is not running${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ Docker is running${NC}"
    return 0
}

# Check if MySQL container exists and is running
check_mysql_container() {
    if docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER_NAME}$"; then
        echo -e "${GREEN}✓ MySQL container is running${NC}"
        return 0
    elif docker ps -a --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER_NAME}$"; then
        echo -e "${YELLOW}⚠ MySQL container exists but is stopped${NC}"
        echo -e "${BLUE}Start it with: ${GREEN}docker start $MYSQL_CONTAINER_NAME${NC}"
        return 1
    else
        echo -e "${RED}✗ MySQL container not found${NC}"
        echo -e "${BLUE}Create it with: ${GREEN}./scripts/init-databases.sh${NC}"
        return 1
    fi
}

# Check MySQL connectivity
check_mysql_connectivity() {
    if docker exec $MYSQL_CONTAINER_NAME mysqladmin ping -uroot -p$MYSQL_ROOT_PASSWORD --silent 2>/dev/null; then
        echo -e "${GREEN}✓ MySQL is responding to queries${NC}"
        return 0
    else
        echo -e "${RED}✗ MySQL is not responding${NC}"
        return 1
    fi
}

# List all databases
list_databases() {
    print_header "📊 Available Databases"
    
    local databases=$(docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "SHOW DATABASES;" 2>/dev/null | grep "^ts-" | wc -l)
    
    echo -e "${BLUE}TrainTicket databases:${NC}"
    docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "SHOW DATABASES;" 2>/dev/null | grep -E "^(ts-|voucherservice)" | while read db; do
        echo -e "  ${GREEN}✓${NC} $db"
    done
    
    echo ""
    echo -e "${BLUE}Total TrainTicket databases:${NC} $databases"
}

# Check database sizes
check_database_sizes() {
    print_header "💾 Database Sizes"
    
    docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
        SELECT 
            table_schema AS 'Database',
            ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
        FROM information_schema.tables 
        WHERE table_schema LIKE 'ts-%' OR table_schema = 'voucherservice'
        GROUP BY table_schema
        ORDER BY table_schema;
    " 2>/dev/null
}

# Show connection info
show_connection_info() {
    print_header "🔌 Connection Information"
    
    echo -e "${BLUE}Host:${NC} localhost"
    echo -e "${BLUE}Port:${NC} 3306"
    echo -e "${BLUE}Username:${NC} root"
    echo -e "${BLUE}Password:${NC} $MYSQL_ROOT_PASSWORD"
    echo ""
    echo -e "${YELLOW}Connect manually:${NC}"
    echo -e "  docker exec -it $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD"
    echo ""
    echo -e "${YELLOW}Connect from services:${NC}"
    echo -e "  Use localhost:3306 with user 'root' and password 'root'"
}

# Check for common issues
check_common_issues() {
    print_header "🔍 Checking Common Issues"
    
    # Check if port 3306 is exposed
    if docker port $MYSQL_CONTAINER_NAME 3306 >/dev/null 2>&1; then
        local port=$(docker port $MYSQL_CONTAINER_NAME 3306 2>/dev/null | cut -d':' -f2)
        echo -e "${GREEN}✓ MySQL port is exposed on localhost:$port${NC}"
    else
        echo -e "${RED}✗ MySQL port 3306 is not exposed${NC}"
        echo -e "${YELLOW}Recreate container with: ./scripts/init-databases.sh${NC}"
    fi
    
    # Check if there are tables in auth database
    local auth_tables=$(docker exec $MYSQL_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "USE \`ts-auth-mysql\`; SHOW TABLES;" 2>/dev/null | wc -l)
    
    if [ $auth_tables -gt 1 ]; then
        echo -e "${GREEN}✓ Auth database has tables (schema initialized)${NC}"
    else
        echo -e "${YELLOW}⚠ Auth database has no tables yet${NC}"
        echo -e "${BLUE}This is normal - tables will be created when services start (JPA auto-create)${NC}"
    fi
    
    # Check MySQL logs for errors
    echo -e "\n${BLUE}Recent MySQL errors (if any):${NC}"
    docker logs $MYSQL_CONTAINER_NAME --tail 20 2>&1 | grep -i error || echo -e "${GREEN}No recent errors${NC}"
}

# Main execution
main() {
    print_header "🚂 Train Ticket - Database Status Check"
    
    if ! check_docker; then
        exit 1
    fi
    
    if ! check_mysql_container; then
        exit 1
    fi
    
    if ! check_mysql_connectivity; then
        exit 1
    fi
    
    list_databases
    check_database_sizes
    check_common_issues
    show_connection_info
    
    print_header "✨ Database Check Complete"
    
    echo -e "${GREEN}Databases are ready for use!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Start services: ${GREEN}./scripts/start-local.sh${NC}"
    echo -e "  2. Check service logs: ${GREEN}tail -f logs/ts-auth-service.log${NC}"
    echo -e "  3. Access UI: ${CYAN}http://localhost:8080${NC}"
    echo ""
}

# Run main function
main "$@"

