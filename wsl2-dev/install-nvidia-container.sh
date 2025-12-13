#!/bin/bash
#
# ==============================================================================
# NVIDIA GPU & Container Toolkit Installer for WSL2 (Debian/Ubuntu)
#
# Description: Installs NVIDIA CUDA Toolkit and Container Toolkit for GPU
#              acceleration in WSL2 Docker containers.
# Usage: sudo bash ./install-nvidia-container.sh
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status.

# --- Color Definitions ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

echo "--- [Step 1/4] Checking for NVIDIA GPU ---"

# Ensure the script is run with sudo
if [ -z "$SUDO_USER" ]; then
    echo -e "${C_RED}✗${C_NC} Please run this script with sudo: sudo bash install-nvidia-container.sh"
    exit 1
fi

# Check for nvidia-smi. This command is available on the host and accessible from WSL
# if NVIDIA drivers are correctly installed on Windows.
echo "Ensure NVIDIA drivers are installed on Windows and WSL2 has access."
echo "Running nvidia-smi to verify GPU..."
if /usr/lib/wsl/lib/nvidia-smi; then
    echo -e "${C_GREEN}✓${C_NC} NVIDIA GPU detected. Proceeding with setup."
else
    echo -e "${C_RED}✗${C_NC} No NVIDIA GPU detected (nvidia-smi failed). Exiting."
    exit 1
fi

echo ""
echo "--- [Step 2/4] Installing NVIDIA CUDA Toolkit ---"

if command -v nvcc &> /dev/null; then
    echo -e "${C_GREEN}✓${C_NC} NVIDIA CUDA Toolkit is already installed."
else
    echo "Installing NVIDIA CUDA Toolkit..."
    sudo apt update && sudo apt install -y nvidia-cuda-toolkit
    echo -e "${C_GREEN}✓${C_NC} NVIDIA CUDA Toolkit installed."
fi

# Verify CUDA installation
if command -v nvcc &> /dev/null; then
    echo "CUDA Compiler (nvcc) version:"
    nvcc --version | head -n 4
else
    echo -e "${C_RED}✗${C_NC} CUDA installation failed. Check your setup."
    exit 1
fi

echo ""
echo "--- [Step 3/4] Installing NVIDIA Container Toolkit ---"

if command -v nvidia-ctk &> /dev/null; then
    echo -e "${C_GREEN}✓${C_NC} NVIDIA Container Toolkit is already installed."
else
    echo "Installing NVIDIA Container Toolkit..."
    # Add NVIDIA's GPG key and repository
    curl -fsL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit

    echo "Configuring Docker to use the NVIDIA runtime..."
    sudo nvidia-ctk runtime configure --runtime=docker

    echo -e "${C_GREEN}✓${C_NC} NVIDIA Container Toolkit installed and configured."
fi

echo ""
echo "--- [Step 4/4] Testing NVIDIA Container Setup ---"

    echo "Testing GPU access in Docker container..."
    if docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1; then
        echo -e "${C_GREEN}✓${C_NC} NVIDIA GPU accessible in Docker containers."
    else
        echo -e "${C_YELLOW}⚠${C_NC} GPU test failed. Try restarting Docker: sudo systemctl restart docker"
        echo "Or check Docker daemon: docker info | grep -i runtime"
        echo "Or test manually: docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu22.04 nvidia-smi"
    fi

echo ""
echo "🎉 NVIDIA GPU & Container setup complete!"
echo "You can now run GPU-accelerated containers with: docker run --gpus all <image>"
echo ""
echo "Installed components:"
echo "  - NVIDIA CUDA Toolkit: Host-side CUDA development tools"
echo "  - NVIDIA Container Toolkit: GPU access in Docker containers"