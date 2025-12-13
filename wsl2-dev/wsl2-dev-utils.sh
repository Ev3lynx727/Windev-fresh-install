#!/bin/bash

# ==============================================================================
# WSL2 Development Utility Functions
#
# Description: A collection of helper functions to manage WSL2 development environments.
# To use, save this script and source it in your .bashrc or .zshrc:
#   echo "source ~/wsl2-dev-utils.sh" >> ~/.bashrc
#   source ~/.bashrc
# ==============================================================================

# --- Color Definitions for better readability ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# wsl-info: Displays a high-level summary of the WSL2 environment.
# ------------------------------------------------------------------------------
wsl-info() {
    echo -e "${C_BLUE}--- WSL2 System Info ---${C_NC}"

    # OS Information
    echo -e "${C_YELLOW}OS Information:${C_NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "Distro:   ${C_GREEN}$PRETTY_NAME${C_NC}"
    fi
    echo -e "Kernel:   ${C_GREEN}$(uname -r)${C_NC}"
    echo -e "Arch:     ${C_GREEN}$(uname -m)${C_NC}"

    echo ""

    # Resource Usage
    echo -e "${C_YELLOW}Resource Usage:${C_NC}"
    echo -e "Memory:   $(free -h | awk 'NR==2{printf "%s used, %s free", $3, $4}')"
    echo -e "Disk:     $(df -h / | awk 'NR==2{printf "%s used of %s (%s)", $3, $2, $5}')"

    echo ""

    # WSL Specific
    echo -e "${C_YELLOW}WSL2 Specific:${C_NC}"
    if [ -f /proc/version ]; then
        if grep -q "microsoft" /proc/version; then
            echo -e "WSL Version: ${C_GREEN}WSL2${C_NC}"
        else
            echo -e "WSL Version: ${C_YELLOW}Unknown${C_NC}"
        fi
    fi

    # Check Windows drives
    echo -e "Windows Drives:"
    for drive in /mnt/[a-z]; do
        if [ -d "$drive" ]; then
            drive_letter=$(basename "$drive" | tr '[:lower:]' '[:upper:]')
            echo -e "  ${drive_letter}: ${C_GREEN}Mounted${C_NC}"
        fi
    done

    echo ""

    # Development Tools Status
    echo -e "${C_YELLOW}Development Tools:${C_NC}"
    tools=("git" "python3" "node" "npm" "docker")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            version=$($tool --version 2>/dev/null | head -n1 | awk '{print $NF}')
            echo -e "  $tool: ${C_GREEN}Installed${C_NC} ($version)"
        else
            echo -e "  $tool: ${C_RED}Not found${C_NC}"
        fi
    done
}

# ------------------------------------------------------------------------------
# wsl-update: Updates the WSL2 system and installed packages.
# ------------------------------------------------------------------------------
wsl-update() {
    echo -e "${C_BLUE}--- Updating WSL2 System ---${C_NC}"
    echo -e "${C_YELLOW}This will update system packages and may take several minutes.${C_NC}"

    read -p "Continue with system update? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Update cancelled."
        return 1
    fi

    echo -e "${C_YELLOW}Updating package lists...${C_NC}"
    sudo apt-get update

    echo -e "${C_YELLOW}Upgrading packages...${C_NC}"
    sudo apt-get upgrade -y

    echo -e "${C_YELLOW}Cleaning up...${C_NC}"
    sudo apt-get autoremove -y
    sudo apt-get autoclean

    echo -e "\n${C_GREEN}✅ WSL2 system update complete. You may want to restart your terminal.${C_NC}"
}

# ------------------------------------------------------------------------------
# wsl-clean: Cleans up the WSL2 environment (packages, cache, temp files).
# ------------------------------------------------------------------------------
wsl-clean() {
    echo -e "${C_BLUE}--- WSL2 System Cleanup ---${C_NC}"
    echo -e "${C_YELLOW}This will remove unnecessary packages and clean caches.${C_NC}"

    read -p "Continue with cleanup? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        return 1
    fi

    echo -e "${C_YELLOW}Removing unnecessary packages...${C_NC}"
    sudo apt-get autoremove -y

    echo -e "${C_YELLOW}Cleaning package cache...${C_NC}"
    sudo apt-get autoclean
    sudo apt-get clean

    echo -e "${C_YELLOW}Cleaning temporary files...${C_NC}"
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*

    echo -e "${C_YELLOW}Clearing bash history...${C_NC}"
    history -c
    rm -f ~/.bash_history

    echo -e "\n${C_GREEN}✅ WSL2 cleanup complete.${C_NC}"
    echo -e "${C_YELLOW}Disk usage after cleanup:${C_NC}"
    df -h /
}

