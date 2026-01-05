#!/bin/bash

# ==============================================================================
# Generate application.properties from application.properties.ini
# ==============================================================================
# This script reads a service's application.properties.ini file and replaces
# parameterized values (${VariableName}) with actual values from 
# properties/dev.application.ini, then creates application.properties
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Services to exclude (non-Java services)
EXCLUDED_SERVICES=("ts-avatar-service" "ts-ticket-office-service" "ts-ui-dashboard" "ts-voucher-service")

# Function to print usage
usage() {
    echo "Usage: $0 [-all] [service-directory] [environment]"
    echo ""
    echo "Arguments:"
    echo "  -all               Process all Java service directories"
    echo "  service-directory  Optional. Service directory name (e.g., ts-basic-service)"
    echo "                     If not provided, uses current directory"
    echo "                     Ignored if -all is specified"
    echo "  environment        Optional. Environment name (default: dev)"
    echo ""
    echo "Examples:"
    echo "  $0 ts-basic-service"
    echo "  $0 ts-basic-service dev"
    echo "  $0 -all"
    echo "  $0 -all dev"
    echo "  cd ts-basic-service && $0"
    exit 1
}

# Function to generate properties for a single service
generate_properties_for_service() {
    local service_dir="$1"
    local environment="$2"
    local service_path="$PROJECT_ROOT/$service_dir"
    local ini_file="$service_path/application.properties.ini"
    local properties_file="$PROJECT_ROOT/properties/${environment}.application.ini"
    local output_file="$service_path/application.properties"
    
    # Validate .ini file exists
    if [ ! -f "$ini_file" ]; then
        echo -e "${RED}Error: Template file not found: $ini_file${NC}" >&2
        return 1
    fi
    
    # Validate properties file exists
    if [ ! -f "$properties_file" ]; then
        echo -e "${RED}Error: Properties file not found: $properties_file${NC}" >&2
        return 1
    fi
    
    echo -e "${BLUE}Generating application.properties for: ${GREEN}$service_dir${NC}"
    echo -e "${BLUE}Template: ${YELLOW}$ini_file${NC}"
    echo -e "${BLUE}Properties: ${YELLOW}$properties_file${NC}"
    echo -e "${BLUE}Output: ${GREEN}$output_file${NC}"
    echo ""
    
    # Read properties from environment.application.ini into an associative array
    # read_ini_to_map uses declare -gA to create a global array
    read_ini_to_map "$properties_file" PROPERTIES
    
    # Process the .ini file and create .properties file
    > "$output_file"  # Clear/create output file
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Replace variables in the line
        processed_line=$(replace_variables "$line")
        echo "$processed_line" >> "$output_file"
    done < "$ini_file"
    
    echo -e "${GREEN}✓ Successfully generated: $output_file${NC}"
    echo ""
}

# Parse arguments
ALL_MODE=false
SERVICE_DIR=""
ENVIRONMENT="dev"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -all)
            ALL_MODE=true
            shift
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            usage
            ;;
        *)
            if [ -z "$SERVICE_DIR" ]; then
                SERVICE_DIR="$1"
            elif [ -z "$ENVIRONMENT" ] || [ "$ENVIRONMENT" = "dev" ]; then
                ENVIRONMENT="$1"
            fi
            shift
            ;;
    esac
done

# Function to read .ini file and create a map
# .ini files use key=value format (ignoring comments and empty lines)
read_ini_to_map() {
    local file="$1"
    declare -gA "$2"
    local map_name="$2"
    
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Trim whitespace
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip if key is empty after trimming
        [[ -z "$key" ]] && continue
        
        # Store in associative array
        eval "$map_name[\"$key\"]=\"$value\""
    done < "$file"
}

# Function to replace ${VariableName} with actual values
replace_variables() {
    local content="$1"
    local result="$content"
    
    # Find all ${VariableName} patterns
    while [[ "$result" =~ \$\{([^}]+)\} ]]; do
        local var_name="${BASH_REMATCH[1]}"
        local var_value="${PROPERTIES[$var_name]}"
        
        if [ -z "$var_value" ]; then
            echo -e "${YELLOW}Warning: Variable \${$var_name} not found in properties file${NC}" >&2
            # Keep the original ${VariableName} if not found
            result="${result//\$\{$var_name\}/\$\{$var_name\}}"
            break
        else
            # Replace ${VariableName} with actual value
            result="${result//\$\{$var_name\}/$var_value}"
        fi
    done
    
    echo "$result"
}

# Main execution
if [ "$ALL_MODE" = true ]; then
    # Process all Java services
    echo -e "${BLUE}Processing all Java services...${NC}"
    echo ""
    
    # Find all service directories with application.properties.ini
    SERVICE_COUNT=0
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    
    while IFS= read -r service_dir; do
        # Check if service is in exclusion list
        excluded=false
        for excluded_service in "${EXCLUDED_SERVICES[@]}"; do
            if [ "$service_dir" = "$excluded_service" ]; then
                excluded=true
                break
            fi
        done
        
        if [ "$excluded" = true ]; then
            continue
        fi
        
        SERVICE_COUNT=$((SERVICE_COUNT + 1))
        
        if generate_properties_for_service "$service_dir" "$ENVIRONMENT"; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
        
        # Clear PROPERTIES array for next iteration (read_ini_to_map will recreate it)
        unset PROPERTIES
        
    done < <(find "$PROJECT_ROOT" -maxdepth 1 -type d -name "ts-*-service" -exec test -f {}/application.properties.ini \; -print | sed 's|.*/||' | sort)
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Summary:${NC}"
    echo -e "  Total services processed: ${SERVICE_COUNT}"
    echo -e "  ${GREEN}Success: ${SUCCESS_COUNT}${NC}"
    if [ $FAIL_COUNT -gt 0 ]; then
        echo -e "  ${RED}Failed: ${FAIL_COUNT}${NC}"
    fi
    echo ""
    
    if [ $FAIL_COUNT -gt 0 ]; then
        exit 1
    fi
else
    # Process single service
    if [ -z "$SERVICE_DIR" ]; then
        # Use current directory if no service directory provided
        SERVICE_PATH="$(pwd)"
        SERVICE_DIR="$(basename "$SERVICE_PATH")"
    else
        SERVICE_PATH="$PROJECT_ROOT/$SERVICE_DIR"
    fi
    
    # Validate service directory exists
    if [ ! -d "$SERVICE_PATH" ]; then
        echo -e "${RED}Error: Service directory not found: $SERVICE_PATH${NC}" >&2
        usage
    fi
    
    generate_properties_for_service "$SERVICE_DIR" "$ENVIRONMENT"
fi


