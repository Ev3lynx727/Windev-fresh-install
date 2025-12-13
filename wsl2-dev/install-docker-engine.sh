#!/bin/bash
#
# ==============================================================================
# Docker Engine & Utilities Setup for WSL2 (Debian/Ubuntu)
#
# Description: This script installs Docker Engine, Docker Compose, NVIDIA Container
#              Toolkit (if GPU detected), and provides utility functions for Docker
#              management in WSL2.
# Usage:
#   - Install: sudo bash ./install-docker-engine.sh
#   - Utils: source ./install-docker-engine.sh (after install)
# ==============================================================================

# --- Color Definitions for better readability ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

# ==============================================================================
# Docker Utility Functions for WSL2
# ==============================================================================

# ... (functions here, but since long, I'll move them up)


    echo ""

    echo -e "${C_YELLOW}Version Information:${C_NC}"
    docker --version
    docker compose version
    echo ""

    echo -e "${C_YELLOW}Running Containers:${C_NC}"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    echo ""

    echo -e "${C_YELLOW}Docker Resource Usage:${C_NC}"
    docker system df
    echo ""
}

# ------------------------------------------------------------------------------
# docker-prune: A more aggressive cleanup utility.
# WARNING: This will stop and remove ALL containers, networks, and build cache.
# ------------------------------------------------------------------------------
docker-prune() {
    echo -e "${C_RED}--- Aggressive Docker Cleanup ---${C_NC}"
    read -p "🚨 WARNING: This will stop and remove ALL containers. Are you sure? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        return 1
    fi

    # Stop all running containers
    if [ "$(docker ps -q)" ]; then
        echo -e "${C_YELLOW}Stopping all running containers...${C_NC}"
        docker stop $(docker ps -aq)
    else
        echo -e "${C_GREEN}No running containers to stop.${C_NC}"
    fi

    # Prune system with --all flag
    echo -e "${C_YELLOW}Running 'docker system prune --all'...${C_NC}"
    echo "This will remove all stopped containers, all networks not used by at least one container, all dangling images, and all build cache."
    docker system prune --all -f

    # Prune volumes
    echo -e "${C_YELLOW}Running 'docker volume prune'...${C_NC}"
    echo "This will remove all local volumes not used by at least one container."
    docker volume prune -f

    echo -e "\n${C_GREEN}✅ Full Docker cleanup complete.${C_NC}"
}

# ------------------------------------------------------------------------------
# docker-shell: Gets an interactive shell inside a running container.
# Usage: docker-shell <container_name_or_id>
# ------------------------------------------------------------------------------
docker-shell() {
    if [ -z "$1" ]; then
        echo -e "${C_RED}Usage: docker-shell <container_name_or_id>${C_NC}"
        echo -e "${C_YELLOW}Available running containers:${C_NC}"
        docker ps --format "{{.Names}}"
        return 1
    fi

    CONTAINER_ID=$1
    echo -e "${C_GREEN}Attempting to connect to shell in container: $CONTAINER_ID...${C_NC}"

    # Check for /bin/bash, fallback to /bin/sh (common in Alpine images)
    if docker exec -it "$CONTAINER_ID" bash -c "true" >/dev/null 2>&1; then
        docker exec -it "$CONTAINER_ID" /bin/bash
    else
        docker exec -it "$CONTAINER_ID" /bin/sh
    fi
}

# ------------------------------------------------------------------------------
# docker-update: Updates Docker packages on Debian/Ubuntu-based systems.
# ------------------------------------------------------------------------------
docker-update() {
    echo -e "${C_BLUE}--- Updating Docker Engine Packages ---${C_NC}"
    echo -e "${C_YELLOW}This requires sudo privileges and runs apt-get.${C_NC}"

    sudo apt-get update && sudo apt-get install --only-upgrade \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin \
      docker-model-plugin

    echo -e "\n${C_GREEN}✅ Docker package update process finished.${C_NC}"
}


