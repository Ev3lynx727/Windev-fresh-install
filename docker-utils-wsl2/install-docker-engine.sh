#!/bin/bash
#
# ==============================================================================
# Docker Engine & NVIDIA Toolkit Installer for WSL2 (Debian/Ubuntu)
#
# Description: This script installs Docker Engine, Docker Compose, and the
#              NVIDIA Container Toolkit (if an NVIDIA GPU is detected).
# Usage: Run this script from within your WSL2 terminal with sudo privileges:
#        sudo bash ./install-docker-engine.sh
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status.

echo "--- [Step 1/6] Installing Docker Engine ---"

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "✅ Docker is already installed. Skipping installation."
else
    echo "Docker not found. Starting installation..."
    # Add Docker's official GPG key:
    apt-get update
    apt-get install -y ca-certificates curl pv
    install -m 0755 -d /etc/apt/keyrings
    echo "Downloading Docker GPG key..."
    curl -fL# https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    # Install the latest version
    echo "Installing Docker packages..."
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "✅ Docker Engine installed successfully."
fi

echo ""
echo "--- [Step 2/6] Checking for NVIDIA GPU & Installing Toolkit ---"

# Check for nvidia-smi. This command is available on the host and accessible from WSL
# if NVIDIA drivers are correctly installed on Windows.
if command -v nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA GPU detected. Proceeding with NVIDIA Container Toolkit setup."

    if ! command -v nvidia-ctk &> /dev/null; then
        echo "Installing NVIDIA Container Toolkit..."
        # Add NVIDIA's GPG key and repository with progress bars
        echo "Downloading NVIDIA GPG key..."
        curl -fsL https://nvidia.github.io/libnvidia-container/gpgkey | pv | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
        echo "Adding NVIDIA repository..."
        curl -sL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
          sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
        
        apt-get update
        apt-get install -y nvidia-container-toolkit
        
        echo "Configuring Docker to use the NVIDIA runtime..."
        nvidia-ctk runtime configure --runtime=docker
        
        echo "✅ NVIDIA Container Toolkit installed and configured."
    else
        echo "✅ NVIDIA Container Toolkit is already installed."
    fi
    
    # The Docker service will be restarted in the final step.
else
    echo "⚠️ No NVIDIA GPU detected (nvidia-smi command not found). Skipping toolkit installation."
fi

echo ""
echo "--- [Step 3/6] Adding User to 'docker' Group ---"

# Add the user who invoked sudo (or the current user if run as root) to the docker group
SUDO_USER=${SUDO_USER:-$USER}
if ! getent group docker | grep -q "\b${SUDO_USER}\b"; then
    echo "Adding user '$SUDO_USER' to the 'docker' group for sudo-less access..."
    usermod -aG docker "$SUDO_USER"
    echo "✅ User '$SUDO_USER' added. A new shell session is required for this to take effect."
else
    echo "✅ User '$SUDO_USER' is already in the 'docker' group."
fi

echo ""
echo "--- [Step 4/6] Installing ctop for Container Monitoring ---"

if command -v ctop &> /dev/null; then
    echo "✅ ctop is already installed. Skipping."
else
    echo "ctop not found. Installing..."
    # Using a known stable version for reliability
    CTOP_VERSION="0.7.7"
    CTOP_URL="https://github.com/bcicen/ctop/releases/download/v${CTOP_VERSION}/ctop-${CTOP_VERSION}-linux-amd64"
    
    echo "Downloading ctop v${CTOP_VERSION}..."
    curl -fL# "$CTOP_URL" -o /usr/local/bin/ctop
    chmod +x /usr/local/bin/ctop
    echo "✅ ctop installed successfully to /usr/local/bin/ctop"
fi

echo ""
echo "--- [Step 5/6] Installing lazydocker for TUI Management ---"

if command -v lazydocker &> /dev/null; then
    echo "✅ lazydocker is already installed. Skipping."
else
    echo "lazydocker not found. Installing..."
    # Find the latest version and download it
    LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    LAZYDOCKER_URL="https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
    
    echo "Downloading lazydocker v${LAZYDOCKER_VERSION}..."
    curl -fL# "$LAZYDOCKER_URL" -o lazydocker.tar.gz
    
    echo "Extracting and installing..."
    tar xf lazydocker.tar.gz lazydocker
    install -m 0755 lazydocker /usr/local/bin
    rm lazydocker lazydocker.tar.gz
    echo "✅ lazydocker installed successfully to /usr/local/bin/lazydocker"
fi

echo ""
echo "--- [Step 6/6] Starting Docker Service ---"
if ! service docker status | grep -q "is running"; then
    echo "Starting Docker service..."
    service docker start
fi
service docker status

echo ""
echo "🎉 Docker Engine setup is complete!"
echo "IMPORTANT: Please start a new WSL terminal session for group changes to apply."