# Docker Utilities for WSL2

This file contains a collection of utility functions to simplify common Docker management tasks within a WSL2 environment. These scripts are intended to be run directly from your Linux distribution inside WSL2.

## How to Use

1.  **Copy the Script:** Inside your WSL2 terminal, create a new file named `docker-utils.sh` in your home directory (`~/`). Copy the bash script from the section below and paste it into this new file.

2.  **Make it Executable:** In your WSL2 terminal, run the following command to make the script executable:
    ```bash
    chmod +x ~/docker-utils.sh
    ```

3.  **Source it in Your Shell Profile:** To make these utility functions available every time you start a new terminal session, add the following line to your `~/.bashrc` (for Bash) or `~/.zshrc` (for Zsh) file:
    ```bash
    source ~/docker-utils.sh
    ```

4.  **Reload Your Shell:** Apply the changes by either restarting your terminal or by running `source ~/.bashrc` (or `source ~/.zshrc`).

5.  **Run the Utility Commands:** You can now use the functions directly from your terminal.

---

## Utility Script (`docker-utils.sh`)

```bash
#!/bin/bash

# ==============================================================================
# Docker Utility Functions for WSL2
#
# Description: A collection of helper functions to manage Docker in WSL2.
# To use, save this script and source it in your .bashrc or .zshrc:
#   echo "source ~\/docker-utils.sh" >> ~\/.bashrc
#   source ~\/.bashrc
# ==============================================================================

# --- Color Definitions for better readability ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# docker-info: Displays a high-level summary of the Docker environment.
# ------------------------------------------------------------------------------
docker-info() {
    echo -e "${C_BLUE}--- Docker System Info ---${C_NC}"
    
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

# --- On-load message ---

echo -e "${C_GREEN}Docker utilities loaded.${C_NC} Available commands:"
echo -e "  - ${C_YELLOW}docker-info${C_NC}: Show Docker status summary."
echo -e "  - ${C_YELLOW}docker-prune${C_NC}: Aggressively prune all containers, networks, and build cache."
echo -e "  - ${C_YELLOW}docker-shell <container>${C_NC}: Exec into a running container's shell."
echo -e "  - ${C_YELLOW}docker-update${C_NC}: Update Docker Engine packages via apt."

```