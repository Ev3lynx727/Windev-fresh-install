# Requires elevated permissions (Run as Administrator)
# Set execution policy to allow running scripts (scoped to the current process)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# --- 1. Enable Required Windows Features ---
Write-Host "## 1. Enabling Windows Features: WSL and Virtual Machine Platform..." -ForegroundColor Cyan

# Enable Windows Subsystem for Linux (WSL)
try {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart -ErrorAction Stop
    Write-Host "✅ Windows Subsystem for Linux (WSL) feature enabled." -ForegroundColor Green
}
catch {
    Write-Host "⚠️ WSL feature might already be enabled or an error occurred: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Enable Virtual Machine Platform (Required for WSL 2)
try {
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart -ErrorAction Stop
    Write-Host "✅ Virtual Machine Platform feature enabled." -ForegroundColor Green
}
catch {
    Write-Host "⚠️ Virtual Machine Platform feature might already be enabled or an error occurred: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check if a restart is needed
$restartNeeded = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -ExpandProperty RestartNeeded
if (-not $restartNeeded) {
    $restartNeeded = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -ExpandProperty RestartNeeded
}

if ($restartNeeded -eq $true) {
    Write-Host "`n🚨 Configuration requires a system restart to complete feature installation." -ForegroundColor Red
    Write-Host "   Run the script again after your computer restarts." -ForegroundColor Red
    # You can uncomment the line below to automatically restart, but be careful!
    # Restart-Computer -Force -Wait
    exit
}

Write-Host "Features enabled successfully. No immediate restart needed (or system was already restarted)." -ForegroundColor Green
Start-Sleep -Seconds 5

# --- 2. Install WSL Linux Kernel Update and Set Default Version ---
Write-Host "`n## 2. Installing WSL Linux Kernel Update and setting default to WSL 2..." -ForegroundColor Cyan

# Download the latest WSL 2 Linux kernel update package
$wslKernelInstallerUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$wslKernelInstallerPath = "$env:TEMP\wsl_update_x64.msi"
Write-Host "Downloading WSL kernel update from $wslKernelInstallerUrl..."
Invoke-WebRequest -Uri $wslKernelInstallerUrl -OutFile $wslKernelInstallerPath -UseBasicParsing -ErrorAction Stop

# Run the kernel update installer silently
Write-Host "Installing WSL kernel update..."
Start-Process -FilePath msiexec.exe -ArgumentList "/i", "`"$wslKernelInstallerPath`"", "/qn", "/norestart" -Wait -NoNewWindow

# Set WSL 2 as the default version
try {
    Write-Host "Setting WSL default version to 2..."
    wsl --set-default-version 2
    Write-Host "✅ WSL default version set to 2." -ForegroundColor Green
}
catch {
    Write-Host "⚠️ Could not set WSL default version. This may not be an issue if Docker handles it." -ForegroundColor Yellow
}

Remove-Item -Path $wslKernelInstallerPath -Force -ErrorAction SilentlyContinue

# --- 3. Install Docker Desktop ---
Write-Host "`n## 3. Installing Docker Desktop..." -ForegroundColor Cyan

$dockerInstallerUrl = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
$dockerInstallerPath = "$env:TEMP\DockerDesktopInstaller.exe"
Write-Host "Downloading Docker Desktop installer..."
Invoke-WebRequest -Uri $dockerInstallerUrl -OutFile $dockerInstallerPath -UseBasicParsing -ErrorAction Stop

# Install Docker Desktop silently and accept the license (important for scripting)
Write-Host "Running Docker Desktop installation (this may take several minutes)..."
# Use 'install --quiet' for silent install. We also explicitly accept the license.
Start-Process -FilePath $dockerInstallerPath -ArgumentList "install", "--quiet", "--accept-license" -Wait -NoNewWindow

Write-Host "✅ Docker Desktop installation finished." -ForegroundColor Green

Remove-Item -Path $dockerInstallerPath -Force -ErrorAction SilentlyContinue

# --- 4. Final Steps ---
Write-Host "`n## 4. Finalizing Setup..." -ForegroundColor Cyan

Write-Host "Launching Docker Desktop (a GUI might pop up)..."
# Start Docker Desktop application
$dockerAppPath = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerAppPath) {
    Start-Process -FilePath $dockerAppPath
    Write-Host "Wait a moment for Docker to start and initialize."
}

Write-Host "`n🎉 **Docker Workstation setup complete!**" -ForegroundColor Green
Write-Host "Please check the Docker Desktop application (it might be in the system tray) and ensure it's running." -ForegroundColor Green
Write-Host "You may need to log out and log back in (or restart) for all changes, like adding your user to the 'docker-users' group, to fully take effect." -ForegroundColor Green

# Optional: Add user to the docker-users group (requires a logoff/restart to take effect)
Write-Host "`nAdding current user to 'docker-users' group (requires logoff/restart)..." -ForegroundColor DarkGray
net localgroup docker-users $env:USERNAME /add 2>$null
