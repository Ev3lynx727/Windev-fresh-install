# Windows Dev Environment Overview

## Current System Status

### WSL2 Environment
- **Distro**: Ubuntu 22.04.5 LTS (Jammy Jellyfish)
- **Kernel**: Linux 6.6.87.2-microsoft-standard-WSL2
- **Architecture**: x86_64
- **Memory**: 3.7GB total, 1.2GB used, 2.0GB free
- **Storage**: 1007GB VHD size, 5.2GB used, 951GB available

### Installed Tools
- **Docker**: v29.1.2 ✅
- **Development Tools**: Python3, Node.js, npm, Git, build-essential, cmake, vim, tmux, zsh ✅
- **Networking Tools**: Complete suite including DNS (dig, nslookup, host), monitoring (iftop, nload, bmon), HTTP (httpie, siege), utilities (socat, telnet, ftp), and basic tools (curl, wget, openssh, netcat) ✅
- **WSL Features**: systemd enabled ✅
- **WSL2 Utilities**: Comprehensive management functions (wsl-info, wsl-network-info, wsl-dns-test, wsl-http-test, etc.) ✅

### Volume Mounting Status
- **C:\ drive**: Auto-mounted at `/mnt/c` (9p/drvfs)
- **Other drives**: D:, E:, F: not auto-mounted
- **WSL drivers**: Mounted read-only at `/usr/lib/wsl/drivers`
- **WSLG**: Active for GUI support

### VHD Configuration
- **Size**: 1TB (oversized for development)
- **Filesystem**: ext4 on /dev/sdd
- **WSL Config**: Minimal (/etc/wsl.conf with systemd=true only)

## WSL2 Container Architecture

WSL2 is fundamentally built around container technology, providing native Docker performance and seamless container integration:

### Key Container Benefits
- **Native Docker Support**: Docker runs directly on the WSL2 kernel without virtualization overhead
- **Container-Native Filesystem**: Uses ext4 with efficient copy-on-write operations
- **Shared Kernel**: Containers and WSL2 share the same Linux kernel for optimal performance
- **Resource Efficiency**: Memory and CPU shared efficiently between WSL2 and containers

### Container-Focused Optimizations
Our WSL2 optimization plan leverages this container architecture:
- **VHD Size Optimization**: Affects both WSL2 filesystem and Docker container storage
- **Drive Mounting**: Enhances container volume mounting capabilities
- **Memory/Swap Tuning**: Impacts both WSL2 and container performance
- **Network Configuration**: Critical for container connectivity and service discovery

### Development Workflow Advantages
- **Unified Environment**: Development tools and containers run in the same optimized space
- **Fast Container Startup**: No virtualization layer between WSL2 and containers
- **Efficient Resource Sharing**: Memory and storage optimized for both development and container workloads

## Networking Capabilities

The WSL2 development environment includes comprehensive networking tools for development and troubleshooting:

### Network Analysis & DNS
- **dnsutils**: dig, nslookup, host commands for DNS troubleshooting
- **traceroute**: Network path analysis and latency testing
- **whois**: Domain and IP information lookup

### Network Monitoring
- **iftop**: Real-time bandwidth monitoring by connection
- **nload**: Network load visualization and statistics
- **bmon**: Bandwidth monitoring with graphical interface

### HTTP Tools & Testing
- **httpie**: Modern, user-friendly HTTP client
- **siege**: HTTP load testing and benchmarking
- **curl & wget**: Standard HTTP download and testing tools

### Network Utilities
- **socat**: Advanced networking relay tool (enhanced netcat)
- **telnet**: Protocol testing and connectivity verification
- **ftp**: File transfer protocol client
- **openssh**: Secure shell connectivity

### WSL2 Network Utilities
- `wsl-network-info`: Comprehensive network status display
- `wsl-dns-test [domain]`: DNS resolution testing
- `wsl-http-test <url>`: HTTP connectivity testing
- `wsl-fix-network`: Network troubleshooting and reset

## Repository Structure

```
Windev-fresh-install/
├── containerd/                # Containerd and Docker utilities
│   ├── agent.md
│   └── readme.md
├── docs/                      # Documentation
│   ├── build-with-devcontainer.md
│   ├── current-hw.md
│   ├── dashboard-spec.md
│   └── hardware-requirement.md
├── ohmyposh-setup/            # Terminal customization
│   ├── find_omp.ps1
│   └── setup_git_bash_omp.sh
├── w11-dev/                   # Windows 11 development tools
│   ├── Install-fullstack-dev.ps1  # Full-stack development setup
│   ├── install-Dockerstation.ps1  # Docker station setup
│   ├── find_omp.ps1
│   └── VScode/                # VS Code extensions management
│       ├── README.md
│       ├── backup-extensions.ps1
│       ├── install-extensions.ps1
│       └── extensions.json
├── wsl2-dev/                  # WSL2 development tools
│   ├── README.md              # Comprehensive tool documentation
│   ├── agent.md
│   ├── install-dev-tools-wsl2.sh  # Development environment setup
│   ├── system-checkup.sh      # System diagnostic tool
│   ├── speedtest-wsl2.sh      # Network speed testing
│   ├── wsl-dev-utils.sh       # WSL2 helper functions
│   ├── wsl2-dev-utils.sh
│   ├── wsl2-docker-tweak.sh
│   ├── install-docker-engine.sh
│   ├── install-extra-tools.sh
│   ├── install-nvidia-container.sh
│   └── VScode/                # VS Code extensions management
│       ├── README.md
│       ├── backup-extensions.sh
│       ├── install-extensions.sh
│       └── extensions.json
├── CHANGELOG.md               # Project changelog
├── LICENSE
├── Overview.md                # Project overview
└── README.MD                  # Main project documentation
```

