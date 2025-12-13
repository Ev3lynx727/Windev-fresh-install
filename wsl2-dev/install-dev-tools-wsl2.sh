#!/bin/bash

# ==============================================================================
# WSL2 Development Tools Installation Script
#
# Description: Installs essential development tools and utilities in WSL2 Ubuntu
# This script follows a logical progression from system updates to development tools
#
# Usage: ./install-dev-tools-wsl2.sh
# ==============================================================================

set -e  # Exit on any error

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

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${C_GREEN}✓${C_NC} $1"
        return 0
    else
        echo -e "${C_RED}✗${C_NC} $1"
        return 1
    fi
}

# --- STEP 1: Initial System Preparation ---
log_info "=== STEP 1: System Preparation ==="

# Check if running on WSL2
if [ ! -f /proc/version ] || ! grep -q "microsoft" /proc/version; then
    log_error "This script is designed for WSL2. Please run it in a WSL2 environment."
    exit 1
fi

log_info "Running on WSL2 ✓"

# Check internet connectivity
if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    log_error "No internet connection detected. Please check your network settings."
    exit 1
fi

log_info "Internet connectivity confirmed ✓"

# --- STEP 2: System Update ---
log_info "=== STEP 2: System Update ==="
log_info "Updating package database and upgrading system packages..."

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

log_success "System update completed"

# --- STEP 3: Essential System Packages ---
log_info "=== STEP 3: Essential System Packages ==="
log_info "Installing networking tools, SSL support, and system utilities..."

ESSENTIAL_PACKAGES=(
    # Networking tools
    netcat-openbsd
    net-tools
    iputils-ping
    openssh-server
    openssh-client
    curl
    wget
    # DNS & Network Analysis
    dnsutils
    traceroute
    whois
    # Network Monitoring
    iftop
    nload
    bmon
    # Advanced HTTP Tools
    httpie
    siege
    # apache2-utils  # Commented out - ab (apache benchmark) - can add manually if needed
    # Network Utilities
    telnet
    ftp
    socat
    # SSL support
    openssl
    # Process monitoring
    procps
    # System utilities
    ca-certificates
    # Additional essentials
    software-properties-common
    apt-transport-https
    lsb-release
    gnupg
    unzip
    zip
    jq
    tree
    htop
    ncdu
)

sudo apt install -y "${ESSENTIAL_PACKAGES[@]}"

log_success "Essential system packages installed"

# --- STEP 4: Development Tools ---
log_info "=== STEP 4: Development Tools ==="
log_info "Installing programming languages, version control, and build tools..."

DEV_PACKAGES=(
    # Version control
    git
    # Build tools
    build-essential
    cmake
    make
    # Programming languages
    python3
    python3-pip
    python3-venv
    nodejs
    npm
    # JavaScript/TypeScript tools
    yarn
    # Database clients (commented out - using DBeaver on Windows, will add DB servers later)
    # postgresql-client
    # mysql-client
    # sqlite3
    # Development utilities
    vim
    nano
    tmux
    # Shell improvements
    zsh
    # Documentation
    man-db
    tldr
)

sudo apt install -y "${DEV_PACKAGES[@]}"

log_success "Development tools installed"

# --- STEP 5: Python Package Management ---
log_info "=== STEP 5: Python Package Management ==="
log_info "Setting up Python development environment..."

# Install pip for Python 3 if not already available
if ! command -v pip3 >/dev/null 2>&1; then
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3
fi

# Install common Python packages
pip3 install --user --upgrade pip setuptools wheel
pip3 install --user virtualenv pipenv

log_success "Python environment configured"

# --- STEP 6: Node.js Package Management ---
log_info "=== STEP 6: Node.js Package Management ==="
log_info "Setting up Node.js development environment..."

# Install nvm (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Load nvm and install latest LTS Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

log_success "Node.js environment configured"

# --- STEP 7: Git Configuration ---
log_info "=== STEP 7: Git Configuration ==="
log_info "Setting up Git with basic configuration..."

# Set default Git configuration if not already set
if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "WSL2 User"
    log_warning "Git user name set to default. Please update with: git config --global user.name 'Your Name'"
fi

if [ -z "$(git config --global user.email)" ]; then
    git config --global user.email "user@wsl2.local"
    log_warning "Git user email set to default. Please update with: git config --global user.email 'your.email@example.com'"
fi

git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global core.filemode false

log_success "Git configured"

# --- STEP 8: Environment Setup ---
log_info "=== STEP 8: Environment Setup ==="
log_info "Configuring shell environment and PATH..."

# Add local bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Add nvm to bashrc if not already there
if ! grep -q "NVM_DIR" ~/.bashrc; then
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
fi

# Source the updated bashrc
source ~/.bashrc

log_success "Environment configured"

# --- STEP 9: Verification ---
log_info "=== STEP 9: Installation Verification ==="
log_info "Verifying installed tools..."

echo "Checking essential tools:"
check_command git
check_command python3
check_command pip3
check_command node
check_command npm
check_command curl
check_command wget
check_command openssl
check_command ssh
check_command docker

echo ""
log_info "Checking versions:"
echo "Git: $(git --version)"
echo "Python: $(python3 --version)"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not running')"

# --- STEP 10: Final Cleanup ---
log_info "=== STEP 10: Final Cleanup ==="
log_info "Cleaning up installation artifacts..."

sudo apt autoremove -y
sudo apt autoclean

log_success "Cleanup completed"

# --- Completion Message ---
echo ""
log_success "🎉 WSL2 Development Environment Setup Complete! 🎉"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run 'source ~/.bashrc' to load the new environment"
echo "2. Configure Git with your actual name and email:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"
echo "3. Consider installing additional tools like:"
echo "   - Docker (if not already installed)"
echo "   - Your preferred code editor extensions"
echo "   - Language-specific tools (Go, Rust, etc.)"
echo ""
echo "Useful commands:"
echo "- wsl-info: Check WSL2 system status"
echo "- wsl-update: Update WSL2 system"
echo "- wsl-clean: Clean up system"
echo ""
echo "Happy coding in WSL2! 🚀"