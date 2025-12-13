#!/bin/bash

# ==============================================================================
# WSL2 System Checkup Script
#
# Description: Checks the current state of WSL2 development environment
# Reports what's installed vs missing, helping determine what needs to be installed
#
# Usage: ./system-checkup.sh
# ==============================================================================

# --- Color Definitions ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_NC='\033[0m' # No Color

# --- Helper Functions ---
log_header() {
    echo -e "${C_BLUE}================================================================================${C_NC}"
    echo -e "${C_BLUE}$1${C_NC}"
    echo -e "${C_BLUE}================================================================================${C_NC}"
}

log_section() {
    echo -e "${C_CYAN}--- $1 ---${C_NC}"
}

check_installed() {
    local package=$1
    local description=$2

    if command -v "$package" >/dev/null 2>&1; then
        echo -e "${C_GREEN}✓${C_NC} $description ($package)"
        return 0
    else
        echo -e "${C_RED}✗${C_NC} $description ($package)"
        return 1
    fi
}

check_package() {
    local package=$1
    local description=$2

    if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
        echo -e "${C_GREEN}✓${C_NC} $description ($package)"
        return 0
    else
        echo -e "${C_RED}✗${C_NC} $description ($package)"
        return 1
    fi
}

check_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        echo -e "${C_GREEN}✓${C_NC} $description ($file)"
        return 0
    else
        echo -e "${C_RED}✗${C_NC} $description ($file)"
        return 1
    fi
}

check_directory() {
    local dir=$1
    local description=$2

    if [ -d "$dir" ]; then
        echo -e "${C_GREEN}✓${C_NC} $description ($dir)"
        return 0
    else
        echo -e "${C_RED}✗${C_NC} $description ($dir)"
        return 1
    fi
}

# --- System Information ---
log_header "WSL2 System Checkup Report"
echo "Generated on: $(date)"
echo "WSL2 Distro: $(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
echo "Kernel: $(uname -r)"
echo ""

# --- STEP 1: System Environment ---
log_section "1. System Environment"

echo "WSL2 Detection:"
if [ -f /proc/version ] && grep -q "microsoft" /proc/version; then
    echo -e "${C_GREEN}✓${C_NC} Running on WSL2"
else
    echo -e "${C_RED}✗${C_NC} Not running on WSL2"
fi

echo ""
echo "Internet Connectivity:"
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo -e "${C_GREEN}✓${C_NC} Internet connection available"
else
    echo -e "${C_RED}✗${C_NC} No internet connection"
fi

echo ""
echo "System Updates:"
LAST_UPDATE=$(stat -c %Y /var/cache/apt/pkgcache.bin 2>/dev/null || echo "0")
CURRENT_TIME=$(date +%s)
DAYS_SINCE_UPDATE=$(( (CURRENT_TIME - LAST_UPDATE) / 86400 ))

if [ $DAYS_SINCE_UPDATE -le 7 ]; then
    echo -e "${C_GREEN}✓${C_NC} System updated recently ($DAYS_SINCE_UPDATE days ago)"
else
    echo -e "${C_YELLOW}⚠${C_NC} System not updated recently ($DAYS_SINCE_UPDATE days ago)"
fi

echo ""

# --- STEP 2: Essential System Packages ---
log_section "2. Essential System Packages"

echo "Basic Networking Tools:"
check_package netcat-openbsd "Netcat"
check_package net-tools "Network tools"
check_package iputils-ping "Ping utilities"
check_package openssh-server "OpenSSH server"
check_package openssh-client "OpenSSH client"
check_package curl "cURL"
check_package wget "Wget"

echo ""
echo "DNS & Network Analysis:"
check_package dnsutils "DNS utilities (dig, nslookup)"
check_package traceroute "Traceroute"
check_package whois "WHOIS lookup"

echo ""
echo "Network Monitoring:"
check_package iftop "iftop (bandwidth monitoring)"
check_package nload "nload (network load)"
check_package bmon "bmon (bandwidth monitor)"

echo ""
echo "Advanced HTTP Tools:"
check_package httpie "HTTPie (modern HTTP client)"
check_package siege "Siege (HTTP load testing)"
# check_package apache2-utils "Apache utils (ab benchmark)"  # Commented out

echo ""
echo "Network Utilities:"
check_package telnet "Telnet client"
check_package ftp "FTP client"
check_package socat "Socat (advanced netcat)"

echo ""
echo "SSL & Security:"
check_package openssl "OpenSSL"
check_package ca-certificates "CA certificates"

echo ""
echo "System Utilities:"
check_package procps "Process utilities"
check_package software-properties-common "Software properties"
check_package apt-transport-https "HTTPS transport for APT"
check_package lsb-release "LSB release info"
check_package gnupg "GnuPG"
check_package unzip "Unzip"
check_package zip "Zip"
check_package jq "JQ JSON processor"
check_package tree "Tree directory viewer"
check_package htop "Htop process viewer"
check_package ncdu "NCdu disk usage"

