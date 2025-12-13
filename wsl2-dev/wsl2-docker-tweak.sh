#!/bin/bash
#
# ==============================================================================
# WSL2 Docker Tweak Script
#
# Description: Automatically optimizes WSL2 configuration for Docker workloads
# by generating/updating .wslconfig with optimal RAM and CPU settings.
# Backs up existing .wslconfig to .wslconfig.backup for fallback.
#
# Usage: sudo bash ./wsl2-docker-tweak.sh
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status.

# --- Color Definitions ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

# --- Helper Functions ---
log_info() {
    echo -e "${C_BLUE}[INFO]${C_NC} $1"
}

log_success() {
    echo -e "${C_GREEN}[SUCCESS]${C_NC} $1"
}

log_warning() {
    echo -e "${C_YELLOW}[WARNING]${C_NC} $1"
}

log_error() {
    echo -e "${C_RED}[ERROR]${C_NC} $1"
}

# --- Get Windows User Profile Path ---
get_windows_user_profile() {
    # In WSL2, %USERPROFILE% is /mnt/c/Users/Username
    local win_user
    win_user=$(whoami)
    echo "/mnt/c/Users/$win_user"
}

# --- Backup existing .wslconfig ---
backup_wslconfig() {
    local wslconfig_path="$1/.wslconfig"
    local backup_path="$1/.wslconfig.backup"

    if [ -f "$wslconfig_path" ]; then
        log_info "Backing up existing .wslconfig to .wslconfig.backup"
        cp "$wslconfig_path" "$backup_path"
        log_success "Backup created at $backup_path"
    else
        log_info "No existing .wslconfig found, no backup needed"
    fi
}

# --- Detect system specs ---
detect_system_specs() {
    log_info "Detecting system specifications..."

    # RAM in GB
    local total_ram_kb
    total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_RAM_GB=$((total_ram_kb / 1024 / 1024))
    log_info "Total RAM: ${TOTAL_RAM_GB}GB"

    # CPU cores
    CPU_CORES=$(nproc)
    log_info "CPU Cores: $CPU_CORES"

    # Docker info if available
    if command -v docker &> /dev/null && docker info &> /dev/null; then
        DOCKER_MEMORY=$(docker info 2>/dev/null | grep "Total Memory" | awk '{print $3}' | sed 's/GiB//')
        if [ -n "$DOCKER_MEMORY" ]; then
            log_info "Docker Total Memory: ${DOCKER_MEMORY}GB"
        fi
    fi
}

# --- Calculate optimal settings ---
calculate_optimal_settings() {
    log_info "Calculating optimal WSL2 settings..."

    # Memory: 50% of host RAM, max 8GB for Docker workloads
    MEMORY_GB=$((TOTAL_RAM_GB / 2))
    if [ $MEMORY_GB -gt 8 ]; then
        MEMORY_GB=8
    fi
    if [ $MEMORY_GB -lt 2 ]; then
        MEMORY_GB=2  # Minimum 2GB
    fi
    log_info "Optimal Memory: ${MEMORY_GB}GB"

    # Processors: All cores for Docker parallelism
    PROCESSORS=$CPU_CORES
    log_info "Optimal Processors: $PROCESSORS"

    # Auto memory reclaim: gradual for Docker stability
    AUTO_MEMORY_RECLAIM="gradual"
}

# --- Set default settings ---
set_default_settings() {
    log_info "Setting WSL2 to default settings..."

    # For default, we can either remove .wslconfig or set minimal
    # Since backup exists, for default, restore backup if exists, else remove
    # But to keep simple, set to basic defaults
    MEMORY_GB=0  # 0 means use WSL2 default (50% RAM)
    PROCESSORS=0  # 0 means use all available
    AUTO_MEMORY_RECLAIM=""  # Default
}