## 📄 Documentation
*   [Deployment Guide](./DEPLOYMENT.md) - Hybrid workflow for fresh installs and repo locking
*   [Current Hardware](./docs/current-hw.md) - Baseline system configuration and upgrade roadmap
*   [Hardware Requirements](./docs/hardware-requirement.md) - Complete Trinity Nuke hardware specifications
*   [Dashboard Design Spec](./docs/dashboard-spec.md)
*   [Build with Dev Container](./docs/build-with-devcontainer.md)

## VS Code Extensions Management

After installing VS Code via `Install-fullstack-dev.ps1`, manage extensions easily:

- **Windows**: Use `w11-dev/VScode/` scripts (`backup-extensions.ps1`, `install-extensions.ps1`) for native PowerShell management.
- **WSL2**: Use `wsl2-dev/VScode/` scripts (`backup-extensions.sh`, `install-extensions.sh`) for cross-platform handling.
- Shared `extensions.json` allows backing up on one platform and installing on another.

## Configuration Issues Identified

### Volume Mounting Problems
1. **Limited drive access**: Only C: drive auto-mounted
2. **Missing metadata support**: Poor Windows file permission handling
3. **No custom mount options**: Default permissions may cause issues

### VHD Configuration Issues
1. **Oversized VHD**: 1TB wastes space and complicates backups
2. **No size limits**: Can grow uncontrollably
3. **Missing optimization**: No memory or swap tuning

## Todo Plan: WSL2 Optimization

### Completed Tasks ✅
- [x] Analyze current WSL2 volume mounting and VHD configuration
- [x] Add comprehensive networking tools (DNS, monitoring, HTTP, utilities)
- [x] Create WSL2 utility functions (wsl-network-info, wsl-dns-test, wsl-http-test)
- [x] Implement system checkup tool with networking diagnostics
- [x] Add network speed testing with visual progress (speedtest2 command)
- [x] Create comprehensive documentation (wsl2-dev/README.md)

### High Priority Tasks
- [ ] Research optimal .wslconfig settings for VHD size limits, memory allocation, and swap configuration
- [ ] Research /etc/wsl.conf options for drive mounting, metadata support, and automount configuration
- [ ] Create Windows-side .wslconfig file with optimized VHD size (256-512GB), memory limits, and swap settings
- [ ] Update /etc/wsl.conf with metadata support, permission masks, and additional drive automount settings

### Medium Priority Tasks
- [ ] Create script to automatically mount additional Windows drives (D:, E:, F:) with proper permissions
- [ ] Plan backup strategy for current WSL distro before making configuration changes
- [ ] Plan testing procedure to verify volume mounting works correctly and VHD size is optimized
- [ ] Plan rollback procedure in case configuration changes cause issues

## Recent Developments

### Enhanced Networking Capabilities
- **DNS Tools**: dig, nslookup, host, traceroute, whois for comprehensive network analysis
- **Monitoring Tools**: iftop, nload, bmon for real-time bandwidth and network monitoring
- **HTTP Tools**: httpie (modern HTTP client), siege (load testing), with curl/wget as standards
- **Network Utilities**: socat (advanced netcat), telnet, ftp for connectivity testing
- **WSL2 Network Functions**: Dedicated utilities for network diagnostics and troubleshooting

### Development Tools Suite
- **Automated Installation**: Complete development environment setup script
- **System Diagnostics**: Comprehensive health checking and status reporting
- **Network Testing**: Speed testing with visual progress and persistent commands
- **Management Utilities**: Interactive functions for WSL2 system management

### Documentation & Usability
- **Comprehensive README**: Detailed documentation for all WSL2 development tools
- **Workflow Integration**: Clear guidance on tool usage and maintenance routines
- **Troubleshooting**: Built-in help and diagnostic capabilities

## Next Steps

1. **Install Networking Tools**: Run `wsl2-dev/install-dev-tools-wsl2.sh` to install all new networking packages
2. **Test New Capabilities**: Use `wsl2-dev/system-checkup.sh` to verify installations and `speedtest2` for network testing
3. **Complete WSL Configuration Research**: Research optimal .wslconfig and /etc/wsl.conf settings
4. **Implement VHD Optimizations**: Create Windows-side configuration for better performance
5. **Test and Validate**: Comprehensive testing of all optimizations before production use

## Tool Capabilities Overview

### WSL2 Development Suite
- **Installation**: Automated setup of complete development environment
- **Diagnostics**: System health checking and network analysis
- **Performance**: Network speed testing and system monitoring
- **Management**: Interactive utilities for ongoing maintenance

### Networking Excellence
- **DNS Analysis**: Professional-grade DNS troubleshooting tools
- **Traffic Monitoring**: Real-time bandwidth and connection monitoring
- **HTTP Testing**: Modern and traditional HTTP client tools
- **Connectivity**: Comprehensive network utility toolkit

### Container Integration
- **Native Docker**: Seamless container development experience
- **Resource Optimization**: Efficient memory and storage sharing
- **Network Services**: Container networking and service discovery
- **Development Workflow**: Unified container and development environment

## Notes

- **Current Status**: Networking tools added, comprehensive documentation created, ready for installation
- **Installation Required**: Run `wsl2-dev/install-dev-tools-wsl2.sh` to install new networking packages
- **Testing Available**: Use `wsl2-dev/system-checkup.sh` and `speedtest2` for verification
- **Future Optimizations**: VHD size and drive mounting improvements planned
- **Backup Recommended**: Create WSL distro backup before major configuration changes
- **Configuration Changes**: Require WSL restart to take effect