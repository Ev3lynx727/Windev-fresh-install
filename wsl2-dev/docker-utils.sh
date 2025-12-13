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
    
    # Check login status
    DOCKER_USER=$(docker system info 2>/dev/null | grep -E '^\s*Username:' | awk '{print $2}')
    if [ -n "$DOCKER_USER" ]; then
        echo -e "Docker Hub User:   ${C_GREEN}$DOCKER_USER${C_NC}"
    else
        echo -e "Docker Hub User:   ${C_RED}Not Logged In${C_NC} (Use 'docker login')"
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
# docker-portainer: Launches Portainer CE for web-based management.
# ------------------------------------------------------------------------------
docker-portainer() {
    echo -e "${C_BLUE}--- Starting Portainer ---${C_NC}"
    
    if [ "$(docker ps -q -f name=portainer)" ]; then
         echo -e "${C_GREEN}Portainer is already running.${C_NC}"
         echo "Access it at: https://localhost:9443"
         return 0
    fi

    if [ "$(docker ps -aq -f name=portainer)" ]; then
        echo -e "${C_YELLOW}Starting existing Portainer container...${C_NC}"
        docker start portainer
    else
        # Check if image exists locally
        if ! docker image inspect portainer/portainer-ce:latest >/dev/null 2>&1; then
            echo -e "${C_YELLOW}Image 'portainer/portainer-ce:latest' not found locally.${C_NC}"
            echo -e "${C_YELLOW}Pulling from Docker Hub...${C_NC}"
            docker pull portainer/portainer-ce:latest
        fi

        echo -e "${C_YELLOW}Creating and starting new Portainer container...${C_NC}"
        docker run -d -p 9000:9000 -p 9443:9443 --name portainer \
            --restart=always \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v portainer_data:/data \
            portainer/portainer-ce:latest
    fi
    
    echo -e "\n${C_GREEN}✅ Portainer started.${C_NC}"
    echo -e "Dashboard: ${C_BLUE}https://localhost:9443${C_NC}"
}

# ------------------------------------------------------------------------------
# docker-ctop: Launches ctop for terminal-based container monitoring.
# ------------------------------------------------------------------------------
docker-ctop() {
    echo -e "${C_BLUE}--- Starting ctop ---${C_NC}"

    # Check if image exists locally
    # Note: quay.io requires TLS 1.2+ (enforced by Docker client)
    if ! docker image inspect quay.io/vektorlab/ctop:latest >/dev/null 2>&1; then
        echo -e "${C_YELLOW}Image 'quay.io/vektorlab/ctop:latest' not found locally.${C_NC}"
        echo -e "${C_YELLOW}Pulling from Docker Hub...${C_NC}"
        docker pull quay.io/vektorlab/ctop:latest
    fi

    echo -e "${C_YELLOW}Running ctop... (Press 'q' to quit)${C_NC}"
    docker run --rm -it \
        --name=ctop \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        quay.io/vektorlab/ctop:latest
}

# --- On-load message ---

echo -e "${C_GREEN}Docker utilities loaded.${C_NC} Available commands:"
echo -e "  - ${C_YELLOW}docker-info${C_NC}: Show Docker status summary."
echo -e "  - ${C_YELLOW}docker-prune${C_NC}: Aggressively prune all containers, networks, and build cache."
echo -e "  - ${C_YELLOW}docker-shell <container>${C_NC}: Exec into a running container's shell."
echo -e "  - ${C_YELLOW}docker-portainer${C_NC}: Launch Portainer management dashboard."
echo -e "  - ${C_YELLOW}docker-ctop${C_NC}: Launch ctop container monitor."
echo -e "  - ${C_YELLOW}docker-update${C_NC}: Update Docker Engine packages via apt."