# --- Generate .wslconfig ---
generate_wslconfig() {
    local wslconfig_path="$1/.wslconfig"
    local mode=$2

    if [ "$mode" = "default" ]; then
        log_info "Restoring default .wslconfig (removing custom settings)"
        if [ -f "$1/.wslconfig.backup" ]; then
            cp "$1/.wslconfig.backup" "$wslconfig_path"
            log_success ".wslconfig restored from backup"
        else
            rm -f "$wslconfig_path"
            log_success ".wslconfig removed (using WSL2 defaults)"
        fi
        return
    fi

    log_info "Generating optimized .wslconfig at $wslconfig_path"

    cat > "$wslconfig_path" << EOF
[wsl2]
# Optimized for Docker workloads
memory=${MEMORY_GB}GB
processors=$PROCESSORS
autoMemoryReclaim=$AUTO_MEMORY_RECLAIM

# Additional optimizations
swap=0  # Disable swap for better performance
localhostForwarding=true  # Enable localhost forwarding
EOF

    log_success ".wslconfig generated with optimal settings"
}

# --- Validate and apply ---
validate_and_apply() {
    local wslconfig_path="$1/.wslconfig"

    log_info "Validating .wslconfig..."
    if [ -f "$wslconfig_path" ] || [ "$MODE" = "default" ]; then
        if [ "$MODE" = "optimize" ]; then
            log_success ".wslconfig created successfully"
            echo ""
            echo "Generated .wslconfig contents:"
            echo "-----------------------------"
            cat "$wslconfig_path"
            echo "-----------------------------"
        else
            log_success ".wslconfig updated to defaults"
        fi
        echo ""
        log_warning "WSL2 will restart to apply changes. Save your work!"
        read -p "Apply changes and restart WSL2? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Restarting WSL2..."
            wsl --shutdown
            log_success "WSL2 restarted. Changes applied."
            if [ "$MODE" = "optimize" ]; then
                log_info "To revert, copy .wslconfig.backup back to .wslconfig and restart WSL2."
            fi
        else
            log_info "Changes not applied. You can manually restart WSL2 later."
        fi
    else
        log_error "Failed to update .wslconfig"
        exit 1
    fi
}

# --- Enable Docker experimental mode ---
enable_docker_experimental() {
    log_info "Enabling Docker experimental mode..."

    # Create or update daemon.json
    sudo mkdir -p /etc/docker
    if [ -f /etc/docker/daemon.json ]; then
        # Backup existing
        sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup
    fi

    # Add experimental: true
    sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "experimental": true
}
EOF

    log_success "Docker experimental mode enabled in daemon.json"
    log_warning "Restarting Docker daemon..."
    sudo systemctl restart docker
    log_success "Docker restarted. Experimental features now available."
}

# --- Show menu ---
show_menu() {
    echo ""
    echo "WSL2 Docker Tweak Options:"
    echo "1) Optimize - Auto-configure optimal RAM/CPU for Docker workloads"
    echo "2) Default - Restore to default WSL2 settings (fallback)"
    echo "3) Enable Docker Experimental - Enable beta Docker features"
    echo ""
    read -p "Select option (1, 2, or 3): " choice
    case $choice in
        1)
            MODE="optimize"
            log_info "Selected: Optimize"
            ;;
        2)
            MODE="default"
            log_info "Selected: Default"
            ;;
        3)
            MODE="experimental"
            log_info "Selected: Enable Docker Experimental"
            ;;
        *)
            log_error "Invalid option. Exiting."
            exit 1
            ;;
    esac
}

# --- Main execution ---
main() {
    log_info "=== WSL2 Docker Tweak Tool ==="

    # Show menu
    show_menu

    if [ "$MODE" = "experimental" ]; then
        # Enable Docker experimental mode
        enable_docker_experimental
        echo ""
        log_success "Docker experimental mode enabled!"
        echo "Check with: docker system info | grep Experimental"
        return
    fi

    # Get Windows user profile
    WIN_PROFILE=$(get_windows_user_profile)
    log_info "Windows User Profile: $WIN_PROFILE"

    # Backup existing config
    backup_wslconfig "$WIN_PROFILE"

    if [ "$MODE" = "optimize" ]; then
        # Detect specs
        detect_system_specs

        # Calculate settings
        calculate_optimal_settings
    else
        # For default, no need to detect/calculate
        :
    fi

    # Generate config
    generate_wslconfig "$WIN_PROFILE" "$MODE"

    # Validate and apply
    validate_and_apply "$WIN_PROFILE"

    echo ""
    if [ "$MODE" = "optimize" ]; then
        log_success "WSL2 optimization complete!"
        echo "Monitor performance with: docker info"
    else
        log_success "WSL2 restored to default settings!"
    fi
}

# --- Run main ---
main "$@"