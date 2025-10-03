#!/bin/bash

# Maven Cleanup Script for WSL
# This script helps free up disk space by cleaning Maven artifacts

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get directory size
get_size() {
    du -sh "$1" 2>/dev/null | cut -f1 || echo "0B"
}

# Function to show disk space
show_disk_space() {
    echo ""
    print_info "Current disk space usage:"
    df -h ~ | awk 'NR==1 || /\/$/'
    echo ""
}

# Main menu
show_menu() {
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "         Maven Cleanup Script for WSL"
    echo "════════════════════════════════════════════════════"
    echo ""
    echo "1) Clean all target directories in current project"
    echo "2) Clean Maven local repository (~/.m2/repository)"
    echo "3) Clean Maven cache and temp files"
    echo "4) Clean specific artifact from local repository"
    echo "5) Clean all unused dependencies (last-updated > 3 days)"
    echo "6) Nuclear option (Clean everything - target + .m2)"
    echo "7) Show disk space usage"
    echo "8) Exit"
    echo ""
    echo -n "Select an option [1-8]: "
}

# Function 1: Clean all target directories
clean_targets() {
    print_info "Searching for target directories..."
    
    local target_dirs=$(find . -type d -name "target" 2>/dev/null)
    
    if [ -z "$target_dirs" ]; then
        print_warning "No target directories found."
        return
    fi
    
    local total_size=0
    echo "$target_dirs" | while read dir; do
        local size=$(get_size "$dir")
        echo "  Found: $dir ($size)"
    done
    
    echo ""
    read -p "Delete all target directories? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "$target_dirs" | while read dir; do
            rm -rf "$dir"
            print_success "Deleted: $dir"
        done
        print_success "All target directories cleaned!"
    else
        print_info "Operation cancelled."
    fi
}

# Function 2: Clean Maven local repository
clean_m2_repository() {
    local m2_repo="$HOME/.m2/repository"
    
    if [ ! -d "$m2_repo" ]; then
        print_warning "Maven repository not found at $m2_repo"
        return
    fi
    
    local size=$(get_size "$m2_repo")
    print_warning "This will delete your entire Maven local repository!"
    print_info "Current size: $size"
    print_info "Location: $m2_repo"
    echo ""
    read -p "Are you ABSOLUTELY sure? (type 'YES' to confirm): " confirm
    
    if [ "$confirm" = "YES" ]; then
        rm -rf "$m2_repo"
        mkdir -p "$m2_repo"
        print_success "Maven repository cleaned! ($size freed)"
        print_info "Dependencies will be re-downloaded on next build."
    else
        print_info "Operation cancelled."
    fi
}

# Function 3: Clean Maven cache and temp files
clean_cache() {
    print_info "Cleaning Maven cache and temporary files..."
    
    local cleaned=0
    
    # Clean resolver status files
    if [ -d "$HOME/.m2/repository" ]; then
        find "$HOME/.m2/repository" -name "*.lastUpdated" -type f -delete 2>/dev/null && cleaned=1
        find "$HOME/.m2/repository" -name "_remote.repositories" -type f -delete 2>/dev/null && cleaned=1
        find "$HOME/.m2/repository" -name "resolver-status.properties" -type f -delete 2>/dev/null && cleaned=1
    fi
    
    # Clean Maven wrapper files
    find . -type d -name ".mvn" -exec rm -rf {} + 2>/dev/null && cleaned=1
    
    if [ $cleaned -eq 1 ]; then
        print_success "Cache and temporary files cleaned!"
    else
        print_info "No cache files found to clean."
    fi
}

# Function 4: Clean specific artifact
clean_specific_artifact() {
    local m2_repo="$HOME/.m2/repository"
    
    if [ ! -d "$m2_repo" ]; then
        print_warning "Maven repository not found."
        return
    fi
    
    echo ""
    print_info "Enter artifact details (e.g., org/springframework/spring-core):"
    read -p "Artifact path: " artifact_path
    
    local full_path="$m2_repo/$artifact_path"
    
    if [ ! -d "$full_path" ]; then
        print_error "Artifact not found at: $full_path"
        return
    fi
    
    local size=$(get_size "$full_path")
    print_info "Found: $full_path ($size)"
    echo ""
    read -p "Delete this artifact? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf "$full_path"
        print_success "Artifact deleted! ($size freed)"
    else
        print_info "Operation cancelled."
    fi
}

