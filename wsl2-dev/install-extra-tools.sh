#!/bin/bash
#
# ==============================================================================
# Install Extra Tools for WSL2 (Debian/Ubuntu)
#
# Description: Installs additional tools for WSL2 development environment,
#              including networking, monitoring, and utility tools.
# Usage: sudo bash ./install-extra-tools.sh
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

# --- Check if tool is installed ---
check_installed() {
    local tool=$1
    if command -v "$tool" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

echo "--- [Step 1/5] Updating Package Lists ---"
sudo apt update

echo ""
echo "--- [Step 2/5] Installing dnsenum ---"
if check_installed dnsenum; then
    log_success "dnsenum is already installed"
else
    log_info "Installing dnsenum..."
    sudo apt install -y dnsenum
    log_success "dnsenum installed"
fi

echo ""
echo "--- [Step 3/5] Installing lazyvim ---"
if check_installed nvim; then
    log_success "Neovim is already installed"
else
    log_info "Installing Neovim for lazyvim..."
    sudo apt install -y neovim
    log_success "Neovim installed"
fi

if [ -d "$HOME/.config/nvim" ]; then
    log_success "LazyVim config already exists"
else
    log_info "Installing LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    log_success "LazyVim installed"
fi

echo ""
echo "--- [Step 4/5] Installing lazydocker ---"
if check_installed lazydocker; then
    log_success "lazydocker is already installed"
else
    log_info "Installing lazydocker..."
    sudo apt install -y lazydocker
    log_success "lazydocker installed"
fi

echo ""
echo "--- [Step 5/5] Installing speedtest-cli ---"
# Merged from speedtest-wsl2.sh
if check_installed speedtest-cli; then
    log_success "speedtest-cli is already installed"
else
    log_info "Installing speedtest-cli..."

    # Try snap installation first (official speedtest CLI)
    if command -v snap >/dev/null 2>&1; then
        log_info "Trying snap installation (official speedtest CLI)..."
        if sudo -n true 2>/dev/null; then
            if sudo snap install speedtest; then
                log_success "Installed speedtest via snap"
                # Create symlinks for speedtest and speedtest2
                mkdir -p "$HOME/bin"
                if [ ! -L "$HOME/bin/speedtest" ]; then
                    sudo ln -sf "/snap/bin/speedtest" "$HOME/bin/speedtest"
                fi
                if [ ! -L "$HOME/bin/speedtest2" ]; then
                    sudo ln -sf "/snap/bin/speedtest" "$HOME/bin/speedtest2"
                    # Add ~/bin to PATH if not already there
                    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
                        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
                    fi
                    log_success "Created 'speedtest' and 'speedtest2' commands in ~/bin"
                    log_info "You can now use 'speedtest' or 'speedtest2' commands directly after restarting your shell"
                fi
            else
                log_warning "Snap installation failed, falling back to pip installation"
            fi
        else
            log_info "Snap available but requires password, using pip installation instead"
        fi
    else
        log_info "Snap not available, using pip installation"
    fi

    # Fallback: Install via pip if not installed via snap
    if ! check_installed speedtest-cli && ! check_installed speedtest; then
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

        # Create speedtest and speedtest2 symlinks in ~/bin for easy access
        mkdir -p "$HOME/bin"
        if [ ! -L "$HOME/bin/speedtest" ]; then
            ln -sf "$HOME/.local/bin/speedtest-cli" "$HOME/bin/speedtest"
        fi
        if [ ! -L "$HOME/bin/speedtest2" ]; then
            ln -sf "$HOME/.local/bin/speedtest-cli" "$HOME/bin/speedtest2"
            # Add ~/bin to PATH if not already there
            if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
                echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
            fi
            log_success "Created 'speedtest' and 'speedtest2' commands in ~/bin"
            log_info "You can now use 'speedtest' or 'speedtest2' commands directly after restarting your shell"
        else
            log_info "'speedtest' and 'speedtest2' commands already exist in ~/bin"
        fi

        log_success "speedtest-cli installed successfully"
    fi
fi

echo ""
echo "🎉 Extra tools installation complete!"
echo "Restart your shell or run 'source ~/.bashrc' to update PATH."
echo ""
echo "Installed tools:"
echo "  - dnsenum: DNS enumeration tool"
echo "  - lazyvim: Neovim-based IDE (run 'nvim' to start)"
echo "  - lazydocker: Docker TUI (run 'lazydocker')"
echo "  - speedtest-cli: Network speed test (run 'speedtest' or 'speedtest2')"