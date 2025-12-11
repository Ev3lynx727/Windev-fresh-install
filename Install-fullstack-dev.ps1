# Requires elevated permissions (Run as Administrator)
# Set execution policy to allow running scripts (scoped to the current process)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Host "## 🛠️ Full-Stack Development Environment Setup" -ForegroundColor Cyan
Write-Host "This script will install all essential development tools, languages, and utilities." -ForegroundColor Cyan
Write-Host ""

# ========================================
# STEP 0: ENABLE WINDOWS DEVELOPER MODE & FEATURES
# ========================================
Write-Host "`n# 0. Configuring Windows for Development" -ForegroundColor Yellow

# --- Enable Windows Developer Mode ---
Write-Host "`n➡️ Enabling Windows Developer Mode..." -ForegroundColor Cyan
try {
    $devModeRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    
    # Create the registry key if it doesn't exist
    if (-not (Test-Path $devModeRegPath)) {
        New-Item -Path $devModeRegPath -Force | Out-Null
    }
    
    # Enable Developer Mode
    Set-ItemProperty -Path $devModeRegPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $devModeRegPath -Name "AllowAllTrustedApps" -Value 1 -Type DWord -Force
    
    Write-Host "✅ Windows Developer Mode enabled successfully." -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to enable Developer Mode. Error: $($_.Exception.Message)" -ForegroundColor Red
}

# --- Enable Essential Windows Features ---
Write-Host "`n➡️ Checking and enabling essential Windows features..." -ForegroundColor Cyan

# List of features to enable (useful for Docker, WSL, VMs, etc.)
$windowsFeatures = @(
    @{Name = "Microsoft-Windows-Subsystem-Linux"; DisplayName = "WSL (Windows Subsystem for Linux)" },
    @{Name = "VirtualMachinePlatform"; DisplayName = "Virtual Machine Platform" },
    @{Name = "Microsoft-Hyper-V-All"; DisplayName = "Hyper-V (Windows Pro/Enterprise only)" }
)

$featuresEnabled = $false

foreach ($feature in $windowsFeatures) {
    try {
        $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature.Name -ErrorAction SilentlyContinue
        
        if ($null -eq $featureState) {
            Write-Host "⚠️ $($feature.DisplayName) is not available on this Windows edition. Skipping." -ForegroundColor Yellow
            continue
        }
        
        if ($featureState.State -eq "Enabled") {
            Write-Host "✅ $($feature.DisplayName) is already enabled." -ForegroundColor Green
        }
        else {
            Write-Host "  Enabling $($feature.DisplayName)..." -ForegroundColor DarkGray
            Enable-WindowsOptionalFeature -Online -FeatureName $feature.Name -All -NoRestart -ErrorAction Stop | Out-Null
            Write-Host "✅ $($feature.DisplayName) enabled successfully." -ForegroundColor Green
            $featuresEnabled = $true
        }
    }
    catch {
        Write-Host "❌ Failed to enable $($feature.DisplayName). Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($featuresEnabled) {
    Write-Host "`n⚠️ NOTE: Some Windows features were enabled. A system restart will be required after this script completes." -ForegroundColor Yellow
}

# --- Helper Function: Refresh Environment Variables ---
function Update-SessionEnvironment {
    Write-Host "🔄 Refreshing environment variables..." -ForegroundColor DarkGray
    
    # Refresh PATH from Machine and User scopes
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
    
    # Refresh other common environment variables
    foreach ($level in 'Machine', 'User') {
        [System.Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
            if ($_.Name -ne 'Path') {
                [System.Environment]::SetEnvironmentVariable($_.Name, $_.Value, 'Process')
            }
        }
    }
    
    Write-Host "✅ Environment variables refreshed." -ForegroundColor DarkGray
}

# --- Helper Function for Downloading and Installing MSI/EXE ---
function Install-Software {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [System.Uri]$Url,
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [string[]]$Arguments
    )
    $InstallerPath = "$env:TEMP\$FileName"
    
    Write-Host "## Starting installation: $Name" -ForegroundColor Cyan
    Write-Host "Downloading installer from $Url..."
    
    try {
        Invoke-WebRequest -Uri $Url.AbsoluteUri -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
        Write-Host "Download complete. Starting silent installation..."

        $process = Start-Process -FilePath $InstallerPath -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Host "✅ $Name installed successfully." -ForegroundColor Green
        }
        else {
            Write-Host "❌ $Name installation failed with Exit Code $($process.ExitCode)." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ An error occurred during $Name installation: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        # Clean up the installer file if it was downloaded
        if (Test-Path $InstallerPath) {
            Remove-Item -Path $InstallerPath -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- 1. Check/Install Winget ---
Write-Host "`n# 1. Checking for Windows Package Manager (Winget)" -ForegroundColor Yellow

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Winget not found. Attempting to install/repair..." -ForegroundColor Red
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Winget could not be installed automatically. Please ensure Windows is updated or install 'App Installer' from the Microsoft Store." -ForegroundColor Red
    }
}
else {
    Write-Host "✅ Winget is available." -ForegroundColor Green
}

# --- 2. Install Packages via Winget ---
Write-Host "`n# 2. Installing Development Tools via Winget" -ForegroundColor Yellow

# ========================================
# CORE DEVELOPMENT TOOLS (Essential)
# ========================================
Write-Host "`n## Core Development Tools" -ForegroundColor Cyan
$corePackages = @(
    "Git.Git",                         # Git for Windows (Version Control)
    "Microsoft.VisualStudioCode",      # VS Code
    "Microsoft.WindowsTerminal",       # Windows Terminal
    "Microsoft.PowerShell",            # PowerShell Core/7
    "Microsoft.VCRedist.2015+.x64"     # Visual C++ Redistributable (2015-2022)
)

foreach ($package in $corePackages) {
    Write-Host "`n➡️ Installing: $($package)..." -ForegroundColor DarkGray
    $installed = winget list --id $package --accept-source-agreements 2>$null | Select-String -Pattern $package
    if ($installed) {
        Write-Host "✅ Package '$($package)' is already installed. Skipping." -ForegroundColor Green
        continue
    }

    winget install --id $package --silent --accept-package-agreements --accept-source-agreements -e 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Installed $($package)." -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed to install $($package). Exit Code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Try running manually: winget install --id $package" -ForegroundColor Yellow
    }
}