echo ""

# --- STEP 3: Development Tools ---
log_section "3. Development Tools"

echo "Version Control:"
check_installed git "Git"

echo ""
echo "Build Tools:"
check_package build-essential "Build essentials"
check_package cmake "CMake"
check_package make "Make"

echo ""
echo "Programming Languages:"
check_installed python3 "Python 3"
check_installed node "Node.js"
check_installed npm "NPM"

echo ""
echo "Editors & Terminals:"
check_installed vim "Vim"
check_installed nano "Nano"
check_installed tmux "Tmux"
check_installed zsh "Zsh"

echo ""
echo "Documentation:"
check_package man-db "Manual pages"
check_installed tldr "TLDR pages"

echo ""

# --- STEP 4: Package Managers & Environments ---
log_section "4. Package Managers & Environments"

echo "Python Package Management:"
check_installed pip3 "Pip3"
check_directory "$HOME/.local/lib/python3.*/site-packages" "Python user packages"

if pip3 list --user 2>/dev/null | grep -q virtualenv; then
    echo -e "${C_GREEN}✓${C_NC} Virtualenv installed"
else
    echo -e "${C_RED}✗${C_NC} Virtualenv not installed"
fi

if pip3 list --user 2>/dev/null | grep -q pipenv; then
    echo -e "${C_GREEN}✓${C_NC} Pipenv installed"
else
    echo -e "${C_RED}✗${C_NC} Pipenv not installed"
fi

echo ""
echo "Node.js Version Management:"
check_directory "$HOME/.nvm" "NVM (Node Version Manager)"

if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    if nvm list 2>/dev/null | grep -q "lts/"; then
        echo -e "${C_GREEN}✓${C_NC} Node.js LTS version installed via NVM"
    else
        echo -e "${C_RED}✗${C_NC} Node.js LTS version not installed via NVM"
    fi
fi

echo ""

# --- STEP 5: Configuration & Environment ---
log_section "5. Configuration & Environment"

echo "Git Configuration:"
if [ -n "$(git config --global user.name)" ]; then
    echo -e "${C_GREEN}✓${C_NC} Git user name configured ($(git config --global user.name))"
else
    echo -e "${C_RED}✗${C_NC} Git user name not configured"
fi

if [ -n "$(git config --global user.email)" ]; then
    echo -e "${C_GREEN}✓${C_NC} Git user email configured ($(git config --global user.email))"
else
    echo -e "${C_RED}✗${C_NC} Git user email not configured"
fi

echo ""
echo "Shell Environment:"
if grep -q "NVM_DIR" ~/.bashrc; then
    echo -e "${C_GREEN}✓${C_NC} NVM configured in .bashrc"
else
    echo -e "${C_RED}✗${C_NC} NVM not configured in .bashrc"
fi

if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    echo -e "${C_GREEN}✓${C_NC} Local bin directory in PATH"
else
    echo -e "${C_RED}✗${C_NC} Local bin directory not in PATH"
fi

echo ""

# --- STEP 6: System Services & Container Runtime ---
log_section "6. System Services & Container Runtime"

echo "System Services:"
# Check systemd
if pidof systemd >/dev/null 2>&1; then
    echo -e "${C_GREEN}✓${C_NC} Systemd service running"
else
    echo -e "${C_RED}✗${C_NC} Systemd service not running"
fi

# Check sysctl
if command -v sysctl >/dev/null 2>&1; then
    echo -e "${C_GREEN}✓${C_NC} Sysctl available"
    # Check if we can read kernel parameters
    if sysctl -n kernel.osrelease >/dev/null 2>&1; then
        echo -e "${C_GREEN}✓${C_NC} Sysctl kernel parameters accessible"
    else
        echo -e "${C_YELLOW}⚠${C_NC} Sysctl available but kernel parameters not accessible"
    fi
else
    echo -e "${C_RED}✗${C_NC} Sysctl not available"
fi

echo ""
echo "Container Runtime:"
check_installed docker "Docker"

if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        echo -e "${C_GREEN}✓${C_NC} Docker daemon running"
    else
        echo -e "${C_YELLOW}⚠${C_NC} Docker installed but daemon not running"
    fi
fi

echo ""

# --- STEP 7: Summary & Recommendations ---
log_section "7. Summary & Recommendations"

echo "To install missing components, run:"
echo "  ./install-dev-tools-wsl2.sh"
echo ""

echo "For WSL2 utilities, source:"
echo "  source wsl-dev-utils.sh"
echo ""

echo "Checkup completed on: $(date)"
echo -e "${C_BLUE}================================================================================${C_NC}"