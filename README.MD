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

## 🏗️ Architecture: The "Holy Trinity"
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

*   **`.\Install-FullStackTools.ps1`**: Installs core tools (Git, Python, Node.js, VS Code, Multipass) via Winget.
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

## 📄 Documentation
*   [Dashboard Design Spec](./docs/dashboard-spec.md)
*   [Build with Dev Container](./docs/build-with-devcontainer.md)