# ------------------------------------------------------------------------------
# docker-ctop: Launches ctop for terminal-based container monitoring.
# ------------------------------------------------------------------------------
docker-ctop() {
    echo -e "${C_BLUE}--- Starting ctop ---${C_NC}"

    # Check if native ctop is installed, else use Docker version
    if command -v ctop &> /dev/null; then
        echo -e "${C_YELLOW}Using installed ctop... (Press 'q' to quit)${C_NC}"
        ctop
    else
        # Fallback to Docker version
        if ! docker image inspect quay.io/vektorlab/ctop:latest >/dev/null 2>&1; then
            echo -e "${C_YELLOW}Image 'quay.io/vektorlab/ctop:latest' not found locally.${C_NC}"
            echo -e "${C_YELLOW}Pulling from Docker Hub...${C_NC}"
            docker pull quay.io/vektorlab/ctop:latest
        fi

        echo -e "${C_YELLOW}Running ctop via Docker... (Press 'q' to quit)${C_NC}"
        docker run --rm -it \
            --name=ctop \
            --volume /var/run/docker.sock:/var/run/docker.sock:ro \
            quay.io/vektorlab/ctop:latest
    fi
}

# --- On-load message for utilities ---
if [ "$0" != "${BASH_SOURCE[0]}" ]; then
    echo -e "${C_GREEN}Docker utilities loaded.${C_NC} Available commands:"
    echo -e "  - ${C_YELLOW}docker-info${C_NC}: Show Docker status summary."
    echo -e "  - ${C_YELLOW}docker-prune${C_NC}: Aggressively prune all containers, networks, and build cache."
    echo -e "  - ${C_YELLOW}docker-shell <container>${C_NC}: Exec into a running container's shell."
    echo -e "  - ${C_YELLOW}docker-ctop${C_NC}: Launch ctop container monitor."
    echo -e "  - ${C_YELLOW}docker-update${C_NC}: Update Docker Engine packages via apt."
fi

# ==============================================================================
# Installation Logic (runs only when executed, not sourced)
# ==============================================================================

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    set -e # Exit immediately if a command exits with a non-zero status.

    echo "--- [Step 1/5] Installing Docker Engine ---"

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
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-model-plugin
    echo "✅ Docker Engine installed successfully."
fi


    
    # The Docker service will be restarted in the final step.
else
    echo "⚠️ No NVIDIA GPU detected (nvidia-smi command not found). Skipping toolkit installation."
fi

echo ""
echo "--- [Step 2/6] Adding User to 'docker' Group ---"

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
echo "--- [Step 3/6] Installing ctop for Container Monitoring ---"

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
echo "--- [Step 4/6] Installing lazydocker for TUI Management ---"

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
echo "--- [Step 5/6] Starting Docker Service ---"
if ! service docker status | grep -q "is running"; then
    echo "Starting Docker service..."
    service docker start
fi
service docker status

    echo ""
echo "🎉 Docker Engine setup is complete!"
echo "IMPORTANT: Please start a new WSL terminal session for group changes to apply."
echo ""
echo "Note: For NVIDIA GPU support in containers, run: sudo bash install-nvidia-container.sh"
fi


    echo ""

    echo -e "${C_YELLOW}Version Information:${C_NC}"
    docker --version
    docker compose version
    echo ""

    echo -e "${C_YELLOW}Running Containers:${C_NC}"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    echo ""

    echo -e "${C_YELLOW}Docker Resource Usage:${C_NC}"
    docker system df
    echo ""
}

# ------------------------------------------------------------------------------
# docker-prune: A more aggressive cleanup utility.
# WARNING: This will stop and remove ALL containers, networks, and build cache.
# ------------------------------------------------------------------------------
docker-prune() {
    echo -e "${C_RED}--- Aggressive Docker Cleanup ---${C_NC}"
    read -p "🚨 WARNING: This will stop and remove ALL containers. Are you sure? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        return 1
    fi

    # Stop all running containers
    if [ "$(docker ps -q)" ]; then
        echo -e "${C_YELLOW}Stopping all running containers...${C_NC}"
        docker stop $(docker ps -aq)
    else
        echo -e "${C_GREEN}No running containers to stop.${C_NC}"
    fi

    # Prune system with --all flag
    echo -e "${C_YELLOW}Running 'docker system prune --all'...${C_NC}"
    echo "This will remove all stopped containers, all networks not used by at least one container, all dangling images, and all build cache."
    docker system prune --all -f

    # Prune volumes
    echo -e "${C_YELLOW}Running 'docker volume prune'...${C_NC}"
    echo "This will remove all local volumes not used by at least one container."
    docker volume prune -f

    echo -e "\n${C_GREEN}✅ Full Docker cleanup complete.${C_NC}"
}