# Refresh environment after core tools installation
Update-SessionEnvironment

# ========================================
# PROGRAMMING LANGUAGES & RUNTIMES
# ========================================
Write-Host "`n## Programming Languages & Runtimes" -ForegroundColor Cyan
$languagePackages = @(
    "NodeJS.Nodejs.LTS",               # Node.js (LTS version)
    "Python.Python.3",                 # Python 3 (includes Pip)
    "Go.Go",                           # Go Programming Language
    "Microsoft.DotNet.SDK.8"           # .NET SDK 8
)

foreach ($package in $languagePackages) {
    Write-Host "`n➡️ Installing: $($package)..." -ForegroundColor DarkGray
    $installed = winget list --id $package --accept-source-agreements 2>$null | Select-String -Pattern $package
    if ($installed) {
        Write-Host "✅ Package '$($package)' is already installed. Skipping." -ForegroundColor Green
        continue
    }

    winget install --id $package --silent --accept-package-agreements --accept-source-agreements -e 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Installed $($package)." -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed to install $($package). Exit Code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Try running manually: winget install --id $package" -ForegroundColor Yellow
    }
}

# Refresh environment after language installations
Update-SessionEnvironment

# ========================================
# CLOUD & DEVOPS TOOLS
# ========================================
Write-Host "`n## Cloud & DevOps Tools" -ForegroundColor Cyan
$cloudPackages = @(
    "Microsoft.kubectl",               # Kubernetes CLI
    "Google.CloudSDK",                 # Google Cloud SDK (gcloud CLI)
    "Canonical.Multipass"              # Multipass (Ubuntu VMs)
)

foreach ($package in $cloudPackages) {
    Write-Host "`n➡️ Installing: $($package)..." -ForegroundColor DarkGray
    $installed = winget list --id $package --accept-source-agreements 2>$null | Select-String -Pattern $package
    if ($installed) {
        Write-Host "✅ Package '$($package)' is already installed. Skipping." -ForegroundColor Green
        continue
    }

    winget install --id $package --silent --accept-package-agreements --accept-source-agreements -e 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Installed $($package)." -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed to install $($package). Exit Code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Try running manually: winget install --id $package" -ForegroundColor Yellow
    }
}

# Refresh environment after cloud tools installation
Update-SessionEnvironment

# ========================================
# DATABASE & DEVELOPMENT TOOLS
# ========================================
Write-Host "`n## Database & Development Tools" -ForegroundColor Cyan
$databasePackages = @(
    "dbeaver.dbeaver"                  # DBeaver Community (Universal Database Tool)
)

foreach ($package in $databasePackages) {
    Write-Host "`n➡️ Installing: $($package)..." -ForegroundColor DarkGray
    $installed = winget list --id $package --accept-source-agreements 2>$null | Select-String -Pattern $package
    if ($installed) {
        Write-Host "✅ Package '$($package)' is already installed. Skipping." -ForegroundColor Green
        continue
    }

    winget install --id $package --silent --accept-package-agreements --accept-source-agreements -e 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Installed $($package)." -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed to install $($package). Exit Code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Try running manually: winget install --id $package" -ForegroundColor Yellow
    }
}

# Refresh environment after database tools installation
Update-SessionEnvironment

# ========================================
# UTILITIES & ENHANCEMENTS
# ========================================
Write-Host "`n## Utilities & Enhancements" -ForegroundColor Cyan
$utilityPackages = @(
    "7zip.7Zip",                       # 7-Zip for file compression/extraction
    "JanDeDobbeleer.OhMyPosh",         # Professional terminal prompt (requires PowerShell Core)
    "Koalaman.ShellCheck"              # ShellCheck (Linter for shell scripts)
)