# ------------------------------------------------------------------------------
# wsl-gpu-check: Checks for NVIDIA GPU availability and provides setup info.
# ------------------------------------------------------------------------------
wsl-gpu-check() {
    echo -e "${C_BLUE}--- WSL2 GPU Check ---${C_NC}"

    if command -v nvidia-smi >/dev/null 2>&1; then
        echo -e "NVIDIA GPU: ${C_GREEN}Detected${C_NC}"
        echo -e "${C_YELLOW}GPU Information:${C_NC}"
        nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
        echo ""

        # Check if NVIDIA Container Toolkit is available
        if command -v nvidia-container-runtime >/dev/null 2>&1; then
            echo -e "NVIDIA Container Toolkit: ${C_GREEN}Installed${C_NC}"
            echo -e "${C_YELLOW}Docker GPU Support:${C_NC} Available"
        else
            echo -e "NVIDIA Container Toolkit: ${C_RED}Not installed${C_NC}"
            echo -e "${C_YELLOW}To install:${C_NC} sudo apt-get install nvidia-container-toolkit"
        fi
    else
        echo -e "NVIDIA GPU: ${C_RED}Not detected${C_NC}"
        echo -e "${C_YELLOW}Note:${C_NC} GPU passthrough requires NVIDIA drivers on Windows host"
        echo -e "      and WSL2 kernel with GPU support."
    fi

    # Check for other GPU info
    if [ -d /dev/dri ]; then
        echo -e "Direct Rendering: ${C_GREEN}Available${C_NC}"
    else
        echo -e "Direct Rendering: ${C_YELLOW}Not available${C_NC}"
    fi
}

# ------------------------------------------------------------------------------
# wsl-mount-windows: Mounts Windows drives for easy access.
# ------------------------------------------------------------------------------
wsl-mount-windows() {
    echo -e "${C_BLUE}--- Mounting Windows Drives ---${C_NC}"

    # Common Windows drives to mount
    drives=("c" "d" "e" "f")

    for drive in "${drives[@]}"; do
        mount_point="/mnt/$drive"
        if [ ! -d "$mount_point" ]; then
            echo -e "${C_YELLOW}Creating mount point for ${drive^^}:...${C_NC}"
            sudo mkdir -p "$mount_point"
        fi

        if mountpoint -q "$mount_point"; then
            echo -e "${drive^^}: ${C_GREEN}Already mounted${C_NC} at $mount_point"
        else
            echo -e "${C_YELLOW}Mounting ${drive^^}:...${C_NC}"
            if sudo mount -t drvfs "${drive^^}:" "$mount_point" 2>/dev/null; then
                echo -e "${drive^^}: ${C_GREEN}Mounted successfully${C_NC} at $mount_point"
            else
                echo -e "${drive^^}: ${C_RED}Failed to mount${C_NC} (drive may not exist)"
            fi
        fi
    done

    echo -e "\n${C_GREEN}✅ Windows drive mounting complete.${C_NC}"
    echo -e "${C_YELLOW}Access Windows files:${C_NC} cd /mnt/c/Users/YourUsername/"
}

# ------------------------------------------------------------------------------
# wsl-network-info: Shows comprehensive network information and status.
# ------------------------------------------------------------------------------
wsl-network-info() {
    echo -e "${C_BLUE}--- WSL2 Network Information ---${C_NC}"

    echo -e "${C_YELLOW}Network Interfaces:${C_NC}"
    ip addr show | grep -E "^[0-9]+:" | sed 's/^/  /'

    echo -e "\n${C_YELLOW}Routing Table:${C_NC}"
    ip route | sed 's/^/  /'

    echo -e "\n${C_YELLOW}DNS Configuration:${C_NC}"
    if [ -f /etc/resolv.conf ]; then
        cat /etc/resolv.conf | sed 's/^/  /'
    else
        echo -e "  ${C_RED}No resolv.conf found${C_NC}"
    fi

    echo -e "\n${C_YELLOW}Active Connections:${C_NC}"
    ss -tuln | head -10 | sed 's/^/  /'

    echo -e "\n${C_YELLOW}Network Connectivity Test:${C_NC}"
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "  ${C_GREEN}✓${C_NC} Internet connectivity OK"
    else
        echo -e "  ${C_RED}✗${C_NC} No internet connectivity"
    fi
}

# ------------------------------------------------------------------------------
# wsl-dns-test: Tests DNS resolution and configuration.
# ------------------------------------------------------------------------------
wsl-dns-test() {
    local domain=${1:-google.com}

    echo -e "${C_BLUE}--- DNS Resolution Test ---${C_NC}"
    echo -e "${C_YELLOW}Testing domain: ${C_CYAN}$domain${C_NC}"

    echo -e "\n${C_YELLOW}DNS Servers:${C_NC}"
    grep nameserver /etc/resolv.conf | sed 's/^/  /' || echo -e "  ${C_RED}No DNS servers configured${C_NC}"

    echo -e "\n${C_YELLOW}Resolution Results:${C_NC}"

    # Test with different DNS tools if available
    if command -v dig >/dev/null 2>&1; then
        echo -e "  ${C_BLUE}Using dig:${C_NC}"
        dig +short "$domain" | sed 's/^/    /' || echo -e "    ${C_RED}dig failed${C_NC}"
    fi

    if command -v nslookup >/dev/null 2>&1; then
        echo -e "  ${C_BLUE}Using nslookup:${C_NC}"
        nslookup "$domain" 2>/dev/null | grep -A5 "Name:" | sed 's/^/    /' || echo -e "    ${C_RED}nslookup failed${C_NC}"
    fi

    if command -v host >/dev/null 2>&1; then
        echo -e "  ${C_BLUE}Using host:${C_NC}"
        host "$domain" 2>/dev/null | sed 's/^/    /' || echo -e "    ${C_RED}host failed${C_NC}"
    fi
}