# Function 5: Clean old dependencies
clean_old_dependencies() {
    local m2_repo="$HOME/.m2/repository"
    
    if [ ! -d "$m2_repo" ]; then
        print_warning "Maven repository not found."
        return
    fi
    
    print_info "Finding dependencies not used in the last 3 days..."
    
    local old_dirs=$(find "$m2_repo" -type d -atime +3 2>/dev/null | grep -v "^$m2_repo$")
    
    if [ -z "$old_dirs" ]; then
        print_info "No old dependencies found."
        return
    fi
    
    local count=$(echo "$old_dirs" | wc -l)
    print_info "Found $count directories not accessed in 3+ days"
    echo ""
    read -p "Delete old dependencies? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "$old_dirs" | xargs rm -rf
        print_success "Old dependencies cleaned!"
    else
        print_info "Operation cancelled."
    fi
}

# Function 6: Nuclear option
nuclear_clean() {
    print_warning "╔════════════════════════════════════════════════╗"
    print_warning "║          ⚠️  NUCLEAR CLEANUP OPTION  ⚠️          ║"
    print_warning "╚════════════════════════════════════════════════╝"
    echo ""
    print_warning "This will delete:"
    print_warning "  • All target directories in current project"
    print_warning "  • Entire Maven local repository (~/.m2/repository)"
    print_warning "  • All Maven cache files"
    echo ""
    
    local m2_size=$(get_size "$HOME/.m2/repository" 2>/dev/null || echo "0B")
    print_info "Maven repository size: $m2_size"
    echo ""
    
    read -p "Type 'NUKE' to proceed (case-insensitive): " confirm
    
    # Convert to uppercase for case-insensitive comparison
    confirm_upper=$(echo "$confirm" | tr '[:lower:]' '[:upper:]')
    
    if [ "$confirm_upper" = "NUKE" ]; then
        print_info "Initiating nuclear cleanup..."
        
        # Clean targets
        find . -type d -name "target" -exec rm -rf {} + 2>/dev/null
        print_success "✓ Target directories cleaned"
        
        # Clean .m2
        rm -rf "$HOME/.m2/repository"
        mkdir -p "$HOME/.m2/repository"
        print_success "✓ Maven repository cleaned"
        
        # Clean cache
        find "$HOME/.m2" -name "*.lastUpdated" -type f -delete 2>/dev/null
        print_success "✓ Cache files cleaned"
        
        print_success "Nuclear cleanup complete! 🚀"
    else
        print_info "Operation cancelled. (Phew! 😅)"
    fi
}

# Function 7: Show disk usage
show_disk_usage() {
    show_disk_space
    
    echo "Maven-related disk usage:"
    echo "─────────────────────────────────────────────────"
    
    if [ -d "$HOME/.m2/repository" ]; then
        local m2_size=$(get_size "$HOME/.m2/repository")
        echo "Maven repository (~/.m2/repository): $m2_size"
    else
        echo "Maven repository: Not found"
    fi
    
    if [ -d "target" ] || [ -n "$(find . -type d -name 'target' 2>/dev/null)" ]; then
        local targets_size=$(find . -type d -name "target" -exec du -sh {} + 2>/dev/null | awk '{sum+=$1} END {print sum "M"}')
        echo "Target directories (current project): $targets_size"
    else
        echo "Target directories: None found"
    fi
    
    echo ""
}

# Main script execution
main() {
    # Check if Maven is installed
    if ! command -v mvn &> /dev/null; then
        print_warning "Maven (mvn) not found in PATH. Some features may not work."
        echo ""
    fi
    
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) clean_targets ;;
            2) clean_m2_repository ;;
            3) clean_cache ;;
            4) clean_specific_artifact ;;
            5) clean_old_dependencies ;;
            6) nuclear_clean ;;
            7) show_disk_usage ;;
            8) 
                print_info "Exiting. Stay clean! 🧹"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-8."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main