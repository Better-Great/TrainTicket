#!/bin/bash

# Train Ticket - Install MySQL Locally (No Docker)
# Installs and configures MySQL server directly on the system

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

# Check if running on WSL/Linux
check_system() {
    if [[ ! -f /etc/os-release ]]; then
        echo -e "${RED}✗ Cannot detect Linux distribution${NC}"
        exit 1
    fi
    
    . /etc/os-release
    echo -e "${BLUE}Detected OS:${NC} $NAME $VERSION"
}

# Install MySQL
install_mysql() {
    print_header "📦 Installing MySQL Server"
    
    # Check if MySQL is already installed
    if command -v mysql >/dev/null 2>&1; then
        echo -e "${YELLOW}MySQL is already installed${NC}"
        mysql --version
        return 0
    fi
    
    echo -e "${BLUE}Installing MySQL server...${NC}"
    
    # Update package list
    sudo apt-get update
    
    # Install MySQL server
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ MySQL server installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install MySQL server${NC}"
        exit 1
    fi
}

# Start MySQL service
start_mysql() {
    print_header "🚀 Starting MySQL Service"
    
    # Start MySQL service
    sudo service mysql start
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ MySQL service started${NC}"
    else
        echo -e "${RED}✗ Failed to start MySQL service${NC}"
        exit 1
    fi
    
    # Wait for MySQL to be ready
    echo -e "${YELLOW}Waiting for MySQL to be ready...${NC}"
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if sudo mysqladmin ping --silent 2>/dev/null; then
            echo -e "${GREEN}✓ MySQL is ready!${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        echo -n "."
        sleep 1
    done
    
    echo -e "\n${RED}✗ MySQL failed to start in time${NC}"
    return 1
}

# Configure MySQL root password
configure_mysql() {
    print_header "⚙️  Configuring MySQL"
    
    echo -e "${BLUE}Setting root password and configuring access...${NC}"
    
    # Set root password and configure
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';" 2>/dev/null
    sudo mysql -e "FLUSH PRIVILEGES;" 2>/dev/null
    
    # Test connection
    if mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ MySQL root password configured${NC}"
    else
        echo -e "${YELLOW}⚠ Root password may already be set or needs manual configuration${NC}"
    fi
    
    # Enable MySQL to start on boot
    echo -e "${BLUE}Enabling MySQL to start on system boot...${NC}"
    sudo systemctl enable mysql 2>/dev/null || true
    
    echo -e "${GREEN}✓ MySQL configured${NC}"
}

# Display MySQL status
show_mysql_status() {
    print_header "📊 MySQL Status"
    
    echo -e "${BLUE}Service Status:${NC}"
    sudo service mysql status | head -5
    
    echo -e "\n${BLUE}MySQL Version:${NC}"
    mysql --version
    
    echo -e "\n${BLUE}Connection Test:${NC}"
    if mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SELECT VERSION();" 2>/dev/null; then
        echo -e "${GREEN}✓ Can connect to MySQL${NC}"
    else
        echo -e "${RED}✗ Cannot connect to MySQL${NC}"
    fi
}

# Show next steps
show_next_steps() {
    print_header "📝 Next Steps"
    
    echo -e "${GREEN}MySQL is installed and running!${NC}\n"
    
    echo -e "${YELLOW}1.${NC} Initialize databases:"
    echo -e "   ${GREEN}./scripts/init-databases-local.sh${NC}\n"
    
    echo -e "${YELLOW}2.${NC} Start services:"
    echo -e "   ${GREEN}./scripts/start-local.sh${NC}\n"
    
    echo -e "${YELLOW}3.${NC} Check database status:"
    echo -e "   ${GREEN}./scripts/check-databases-local.sh${NC}\n"
    
    echo -e "${BLUE}Connection Information:${NC}"
    echo -e "  Host: localhost"
    echo -e "  Port: 3306"
    echo -e "  User: root"
    echo -e "  Password: ${MYSQL_ROOT_PASSWORD}\n"
    
    echo -e "${BLUE}Manual MySQL Access:${NC}"
    echo -e "  ${GREEN}mysql -uroot -p${MYSQL_ROOT_PASSWORD}${NC}\n"
    
    echo -e "${BLUE}Start/Stop MySQL:${NC}"
    echo -e "  Start:  ${GREEN}sudo service mysql start${NC}"
    echo -e "  Stop:   ${GREEN}sudo service mysql stop${NC}"
    echo -e "  Status: ${GREEN}sudo service mysql status${NC}\n"
}

# Main execution
main() {
    print_header "🚂 Train Ticket - Local MySQL Installation"
    
    echo -e "${YELLOW}This script will install MySQL server directly on your system${NC}"
    echo -e "${YELLOW}No Docker required!${NC}\n"
    
    check_system
    install_mysql
    start_mysql
    configure_mysql
    show_mysql_status
    show_next_steps
    
    print_header "✨ MySQL Installation Complete"
}

# Run main function
main "$@"