# ------------------------------------------------------------------------------
# wsl-http-test: Tests HTTP connectivity and server response.
# ------------------------------------------------------------------------------
wsl-http-test() {
    local url=$1

    if [ -z "$url" ]; then
        echo -e "${C_RED}Usage: wsl-http-test <url>${C_NC}"
        echo -e "${C_YELLOW}Example: wsl-http-test https://google.com${C_NC}"
        return 1
    fi

    echo -e "${C_BLUE}--- HTTP Connectivity Test ---${C_NC}"
    echo -e "${C_YELLOW}Testing URL: ${C_CYAN}$url${C_NC}"

    # Test with curl
    if command -v curl >/dev/null 2>&1; then
        echo -e "\n${C_YELLOW}Using curl:${C_NC}"
        curl -I --connect-timeout 10 "$url" 2>/dev/null | head -5 | sed 's/^/  /' || echo -e "  ${C_RED}curl failed${C_NC}"
    fi

    # Test with httpie if available
    if command -v http >/dev/null 2>&1; then
        echo -e "\n${C_YELLOW}Using httpie:${C_NC}"
        http --headers "$url" 2>/dev/null | head -5 | sed 's/^/  /' || echo -e "  ${C_RED}httpie failed${C_NC}"
    fi

    # Basic connectivity test
    echo -e "\n${C_YELLOW}Basic connectivity:${C_NC}"
    if curl -s --head --connect-timeout 5 "$url" >/dev/null 2>&1; then
        echo -e "  ${C_GREEN}✓${C_NC} Server is reachable"
    else
        echo -e "  ${C_RED}✗${C_NC} Server is not reachable"
    fi
}

# ------------------------------------------------------------------------------
# wsl-fix-network: Resets WSL2 networking when connectivity issues occur.
# ------------------------------------------------------------------------------
wsl-fix-network() {
    echo -e "${C_BLUE}--- WSL2 Network Reset ---${C_NC}"
    echo -e "${C_YELLOW}This will restart networking services to fix connectivity issues.${C_NC}"

    read -p "Continue with network reset? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Network reset cancelled."
        return 1
    fi

    echo -e "${C_YELLOW}Stopping network services...${C_NC}"
    sudo service networking stop 2>/dev/null || true
    sudo service network-manager stop 2>/dev/null || true

    echo -e "${C_YELLOW}Restarting WSL networking...${C_NC}"
    # Generate new resolv.conf
    sudo rm -f /etc/resolv.conf
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
    echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf > /dev/null

    echo -e "${C_YELLOW}Starting network services...${C_NC}"
    sudo service networking start 2>/dev/null || true
    sudo service network-manager start 2>/dev/null || true

    echo -e "${C_YELLOW}Testing connectivity...${C_NC}"
    if ping -c 1 google.com >/dev/null 2>&1; then
        echo -e "Network: ${C_GREEN}Working${C_NC}"
    else
        echo -e "Network: ${C_RED}Still having issues${C_NC}"
        echo -e "${C_YELLOW}Try:${C_NC} wsl --shutdown from Windows, then restart WSL"
    fi

    echo -e "\n${C_GREEN}✅ Network reset complete.${C_NC}"
}

# --- On-load message ---

echo -e "${C_GREEN}WSL2 development utilities loaded.${C_NC} Available commands:"
echo -e "  - ${C_YELLOW}wsl-info${C_NC}: Show WSL2 system status summary."
echo -e "  - ${C_YELLOW}wsl-update${C_NC}: Update WSL2 system and packages."
echo -e "  - ${C_YELLOW}wsl-clean${C_NC}: Clean up unnecessary packages and files."
echo -e "  - ${C_YELLOW}wsl-gpu-check${C_NC}: Check NVIDIA GPU availability."
echo -e "  - ${C_YELLOW}wsl-mount-windows${C_NC}: Mount Windows drives for access."
echo -e "  - ${C_YELLOW}wsl-network-info${C_NC}: Show comprehensive network information."
echo -e "  - ${C_YELLOW}wsl-dns-test [domain]${C_NC}: Test DNS resolution."
echo -e "  - ${C_YELLOW}wsl-http-test <url>${C_NC}: Test HTTP connectivity."
echo -e "  - ${C_YELLOW}wsl-fix-network${C_NC}: Reset networking when having connectivity issues."