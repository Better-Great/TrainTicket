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

# Function to print usage
usage() {
    echo "Usage: $0 [service-directory] [environment]"
    echo ""
    echo "Arguments:"
    echo "  service-directory  Optional. Service directory name (e.g., ts-basic-service)"
    echo "                     If not provided, uses current directory"
    echo "  environment        Optional. Environment name (default: dev)"
    echo ""
    echo "Examples:"
    echo "  $0 ts-basic-service"
    echo "  $0 ts-basic-service dev"
    echo "  cd ts-basic-service && $0"
    exit 1
}

# Parse arguments
SERVICE_DIR="${1:-}"
ENVIRONMENT="${2:-dev}"

# If service directory is provided, use it; otherwise use current directory
if [ -n "$SERVICE_DIR" ]; then
    SERVICE_PATH="$PROJECT_ROOT/$SERVICE_DIR"
else
    SERVICE_PATH="$(pwd)"
    SERVICE_DIR="$(basename "$SERVICE_PATH")"
fi

# Validate service directory exists
if [ ! -d "$SERVICE_PATH" ]; then
    echo -e "${RED}Error: Service directory not found: $SERVICE_PATH${NC}" >&2
    usage
fi

# Path to the .ini template file
INI_FILE="$SERVICE_PATH/application.properties.ini"

# Validate .ini file exists
if [ ! -f "$INI_FILE" ]; then
    echo -e "${RED}Error: Template file not found: $INI_FILE${NC}" >&2
    exit 1
fi

# Path to the properties file with actual values
PROPERTIES_FILE="$PROJECT_ROOT/properties/${ENVIRONMENT}.application.ini"

# Validate properties file exists
if [ ! -f "$PROPERTIES_FILE" ]; then
    echo -e "${RED}Error: Properties file not found: $PROPERTIES_FILE${NC}" >&2
    exit 1
fi

# Output file
OUTPUT_FILE="$SERVICE_PATH/application.properties"

echo -e "${BLUE}Generating application.properties for: ${GREEN}$SERVICE_DIR${NC}"
echo -e "${BLUE}Template: ${YELLOW}$INI_FILE${NC}"
echo -e "${BLUE}Properties: ${YELLOW}$PROPERTIES_FILE${NC}"
echo -e "${BLUE}Output: ${GREEN}$OUTPUT_FILE${NC}"
echo ""

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

# Read properties from dev.application.ini into an associative array
declare -A PROPERTIES
read_ini_to_map "$PROPERTIES_FILE" PROPERTIES

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

# Process the .ini file and create .properties file
> "$OUTPUT_FILE"  # Clear/create output file

while IFS= read -r line || [ -n "$line" ]; do
    # Replace variables in the line
    processed_line=$(replace_variables "$line")
    echo "$processed_line" >> "$OUTPUT_FILE"
done < "$INI_FILE"

echo -e "${GREEN}✓ Successfully generated: $OUTPUT_FILE${NC}"
echo ""

# Show a preview of the generated file (first 10 lines)
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${BLUE}Preview (first 10 lines):${NC}"
    head -n 10 "$OUTPUT_FILE" | sed 's/^/  /'
    echo ""
fi


