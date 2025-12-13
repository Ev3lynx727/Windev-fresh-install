# Windows Dev Setup & Docker Workstation

This repository contains automation scripts to set up a professional development environment on Windows 10/11.

## 🛑 Prerequisites (Before You Start)

### 1. BIOS / UEFI Settings
**CRITICAL**: You must enable Hardware Virtualization in your computer's BIOS.
*   **Intel**: Look for `Intel VT-x`, `Virtualization Technology`.
*   **AMD**: Look for `SVM Mode`, `AMD-V`.
*   *Why?* Required for WSL2, Hyper-V, and Docker.

### 2. Operating System
*   **Recommended**: Windows 10/11 **Professional** or **Enterprise**.
*   **Minimum**: Windows 10/11 Home (Docker will work, but Hyper-V features are limited).

### 3. NVIDIA GPU Setup (For GPU-accelerated development)
**OPTIONAL**: Only required if you have an NVIDIA GPU and plan to use GPU-accelerated containers, machine learning, or CUDA development.

#### Why NVIDIA Setup?
- Enables GPU-accelerated Docker containers in WSL2
- Required for TensorFlow, PyTorch, and other ML frameworks
- Supports CUDA development and GPU computing workloads

#### Step 3.1: Install NVIDIA Graphics Drivers
```powershell
# Download and install latest NVIDIA drivers:
# Visit: https://www.nvidia.com/Download/index.aspx
# Or use Windows Update (recommended for RTX series)

# After installation, restart your system
```

#### Step 3.2: Verify GPU Detection
```powershell
# Open PowerShell as Administrator and run:
nvidia-smi

# Expected output should show:
# - GPU model (e.g., NVIDIA GeForce RTX 2050)
# - Driver version (e.g., 591.44)
# - CUDA version (e.g., 13.1)
```

#### Step 3.3: Optional - Install CUDA Toolkit (Windows)
```powershell
# SKIP THIS STEP for most users - CUDA will be installed in WSL2
# Only install on Windows if you plan to develop CUDA applications natively

# Download from: https://developer.nvidia.com/cuda-downloads
```

#### Post-Installation Verification
- ✅ `nvidia-smi` works in Windows PowerShell
- ✅ GPU appears in Task Manager > Performance tab
- ✅ WSL2 can access GPU (verified during Docker setup)

#### Troubleshooting
- **"nvidia-smi not found"**: Reinstall drivers, restart system
- **WSL2 GPU not accessible**: Update WSL2 kernel, check Windows drivers
- **Driver conflicts**: Use DDU (Display Driver Uninstaller) for clean install

**Note**: The WSL2 setup scripts will automatically detect NVIDIA GPUs and complete the container toolkit installation in WSL2.

## 🏗️ Architecture: "Trinity Nuke"
This setup consolidates 3 powerful VM strategies onto a single Local Machine:

| Environment | Tech Stack | Role | Best For |
| :--- | :--- | :--- | :--- |
| **1. WSL2** | Hyper-V (Utility VM) | **The Daily Driver** | Coding, Git, Docker, VS Code integration. |
| **2. Multipass** | Hyper-V (Ubuntu VM) | **The Instant Server** | Testing deployments, isolated experiments, "Cloud-like" feel. |
| **3. MS Dev VM** | Hyper-V (Full OS) | **The Clean Slate** | Testing installers, "Nuking" the OS, SysAdmin validation. |

**Concept**: You develop in **WSL2**, test deployments in **Multipass**, and verify system-level installers in **MS Dev VM**.

## 🚀 Getting Started

### 1. Bypass Execution Policy
To run these scripts, you must allow PowerShell to execute local scripts. Open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### 2. Run the Scripts
Navigate to this folder and run the desired setup script:

*   **`.\Install-fullstack-dev.ps1`**: Installs core tools (Git, Python, Node.js, VS Code, Multipass) via Winget.
*   **`.\install-Dockerstation.ps1`**: Sets up WSL2, Ubuntu, Docker Engine, and NVIDIA Drivers (if GPU detected).

### 3. Quick VM (Multipass)
After running the Full Stack Installer, you can launch a fresh Ubuntu VM instantly:
```powershell
# Start a new VM
multipass launch --name dev-vm

# Enter the VM
multipass shell dev-vm

# Stop/Delete
multipass stop dev-vm
multipass delete dev-vm --purge
```

## VS Code Extensions Management

After installing VS Code, manage extensions easily:

- **Windows**: Use `w11-dev/VScode/` scripts for native PowerShell management.
- **WSL2**: Use `wsl2-dev/VScode/` scripts for cross-platform handling.
- Shared `extensions.json` allows backing up on one platform and installing on another.

## 📄 Documentation
*   [Deployment Guide](./DEPLOYMENT.md) - Hybrid workflow for fresh installs, repo locking, alias setup, and update automation
*   [Current Hardware](./docs/current-hw.md) - Baseline system configuration and upgrade roadmap
*   [Hardware Requirements](./docs/hardware-requirement.md) - Complete Trinity Nuke hardware specifications
*   [VS Code Extensions Catalog](./docs/vscode-extensions-catalog.md) - Current VS Code extension inventory and recommendations
*   [Dashboard Design Spec](./docs/dashboard-spec.md)
*   [Build with Dev Container](./docs/build-with-devcontainer.md)