# ------------------------------------------------------------------------------
# docker-shell: Gets an interactive shell inside a running container.
# Usage: docker-shell <container_name_or_id>
# ------------------------------------------------------------------------------
docker-shell() {
    if [ -z "$1" ]; then
        echo -e "${C_RED}Usage: docker-shell <container_name_or_id>${C_NC}"
        echo -e "${C_YELLOW}Available running containers:${C_NC}"
        docker ps --format "{{.Names}}"
        return 1
    fi

    CONTAINER_ID=$1
    echo -e "${C_GREEN}Attempting to connect to shell in container: $CONTAINER_ID...${C_NC}"

    # Check for /bin/bash, fallback to /bin/sh (common in Alpine images)
    if docker exec -it "$CONTAINER_ID" bash -c "true" >/dev/null 2>&1; then
        docker exec -it "$CONTAINER_ID" /bin/bash
    else
        docker exec -it "$CONTAINER_ID" /bin/sh
    fi
}

# ------------------------------------------------------------------------------
# docker-update: Updates Docker packages on Debian/Ubuntu-based systems.
# ------------------------------------------------------------------------------
docker-update() {
    echo -e "${C_BLUE}--- Updating Docker Engine Packages ---${C_NC}"
    echo -e "${C_YELLOW}This requires sudo privileges and runs apt-get.${C_NC}"

    sudo apt-get update && sudo apt-get install --only-upgrade \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin

    echo -e "\n${C_GREEN}✅ Docker package update process finished.${C_NC}"
}

# ------------------------------------------------------------------------------
# docker-ctop: Launches ctop for terminal-based container monitoring.
# ------------------------------------------------------------------------------
docker-ctop() {
    echo -e "${C_BLUE}--- Starting ctop ---${C_NC}"

    # Check if native ctop is installed, else use Docker version
    if command -v ctop &> /dev/null; then
        echo -e "${C_YELLOW}Using installed ctop... (Press 'q' to quit)${C_NC}"
        ctop
    else
        # Fallback to Docker version
        if ! docker image inspect quay.io/vektorlab/ctop:latest >/dev/null 2>&1; then
            echo -e "${C_YELLOW}Image 'quay.io/vektorlab/ctop:latest' not found locally.${C_NC}"
            echo -e "${C_YELLOW}Pulling from Docker Hub...${C_NC}"
            docker pull quay.io/vektorlab/ctop:latest
        fi

        echo -e "${C_YELLOW}Running ctop via Docker... (Press 'q' to quit)${C_NC}"
        docker run --rm -it \
            --name=ctop \
            --volume /var/run/docker.sock:/var/run/docker.sock:ro \
            quay.io/vektorlab/ctop:latest
    fi
}

# --- On-load message for utilities ---
if [ "$0" != "${BASH_SOURCE[0]}" ]; then
    echo -e "${C_GREEN}Docker utilities loaded.${C_NC} Available commands:"
    echo -e "  - ${C_YELLOW}docker-info${C_NC}: Show Docker status summary."
    echo -e "  - ${C_YELLOW}docker-prune${C_NC}: Aggressively prune all containers, networks, and build cache."
    echo -e "  - ${C_YELLOW}docker-shell <container>${C_NC}: Exec into a running container's shell."
    echo -e "  - ${C_YELLOW}docker-ctop${C_NC}: Launch ctop container monitor."
    echo -e "  - ${C_YELLOW}docker-update${C_NC}: Update Docker Engine packages via apt."
fi