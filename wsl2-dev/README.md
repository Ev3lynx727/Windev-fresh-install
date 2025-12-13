# WSL2 Development Tools

This directory contains essential tools and utilities for managing and optimizing your WSL2 (Windows Subsystem for Linux 2) development environment.

## 📁 Directory Contents

| File | Description | Purpose |
|------|-------------|---------|
| [`install-dev-tools-wsl2.sh`](#install-dev-tools-wsl2sh) | Development environment setup script | Automated installation of development tools |
| [`system-checkup.sh`](#system-checkupsh) | System diagnostic tool | Comprehensive health check and status reporting |
| [`speedtest-wsl2.sh`](#speedtest-wsl2sh) | Network speed testing tool | Internet connection performance testing |
| [`wsl-dev-utils.sh`](#wsl-dev-utilssh) | WSL2 utility functions | Interactive commands for WSL2 management |

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

## 🔄 Workflow Integration

### Typical Development Setup
1. **Initial Setup**: Run `install-dev-tools-wsl2.sh` for complete environment setup
2. **Health Check**: Use `system-checkup.sh` to verify installation
3. **Network Testing**: Run `speedtest-wsl2.sh` to check connectivity
4. **Ongoing Management**: Source `wsl-dev-utils.sh` for utility functions

### Maintenance Routine
```bash
# Weekly system check
./system-checkup.sh

# Network performance monitoring
speedtest2 --simple

# System cleanup
source wsl-dev-utils.sh
wsl-clean
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

### Getting Help

- Run `system-checkup.sh` for diagnostic information
- Use `wsl-info` for system status
- Check `/var/log/apt/history.log` for installation issues

## 📈 Performance Optimization

- **VHD Size**: Keep under 256GB for better performance
- **Memory**: Configure WSL2 memory limits in `.wslconfig`
- **Network**: Use `wsl-fix-network` for connectivity issues
- **Updates**: Regular `wsl-update` for security and performance

## 🤝 Contributing

To add new tools or utilities:
1. Follow the existing naming conventions
2. Add comprehensive documentation
3. Include error handling and user feedback
4. Update this README.md

## 📄 License

These tools are part of the Windows Dev Environment setup and follow the same licensing terms.