#!/bin/bash

# ==============================================================================
# WSL2 Speedtest Script
#
# Description: Installs and runs speedtest-cli for internet speed testing in WSL2
# Provides network performance diagnostics for development environments
#
# Usage: ./speedtest-wsl2.sh
# ==============================================================================

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

# --- Check if speedtest-cli is installed ---
check_speedtest() {
    if command -v speedtest-cli >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# --- Install speedtest-cli ---
install_speedtest() {
    log_info "Installing speedtest-cli..."

    # Try snap installation first (official speedtest CLI)
    if command -v snap >/dev/null 2>&1; then
        log_info "Trying snap installation (official speedtest CLI)..."
        # Check if we can run sudo without password
        if sudo -n true 2>/dev/null; then
            if sudo snap install speedtest; then
                log_success "Installed speedtest via snap"
                # Create symlink for speedtest2
                mkdir -p "$HOME/bin"
                if [ ! -L "$HOME/bin/speedtest2" ]; then
                    sudo ln -sf "/snap/bin/speedtest" "$HOME/bin/speedtest2"
                    # Add ~/bin to PATH if not already there
                    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
                        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
                    fi
                    log_success "Created 'speedtest2' command in ~/bin"
                    log_info "You can now use 'speedtest2' command directly after restarting your shell"
                fi
                return 0
            else
                log_warning "Snap installation failed, falling back to pip installation"
            fi
        else
            log_info "Snap available but requires password, using pip installation instead"
        fi
    else
        log_info "Snap not available, using pip installation"
    fi

    # Fallback: Install via pip
    log_info "Installing via pip (speedtest-cli)..."

    # Install Python pip if not available
    if ! command -v pip3 >/dev/null 2>&1; then
        log_info "Installing pip3 first..."
        sudo apt update && sudo apt install -y python3-pip
    fi

    # Install speedtest-cli
    pip3 install --user speedtest-cli

    # Add to PATH if needed
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    # Create speedtest2 symlink in ~/bin for easy access
    mkdir -p "$HOME/bin"
    if [ ! -L "$HOME/bin/speedtest2" ]; then
        ln -sf "$HOME/.local/bin/speedtest-cli" "$HOME/bin/speedtest2"
        # Add ~/bin to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
            echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        fi
        log_success "Created 'speedtest2' command in ~/bin"
        log_info "You can now use 'speedtest2' command directly after restarting your shell"
    else
        log_info "'speedtest2' command already exists in ~/bin"
    fi

    log_success "speedtest-cli installed successfully"
}

# --- Loading bar function ---
show_loading() {
    local duration=$1
    local message=$2
    local progress=0
    local bar_width=50

    echo -n "$message "
    echo -n "["
    while [ $progress -lt $bar_width ]; do
        echo -n "="
        progress=$((progress + 1))
        sleep $(echo "scale=2; $duration/$bar_width" | bc 2>/dev/null || echo "0.1")
    done
    echo "] Done!"
}

# --- Run speedtest ---
run_speedtest() {
    log_info "Running internet speed test..."
    echo "This may take 30-60 seconds depending on your connection..."
    echo ""

    # Ensure speedtest-cli is in PATH
    export PATH="$HOME/.local/bin:$PATH"

    # Start speedtest in background and show loading bar
    speedtest-cli &
    local speedtest_pid=$!

    # Show loading bar for estimated duration (45 seconds typical)
    show_loading 45 "Testing connection"

    # Wait for speedtest to complete
    wait $speedtest_pid

    echo ""
    log_success "Speed test completed"
    echo ""
    log_info "Tip: You can now use 'speedtest2' command directly (after sourcing ~/.bashrc or restarting shell)"
}

# --- Main execution ---
main() {
    log_info "=== WSL2 Speedtest Tool ==="

    # Check if speedtest-cli is available
    if check_speedtest; then
        log_success "speedtest-cli is already installed"
    else
        log_warning "speedtest-cli not found. Installing..."
        install_speedtest

        # Verify installation
        if ! check_speedtest; then
            log_error "Failed to install speedtest-cli. Please check your internet connection and try again."
            exit 1
        fi
    fi

    echo ""
    run_speedtest
}

# --- Run main function ---
main "$@"