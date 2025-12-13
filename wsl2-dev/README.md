# WSL2 Development Tools

This directory contains essential tools and utilities for managing and optimizing your WSL2 (Windows Subsystem for Linux 2) development environment.

## 📁 Directory Contents

| File | Description | Purpose |
|------|-------------|---------|
| [`install-dev-tools-wsl2.sh`](#install-dev-tools-wsl2sh) | Development environment setup script | Automated installation of development tools |
| [`install-docker-engine.sh`](#install-docker-enginesh) | Docker Engine & utilities setup script | Install Docker and provide management utilities |
| [`install-extra-tools.sh`](#install-extra-toolssh) | Extra tools installer | Install additional networking, monitoring, and utility tools |
| [`install-nvidia-container.sh`](#install-nvidia-containersh) | NVIDIA GPU & container setup script | Install CUDA toolkit and NVIDIA Container Toolkit |
| [`system-checkup.sh`](#system-checkupsh) | System diagnostic tool | Comprehensive health check and status reporting |
| [`speedtest-wsl2.sh`](#speedtest-wsl2sh) | Network speed testing tool | Internet connection performance testing |
| [`wsl2-docker-tweak.sh`](#wsl2-docker-tweaksh) | WSL2 auto-config optimizer | Automatically optimize .wslconfig for Docker workloads |
| [`wsl-dev-utils.sh`](#wsl-dev-utilssh) | WSL2 utility functions | Interactive commands for WSL2 management |
| [`Agent/`](#agent) | Agent installation and MCP setup | Scripts for installing opencode, mgrep, and configuring MCP servers |
| [`install-agent.sh`](#install-agentsh) | Agent installer | Install opencode and mgrep agents via pnpm/bun |

## 🛠️ Tool Documentation

### `install-dev-tools-wsl2.sh`

**Purpose**: Automated installation script for setting up a complete WSL2 development environment.

**Features**:
- ✅ System preparation and validation
- ✅ Package database updates
- ✅ Essential system packages installation
- ✅ Development tools setup (Git, Python, Node.js, etc.)
- ✅ Package manager configuration (pip, nvm)
- ✅ Git configuration with WSL2 optimizations
- ✅ Environment setup and PATH configuration
- ✅ Installation verification

**Networking Tools Included**:
- **Basic**: netcat, net-tools, ping, SSH, curl, wget
- **DNS**: dnsutils (dig, nslookup, host), traceroute, whois
- **Monitoring**: iftop, nload, bmon
- **HTTP**: httpie, siege
- **Utilities**: telnet, ftp, socat

**Usage**:
```bash
# Make executable and run
chmod +x install-dev-tools-wsl2.sh
./install-dev-tools-wsl2.sh
```

**What it installs**:
- Ubuntu system updates
- Essential networking and system utilities
- Programming languages (Python 3, Node.js)
- Development tools (Git, build tools, editors)
- Package managers and environment setup

### `system-checkup.sh`

**Purpose**: Comprehensive diagnostic tool that checks the health and status of your WSL2 development environment.

**Features**:
- ✅ WSL2 environment validation
- ✅ Internet connectivity testing
- ✅ System update status checking
- ✅ Package installation verification
- ✅ Development tool availability checking
- ✅ Network configuration assessment
- ✅ Container runtime status (Docker)

**Check Categories**:
- **System Environment**: WSL2 detection, connectivity, updates
- **Essential Packages**: Networking tools, SSL, system utilities
- **Development Tools**: Git, Python, Node.js, editors, shells
- **Package Managers**: pip, nvm, npm status
- **Configuration**: Git config, shell environment, PATH
- **Services**: Docker daemon, systemd status

**Usage**:
```bash
# Make executable and run
chmod +x system-checkup.sh
./system-checkup.sh
```

**Output Example**:
```
WSL2 System Checkup Report
Generated on: [date]
WSL2 Distro: Ubuntu 22.04.5 LTS

Basic Networking Tools:
✓ Netcat (netcat-openbsd)
✓ Network tools (net-tools)
...
```

### `speedtest-wsl2.sh`

**Purpose**: Network performance testing tool with visual progress indication.

**Features**:
- ✅ Automatic speedtest-cli installation
- ✅ Loading bar with progress indication
- ✅ Official Ookla speedtest with fallback to Python version
- ✅ Persistent `speedtest2` command creation
- ✅ Cross-session availability

**Installation Methods** (tries in order):
1. **Snap**: `sudo snap install speedtest` (official CLI)
2. **Pip**: `pip3 install speedtest-cli` (fallback)

**Usage**:
```bash
# Initial setup (installs and creates speedtest2 command)
chmod +x speedtest-wsl2.sh
./speedtest-wsl2.sh

# Subsequent usage (direct command)
speedtest2
speedtest2 --simple
speedtest2 --help
```

**Output Example**:
```
Testing connection [================] Done!

Retrieving speedtest.net configuration...
Testing from PT Mega Data Perkasa (103.162.16.173)...
...
Download: 15.78 Mbit/s
Upload: 7.08 Mbit/s
```

### `install-docker-engine.sh`

**Purpose**: Installs Docker Engine, NVIDIA Container Toolkit (if GPU detected), and provides utility functions for Docker management in WSL2.

**Features**:
- ✅ Docker Engine installation (CE, CLI, Compose, Buildx, Model plugin)
- ✅ NVIDIA GPU support detection and toolkit setup
- ✅ User group management for sudo-less Docker access
- ✅ ctop and lazydocker installation for monitoring
- ✅ Utility functions: docker-info, docker-prune, docker-shell, docker-ctop, docker-update

**Installation**:
```bash
# Install Docker and tools
sudo bash install-docker-engine.sh
```

**Utilities**:
```bash
# Load utilities (after install)
source install-docker-engine.sh

# Available commands
docker-info      # Show Docker status summary
docker-prune     # Aggressive cleanup of containers and images
docker-shell <container>  # Exec into running container
docker-ctop      # Launch ctop container monitor
docker-update    # Update Docker packages
```

**What it installs**:
- Docker Engine Community Edition
- Docker Compose, Buildx, and Model plugins
- NVIDIA Container Toolkit (if GPU present)
- ctop and lazydocker for monitoring
- Adds user to docker group

### `install-extra-tools.sh`

**Purpose**: Installs additional tools for WSL2, including networking, monitoring, and development extras.

**Tools Installed**:
- **dnsenum**: DNS enumeration tool for network analysis.
- **lazyvim**: Neovim-based IDE with LazyVim configuration.
- **lazydocker**: Terminal UI for Docker management.
- **speedtest-cli**: Command-line internet speed testing (merged from speedtest-wsl2.sh).

**Usage**:
```bash
# Install extra tools
sudo bash install-extra-tools.sh
```

**Post-Installation**:
- Restart shell or `source ~/.bashrc` for PATH updates.
- Use tools: `dnsenum`, `nvim` (for lazyvim), `lazydocker`, `speedtest2`.

### `wsl2-docker-tweak.sh`

**Purpose**: Optimizes or resets WSL2 configuration (.wslconfig) for Docker workloads with menu-driven options.

**Features**:
- **Menu Options**:
  - Optimize: Auto-detect RAM/CPU, set optimal limits (50% RAM, all cores)
  - Default: Restore to default WSL2 settings (fallback)
  - Enable Docker Experimental: Enable beta Docker features
- Detects host specs and Docker info
- Backs up existing .wslconfig to .wslconfig.backup
- Prompts for WSL2 restart to apply changes

**Requirements**:
- WSL2 installed
- Docker installed (optional, for better tuning)

**Usage**:
```bash
# Run tweak tool with menu
sudo bash wsl2-docker-tweak.sh
```

**Effects**:
- **Optimize**: Improves Docker performance with custom RAM/CPU limits.
- **Default**: Reverts to WSL2 defaults for stability.
- **Experimental**: Enables beta Docker features (may be unstable).

**Fallback**:
- To revert: Copy .wslconfig.backup to .wslconfig, then `wsl --shutdown` and restart WSL2.

### `wsl-dev-utils.sh`

**Purpose**: Interactive utility functions for WSL2 management and troubleshooting.

**Available Commands**:

#### System Information
```bash
wsl-info          # Comprehensive WSL2 system status
```

#### System Management
```bash
wsl-update        # Update WSL2 system and packages
wsl-clean         # Clean up unnecessary packages and files
wsl-gpu-check     # Check NVIDIA GPU availability
```

#### Drive & Storage
```bash
wsl-mount-windows # Mount Windows drives for access
```

#### Network Tools
```bash
wsl-network-info  # Comprehensive network information
wsl-dns-test [domain]    # DNS resolution testing
wsl-http-test <url>      # HTTP connectivity testing
wsl-fix-network   # Network troubleshooting and reset
```

**Usage**:
```bash
# Load utilities
source wsl-dev-utils.sh

# Use any command
wsl-info
wsl-network-info
wsl-dns-test google.com
```

### `Agent/`

**Purpose**: Scripts and configs for installing AI agents and setting up MCP servers for orchestration.

**Contents**:
- `install-agent.sh`: Installs opencode and mgrep, configures mgrep for opencode, and sets up MCP servers.
- `sample-mcp-config.jsonc`: Sample config for MCP servers in opencode.

**Features**:
- ✅ Detects available package manager (pnpm > bun > npm)
- ✅ Installs opencode and mgrep globally
- ✅ Configures mgrep for opencode (login and install-opencode)
- ✅ Sets up MCP servers in opencode config

**Usage**:
```bash
cd Agent
./install-agent.sh
```

**What it sets up**:
- opencode: AI-assisted development agent
- mgrep: Grep-based plugin/agent
- MCP servers: Test, Context7, Grep by Vercel

## 🔄 Workflow Integration

### Typical Development Setup
1. **Initial Setup**: Run `install-dev-tools-wsl2.sh` for complete environment setup
2. **Docker Setup**: Run `sudo bash install-docker-engine.sh` for Docker installation
3. **WSL2 Optimization**: Run `sudo bash wsl2-docker-tweak.sh` to auto-configure RAM/CPU for Docker
4. **NVIDIA GPU (Optional)**: If GPU present, run `sudo bash install-nvidia-container.sh` for CUDA/container support
5. **Extra Tools**: Run `sudo bash install-extra-tools.sh` for additional tools
6. **Health Check**: Use `system-checkup.sh` to verify installation
7. **Network Testing**: Run `speedtest-wsl2.sh` to check connectivity
8. **Ongoing Management**: Source `wsl-dev-utils.sh`, `install-docker-engine.sh`, and `install-extra-tools.sh` for utility functions

### Maintenance Routine
```bash
# Weekly system check
./system-checkup.sh

# Network performance monitoring
speedtest2 --simple

# System cleanup
source wsl-dev-utils.sh
wsl-clean

# Docker maintenance
source install-docker-engine.sh
docker-update  # Update Docker packages
docker-prune   # Clean up containers/images

# NVIDIA maintenance (if installed)
sudo apt update && sudo apt install --only-upgrade nvidia-cuda-toolkit nvidia-container-toolkit
# Test GPU: docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

## 📋 Prerequisites

- **WSL2 Environment**: Ubuntu 22.04+ recommended
- **Internet Connection**: Required for package downloads and speed testing
- **Sudo Access**: Required for package installation
- **Windows Integration**: For drive mounting and GPU features

## 🔧 Troubleshooting

### Common Issues

**Permission Denied**:
```bash
chmod +x *.sh  # Make all scripts executable
```

**Network Issues**:
```bash
source wsl-dev-utils.sh
wsl-fix-network
```

**Package Installation Failures**:
```bash
sudo apt update
sudo apt install -f  # Fix broken packages
```

**Speedtest Issues**:
- Check internet connectivity
- Try `speedtest2 --list` to see available servers
- Use `speedtest2 --server [server_id]` for specific server

**NVIDIA GPU Issues**:
- Ensure Windows NVIDIA drivers are installed (latest from NVIDIA site)
- Run `nvidia-smi` manually to verify GPU access
- If detection fails, check WSL2 integration: `wsl --update`
- For container issues: `docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi`

**.wslconfig Issues**:
- Use `wsl2-docker-tweak.sh` for automatic optimization
- To revert: `cp /mnt/c/Users/$USER/.wslconfig.backup /mnt/c/Users/$USER/.wslconfig`
- After changes: `wsl --shutdown` then restart WSL2

### Getting Help

- Run `system-checkup.sh` for diagnostic information
- Use `wsl-info` for system status
- Check `/var/log/apt/history.log` for installation issues

## 📈 Performance Optimization

- **VHD Size**: Keep under 256GB for better performance
- **Memory**: Use `wsl2-docker-tweak.sh` to auto-configure RAM limits in `.wslconfig`
- **CPU**: Auto-set processor limits for Docker parallelism
- **Network**: Use `wsl-fix-network` for connectivity issues
- **GPU**: For NVIDIA GPUs, use `install-nvidia-container.sh` for CUDA workloads
- **Updates**: Regular `wsl-update` for security and performance

## 🤝 Contributing

To add new tools or utilities:
1. Follow the existing naming conventions
2. Add comprehensive documentation
3. Include error handling and user feedback
4. Update this README.md

## 📄 License

These tools are part of the Windows Dev Environment setup and follow the same licensing terms.