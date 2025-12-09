# -----------------------------------------------------------------------------
# Docker Workstation Setup Script for Windows
# Description: This script automates the installation and configuration of a complete
#              Docker development environment using WSL 2.
# Version: 2.0
#
# Features:
#   - Self-elevates to Administrator privileges.
#   - Idempotent: Can be run multiple times safely.
#   - Enables required Windows features (WSL & Virtual Machine Platform).
#   - Updates WSL to the latest kernel and sets WSL 2 as default.
#   - Installs a default Linux distro (Ubuntu 22.04) if none exist.
#   - Installs Docker Desktop if not already present.
# -----------------------------------------------------------------------------

# --- 0. PREPARATION AND ADMINISTRATOR CHECK ---
Write-Host "--- Docker Workstation Setup ---" -ForegroundColor Yellow

# Self-elevate to Administrator
if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires Administrator privileges. Attempting to re-launch as Administrator..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Set execution policy to allow running scripts for the current process
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
$ErrorActionPreference = "Stop" # Exit on any error

# --- 1. ENABLE REQUIRED WINDOWS FEATURES ---
Write-Host "`n## 1. Checking and enabling Windows Features..." -ForegroundColor Cyan
$features = @("Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform")
$restartNeeded = $false

foreach ($feature in $features) {
    $featureState = (Get-WindowsOptionalFeature -Online -FeatureName $feature).State
    if ($featureState -ne 'Enabled') {
        Write-Host "Enabling feature: $feature..."
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
        Write-Host "✅ Feature '$feature' enabled." -ForegroundColor Green
        if ((Get-WindowsOptionalFeature -Online -FeatureName $feature).RestartNeeded) {
            $restartNeeded = $true
        }
    } else {
        Write-Host "✅ Feature '$feature' is already enabled." -ForegroundColor Green
    }
}

if ($restartNeeded) {
    Write-Host "`n🚨 A system restart is required to complete feature installation." -ForegroundColor Red
    Write-Host "   Please restart your computer and then run this script again." -ForegroundColor Red
    exit
}

# --- 2. UPDATE WSL AND SET DEFAULT TO VERSION 2 ---
Write-Host "`n## 2. Updating WSL kernel and setting default to WSL 2..." -ForegroundColor Cyan
try {
    Write-Host "Running WSL update..."
    wsl --update
    Write-Host "Setting WSL default version to 2..."
    wsl --set-default-version 2
    Write-Host "✅ WSL updated and default version set to 2." -ForegroundColor Green
}
catch {
    Write-Warning "Could not update WSL or set default version. Error: $($_.Exception.Message)"
}

# --- 3. INSTALL AND CONFIGURE A WSL LINUX DISTRO ---
Write-Host "`n## 3. Checking for and installing a WSL Linux distro..." -ForegroundColor Cyan
$defaultDistro = "Ubuntu-22.04"
# Check wsl --list --quiet output
$installedDistros = wsl --list --quiet
if ($installedDistros) {
    Write-Host "✅ Found existing WSL distro(s):" -ForegroundColor Green
    wsl --list
} else {
    Write-Host "No WSL distro found. Installing '$defaultDistro'..."
    wsl --install -d $defaultDistro --no-launch
    Write-Host "✅ '$defaultDistro' installed successfully." -ForegroundColor Green
}

# Verify the primary distro is running on WSL 2
$distroToVerify = if ($installedDistros) { $installedDistros.Split([Environment]::NewLine)[0].Trim() } else { $defaultDistro }
if ($distroToVerify) {
    Write-Host "Verifying '$distroToVerify' is running on WSL 2..."
    $distroVersion = (wsl --list --verbose | Where-Object { $_ -match $distroToVerify } | ForEach-Object { ($_.Split(' ',[StringSplitOptions]::RemoveEmptyEntries))[2] })
    if ($distroVersion -eq "2") {
        Write-Host "✅ '$distroToVerify' is correctly set to WSL version 2." -ForegroundColor Green
    } else {
        Write-Warning "'$distroToVerify' is on version $distroVersion. Attempting to convert to WSL 2..."
        wsl --set-version $distroToVerify 2
        Write-Host "✅ Conversion to WSL 2 complete." -ForegroundColor Green
    }
}

# --- 4. INSTALL DOCKER ENGINE IN WSL ---
Write-Host "`n## 4. Checking for and installing Docker Engine in WSL..." -ForegroundColor Cyan

# Check if Docker is already installed in the WSL distro
$dockerInstalled = try {
    # This command will produce output (and thus be 'true' in PS) if docker is found, or throw an error if not.
    if (wsl -d $distroToVerify -u root -- bash -c "command -v docker") { $true } else { $false }
} catch {
    $false
}

if ($dockerInstalled) {
    Write-Host "✅ Docker Engine is already installed in '$distroToVerify'." -ForegroundColor Green
} else {
    Write-Host "Docker Engine not found in '$distroToVerify'. Installing..."

    # This multi-line script will be executed inside WSL. It follows the official Docker installation guide.
    $installScript = @"
set -e
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
"@

    try {
        # Pipe the script into WSL to execute as root.
        $installScript | wsl -d $distroToVerify -u root -- bash
        Write-Host "✅ Docker Engine installed successfully in '$distroToVerify'." -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to install Docker Engine in WSL. Error: $($_.Exception.Message)"
        exit 1
    }
}

# --- 5. FINALIZING ---
Write-Host "`n## 5. Finalizing Setup..." -ForegroundColor Cyan

# Add current user to the 'docker' group within WSL for sudo-less access.
# This assumes the WSL username matches the Windows username ($env:USERNAME).
Write-Host "Adding user '$env:USERNAME' to the 'docker' group in '$distroToVerify'..."
try {
    # Check if group exists, create if not. Then add user.
    wsl -d $distroToVerify -u root -- bash -c "getent group docker >/dev/null || groupadd docker; usermod -aG docker $env:USERNAME"
    Write-Host "✅ User '$env:USERNAME' added to 'docker' group in WSL." -ForegroundColor Green
}
catch {
    # This might fail if the user doesn't exist in WSL yet.
    Write-Warning "Could not add user to docker group in WSL. You may need to create the user and run 'sudo usermod -aG docker \$USER' manually inside WSL. Error: $($_.Exception.Message)"
}

# Start Docker Service inside WSL
Write-Host "Starting Docker service in '$distroToVerify'..."
try {
    wsl -d $distroToVerify -u root -- bash -c "service docker status > /dev/null 2>&1 || service docker start"
    Start-Sleep -Seconds 3 # Give service a moment to start
    
    $dockerStatus = wsl -d $distroToVerify -u root -- bash -c "service docker status"
    if ($dockerStatus -like "*is running*") {
        Write-Host "✅ Docker service is running in '$distroToVerify'." -ForegroundColor Green
    } else {
        Write-Warning "Docker service may not have started correctly. Check with 'service docker status' inside WSL. Status: $dockerStatus"
    }
}
catch {
    Write-Error "❌ Could not start Docker service in WSL. Error: $($_.Exception.Message)"
}

Write-Host "`n🎉 **Docker on WSL setup complete!**" -ForegroundColor Green
Write-Host "   You can now run docker commands from within the '$distroToVerify' WSL terminal (after a logout/login)."
Write-Host "   To use Docker from Windows (e.g., in PowerShell or VS Code), you might need to configure a Docker context."
Write-Host "   IMPORTANT: A full logout/restart of your Windows session is required for group membership changes to take full effect inside WSL." -ForegroundColor Yellow
