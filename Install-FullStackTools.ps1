# Requires elevated permissions (Run as Administrator)
# Set execution policy to allow running scripts (scoped to the current process)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Host "## 🛠️ Installing Multi-Language Developer Tools" -ForegroundColor Cyan
Write-Host "This script will silently install Git, Node.js, Python, Chocolatey, Go, and Bun." -ForegroundColor Cyan

# --- 1. Check/Install Winget ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Winget (Windows Package Manager) not found. Attempting to install/repair..." -ForegroundColor Red
    # Attempt to install the App Installer package which contains Winget
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Winget could not be installed automatically. Please ensure Windows is updated." -ForegroundColor Red
        # Continue as some tools can be installed via Chocolatey later
    }
}
Write-Host "✅ Winget is available or installation was attempted." -ForegroundColor Green

# --- 2. Install Tools via Winget (Prioritized) ---

# Array of package IDs for efficient Winget installation
$wingetPackages = @(
    "Git.Git",               # Git for Windows (Version Control)
    "NodeJS.Nodejs.LTS",     # Node.js (Long Term Support version)
    "Python.Python.3",       # Python 3 (latest stable version, includes Pip)
    "Go.Go",                 # Go Programming Language
    "Koalaman.ShellCheck",   # ShellCheck (Linter for shell scripts)
    "Canonical.Multipass"    # Multipass (Ubuntu VMs)
)

foreach ($packageId in $wingetPackages) {
    Write-Host "`n➡️ Installing package via Winget: $($packageId)..." -ForegroundColor Yellow
    try {
        winget install --id $packageId --silent --accept-package-agreements --accept-source-agreements -e
        Write-Host "✅ Successfully installed $($packageId)." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install $($packageId) via Winget. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- 2.1 Install Shell LSP via NPM ---
# Note: npm might not be available immediately after Winget install during the same session.
# $npmPath = Get-Command npm -ErrorAction SilentlyContinue
# if ($npmPath) {
#     Write-Host "`n➡️ Installing bash-language-server via npm..." -ForegroundColor Yellow
#     try {
#         npm install -g bash-language-server
#         Write-Host "✅ Successfully installed bash-language-server." -ForegroundColor Green
#     }
#     catch {
#         Write-Host "❌ Failed to install bash-language-server. Error: $($_.Exception.Message)" -ForegroundColor Red
#     }
# }
# else {
#     Write-Host "`n⚠️ npm command not found (pending PATH update). Skipping bash-language-server installation." -ForegroundColor Yellow
#     Write-Host "   Please run 'npm install -g bash-language-server' manually after restart." -ForegroundColor Yellow
# }

# --- 3. Install Chocolatey (Cygwin/Shell compatibility) ---
Write-Host "`n## 🚀 Installing Chocolatey Package Manager..." -ForegroundColor Cyan

# Chocolatey's recommended one-liner installation
$ChocoInstallCommand = @"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
"@

try {
    # Execute the command to install Chocolatey silently
    Invoke-Expression $ChocoInstallCommand
    # Note: choco is usually available immediately, but we can wait for safety
    Start-Sleep -Seconds 5
    Write-Host "✅ Chocolatey installed successfully." -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to install Chocolatey. Error: $($_.Exception.Message)" -ForegroundColor Red
}

# --- 4. Install Bun via Chocolatey ---
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "`n➡️ Installing Bun via Chocolatey..." -ForegroundColor Yellow
    try {
        # Use --confirm to bypass confirmation prompts
        choco install bun --confirm
        Write-Host "✅ Successfully installed Bun." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install Bun via Chocolatey. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "⚠️ Skipping Bun installation because Chocolatey is not available." -ForegroundColor Yellow
}

# --- 5. Final Verification and Cleanup ---
Write-Host "`n## ✅ Verification and Finalization" -ForegroundColor Cyan

# Verify key installations (results will appear below)
Write-Host "Verifying installations..."
$tools = @("git", "node", "npm", "python3", "pip", "go", "choco", "bun")
foreach ($tool in $tools) {
    try {
        Write-Host "- $($tool):" -NoNewline
        $versionOutput = & $tool "--version" 2>&1
        Write-Host " $($versionOutput.Split(' ')[0])" -ForegroundColor DarkGreen
    }
    catch {
        Write-Host " Not found or path error." -ForegroundColor Red
    }
}


Write-Host "`n🎉 **Multi-Language Developer Tools Setup Complete!**" -ForegroundColor Green
Write-Host "‼️ **ACTION REQUIRED:** Please close all terminals and RESTART YOUR COMPUTER to ensure all new tools (especially Go, Choco, and Bun) are correctly added to the system PATH." -ForegroundColor Red