foreach ($package in $utilityPackages) {
    Write-Host "`n➡️ Installing: $($package)..." -ForegroundColor DarkGray
    $installed = winget list --id $package --accept-source-agreements 2>$null | Select-String -Pattern $package
    if ($installed) {
        Write-Host "✅ Package '$($package)' is already installed. Skipping." -ForegroundColor Green
        continue
    }

    winget install --id $package --silent --accept-package-agreements --accept-source-agreements -e 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Installed $($package)." -ForegroundColor Green
    }
    else {
        Write-Host "❌ Failed to install $($package). Exit Code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "   Try running manually: winget install --id $package" -ForegroundColor Yellow
    }
}

# Refresh environment after utility installations
Update-SessionEnvironment

# ========================================
# ALTERNATIVE PACKAGE MANAGERS (Optional)
# ========================================
Write-Host "`n## Alternative Package Managers" -ForegroundColor Cyan

# --- Install Chocolatey ---
Write-Host "`n➡️ Installing Chocolatey Package Manager..." -ForegroundColor Yellow

if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "✅ Chocolatey is already installed. Skipping." -ForegroundColor Green
}
else {
    $ChocoInstallCommand = @"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
"@

    try {
        Invoke-Expression $ChocoInstallCommand
        Start-Sleep -Seconds 5
        Write-Host "✅ Chocolatey installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install Chocolatey. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# --- Install Bun via Chocolatey ---
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "`n➡️ Installing Bun via Chocolatey..." -ForegroundColor Yellow
    try {
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

# --- 3. Verification ---
Write-Host "`n## ✅ Verification" -ForegroundColor Cyan

# Final PATH refresh before verification
Update-SessionEnvironment

Write-Host "Verifying installations..."
$tools = @(
    @{Name = "git"; Args = "--version" },
    @{Name = "code"; Args = "--version" },
    @{Name = "wt"; Args = "--version" },
    @{Name = "pwsh"; Args = "--version" },
    @{Name = "node"; Args = "--version" },
    @{Name = "npm"; Args = "--version" },
    @{Name = "python"; Args = "--version" },
    @{Name = "pip"; Args = "--version" },
    @{Name = "go"; Args = "version" },
    @{Name = "dotnet"; Args = "--version" },
    @{Name = "kubectl"; Args = "version --client" },
    @{Name = "gcloud"; Args = "--version" },
    @{Name = "choco"; Args = "--version" },
    @{Name = "bun"; Args = "--version" }
)

$failedTools = @()

foreach ($tool in $tools) {
    try {
        Write-Host "- $($tool.Name):" -NoNewline
        $versionOutput = & $tool.Name $tool.Args.Split(' ') 2>&1
        if ($LASTEXITCODE -eq 0 -and $versionOutput) {
            $version = ($versionOutput | Select-Object -First 1).ToString().Trim()
            Write-Host " $version" -ForegroundColor DarkGreen
        }
        else {
            Write-Host " Installed (version check unavailable)" -ForegroundColor DarkGreen
        }
    }
    catch {
        Write-Host " Not found in PATH" -ForegroundColor Red
        $failedTools += $tool.Name
    }
}

if ($failedTools.Count -gt 0) {
    Write-Host "`n⚠️ Some tools are not accessible:" -ForegroundColor Yellow
    Write-Host "Missing: $($failedTools -join ', ')" -ForegroundColor Yellow
    Write-Host "`nTroubleshooting steps:" -ForegroundColor Cyan
    Write-Host "1. Close and reopen PowerShell/Terminal" -ForegroundColor White
    Write-Host "2. If still not working, restart your computer" -ForegroundColor White
    Write-Host "3. Verify installations with: winget list" -ForegroundColor White
}

# --- 4. Final Steps ---
Write-Host "`n🎉 **Full-Stack Development Environment Setup Complete!**" -ForegroundColor Green
Write-Host ""
Write-Host "‼️ **ACTION REQUIRED:**" -ForegroundColor Red
Write-Host "Please restart PowerShell and/or your computer to ensure all tools are correctly added to your system PATH." -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 **Installed Tools Summary:**" -ForegroundColor Cyan
Write-Host "  • Core: Git, VS Code, Windows Terminal, PowerShell Core, VCRedist" -ForegroundColor White
Write-Host "  • Languages: Node.js, Python, Go, .NET SDK" -ForegroundColor White
Write-Host "  • Cloud: kubectl, gcloud, Multipass" -ForegroundColor White
Write-Host "  • Database: DBeaver" -ForegroundColor White
Write-Host "  • Utilities: 7-Zip, Oh My Posh, ShellCheck" -ForegroundColor White
Write-Host "  • Package Managers: Chocolatey, Bun" -ForegroundColor White
Write-Host ""
