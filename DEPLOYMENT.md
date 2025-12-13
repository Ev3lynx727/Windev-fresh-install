# Hybrid Deployment Workflow for Fresh Installs

This guide outlines the hybrid workflow for deploying the Windev-fresh-install repo on a fresh WSL2 system. It combines user-level setup with root-level system fixes, followed by repo cloning to root and locking for security.

## Overview

The hybrid approach ensures safe, phased deployment:
- **User Phase**: Clone repo and run user-level scripts (e.g., dev tools, agents).
- **Root Phase**: Switch to root for system-level scripts (e.g., Docker, NVIDIA).
- **Clone to Root**: Copy repo to root for restricted access.
- **Lock Repo**: Secure the repo to prevent unauthorized changes.

This is ideal for fresh WSL2 installs or fixing dev systems in restricted environments.

## Prerequisites

- WSL2 with Ubuntu installed.
- User account with sudo access.
- Internet connection for cloning and installs.
- Basic familiarity with terminal commands.

## Workflow Diagram

```
Fresh WSL2 System
       |
       v
   Clone as User
   (git clone <repo> ~/windev-setup)
       |
       v
   User Phase
   - Run user scripts (install-dev-tools-wsl2.sh, Agent/install-agent.sh, etc.)
   - No sudo needed for most
       |
       v
   Root Phase
   - sudo su
   - Run system scripts (install-docker-engine.sh, install-nvidia-container.sh)
   - Requires sudo/root for packages
       |
       v
   Clone to Root
   - sudo cp -r ~/windev-setup /root/windev-setup
   - Adjust paths if needed
       |
       v
   Lock Repo
   - chattr +i /root/windev-setup (immutable)
   - chmod 755 /root/windev-setup (restrict access)
       |
       v
   Set Up Aliases
   - Run setup-aliases.sh for auto-completion
       |
       v
   Set Up Updates
   - Configure cron for daily pulls
       |
       v
   Deployment Complete
   (Repo secured, aliases ready, auto-updates enabled)
```

## Step-by-Step Guide

### 1. Clone as User
```bash
git clone <repo-url> ~/windev-setup
cd ~/windev-setup
```

### 2. User Phase
Run scripts that don't require root:
```bash
./wsl2-dev/install-dev-tools-wsl2.sh
./wsl2-dev/Agent/install-agent.sh
# Run other user scripts as needed
```

### 3. Root Phase
Switch to root and run system scripts:
```bash
sudo su
cd /home/<user>/windev-setup  # Adjust path
./wsl2-dev/install-docker-engine.sh
./wsl2-dev/install-nvidia-container.sh
# Exit root: exit
```

### 4. Clone to Root
Copy repo to root location:
```bash
sudo cp -r ~/windev-setup /root/windev-setup
```

### 5. Lock Repo
Secure the root copy:
```bash
sudo chattr +i /root/windev-setup  # Make immutable
sudo chmod 755 /root/windev-setup  # Read/execute for root, read for others
```

### 6. Set Up Aliases
Run the auto-setup script for aliases:
```bash
./setup-aliases.sh
```
This adds `opendev-update` and `Opendev-checkup` to both `~/.bashrc` and `/root/.bashrc`. It also detects and adds optional aliases for oh-my-posh (`omp`) and oh-my-zsh (`zshrc`) if installed.

### 7. Set Up Update Mechanism
Configure cron for daily pulls and aliases for easy execution.

#### Cron Setup (as root)
```bash
sudo crontab -e
# Add this line for daily updates at 2 AM:
0 2 * * * /root/windev-setup/opendev-update.sh
```

#### Alias Setup
Add to both user and root `.bashrc`:
```bash
# In ~/.bashrc (user)
echo "alias opendev-update='bash /root/windev-setup/opendev-update.sh'" >> ~/.bashrc

# In /root/.bashrc (root)
sudo sh -c 'echo "alias opendev-update=\"bash /root/windev-setup/opendev-update.sh\"" >> /root/.bashrc'
```

Reload bashrc: `source ~/.bashrc` (user) or `sudo su -c 'source /root/.bashrc'` (root).

Now you can run `opendev-update` manually or let cron handle daily pulls.

## Script Modifications

- Scripts may need `--root` flags for root-mode paths (e.g., config in `/root/.config`).
- If paths conflict, update scripts to detect root vs user execution.

## Troubleshooting

- **Permissions Denied**: Ensure sudo for root phase.
- **Path Issues**: Use absolute paths; test scripts in both contexts.
- **Unlock Repo**: If needed, `sudo chattr -i /root/windev-setup` to edit.
- **WSL2 Mounts**: Ensure no Windows interference with `/mnt/c`.

## Security Notes

- Locking prevents accidental changes in restricted systems.
- Root access is minimized to necessary phases.
- Backup repo before locking.

For detailed script usage, see `wsl2-dev/README.md` and `Overview.md`.