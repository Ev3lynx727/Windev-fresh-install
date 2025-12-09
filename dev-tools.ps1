# Requires elevated permissions (Run as Administrator)
# Set execution policy to allow running scripts (scoped to the current process)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# --- Helper Function for Downloading and Installing MSI/EXE ---
function Install-Software {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$FileName,
        [Parameter(Mandatory=$true)][string[]]$Arguments
    )
    $InstallerPath = "$env:TEMP\$FileName"
    
    Write-Host "## Starting installation: $Name" -ForegroundColor Cyan
    Write-Host "Downloading installer from $Url..."
    
    try {
        # Check if winget is available and prefer it if the package is common (like Git)
        if ($Name -eq "Git for Windows" -and (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "Using winget for Git installation..."
            winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
            Write-Host "✅ Git for Windows installed successfully via winget." -ForegroundColor Green
            return
        }
        
        # Fallback to direct download/install if winget is not available or for custom installers
        Invoke-WebRequest -Uri $Url -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
        Write-Host "Download complete. Starting silent installation..."

        $process = Start-Process -FilePath $InstallerPath -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Host "✅ $Name installed successfully." -ForegroundColor Green
        } else {
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

# --- 1. Install Git for Windows (Version Control) ---
Write-Host "`n# 1. Installing Git for Windows" -ForegroundColor Yellow
# Using winget is the preferred method on modern Windows versions, falling back to direct install.
# The winget block is included in the Install-Software function above.
Install-Software -Name "Git for Windows" -Url "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -FileName "GitInstaller.exe" -Arguments @(
    "/VERYSILENT", "/NORESTART", "/NOCANCEL", "/SP-", "/CLOSEAPPLICATIONS", "/RESTARTAPPLICATIONS",
    "/COMPONENTS=assoc,assoc_sh,icons,ext\\reg\\shellhere,ext\\reg\\assoc,ext\\reg\\assoc_sh,ext\\reg\\shellhere",
    "/PATH=CmdTools" # Recommended: Allows Git to be used from Command Prompt and PowerShell
)

# --- 2. Install Winget (Windows Package Manager) ---
# NOTE: Winget is often pre-installed on modern Windows 10/11. We check and install other tools using it.
Write-Host "`n# 2. Installing common developer tools using Winget" -ForegroundColor Yellow

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not found. Attempting to install the App Installer package..." -ForegroundColor Yellow
    # This command attempts to repair/install the App Installer which contains Winget
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Winget could not be installed automatically. Please ensure Windows is updated or install 'App Installer' from the Microsoft Store." -ForegroundColor Red
    }
} else {
    Write-Host "✅ Winget is available. Continuing with package installation." -ForegroundColor Green
}

# --- 3. Install Common Developer Tools using Winget ---

# Array of common package IDs
$packagesToInstall = @(
    "Microsoft.PowerShell",        # Latest PowerShell Core/7
    "NodeJS.Nodejs.LTS",           # Node.js (LTS version)
    "7zip.7Zip",                   # 7-Zip for file compression/extraction
    "JanDeDobbeleer.OhMyPosh",     # For a professional, themed terminal prompt (requires PowerShell Core)
    "dbeaver.dbeaver",             # DBeaver Community (Universal Database Tool)
    "Google.CloudSDK",             # Google Cloud SDK (gcloud CLI)
    "Microsoft.VisualStudioCode",  # VS Code
    "Microsoft.WindowsTerminal",   # Windows Terminal
    "Microsoft.DotNet.SDK.8",      # .NET SDK
    "Microsoft.kubectl",           # Kubernetes CLI
    "Hashicorp.Terraform",         # Terraform
    "Canonical.Multipass"          # Multipass
)

foreach ($package in $packagesToInstall) {
    Write-Host "Installing package: $($package)..." -ForegroundColor DarkGray
    try {
        # --silent is implied by winget for most installations
        winget install --id $package --silent --accept-package-agreements --accept-source-agreements -e
        Write-Host "✅ Installed $($package)." -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to install $($package). Skipping." -ForegroundColor Red
    }
}

# --- 3a. Special Install for Visual Studio 2022 Community ---
Write-Host "`n# 3a. Installing Visual Studio 2022 Community with workloads..." -ForegroundColor Yellow
try {
    $vsWorkloads = @(
        "--add", "Microsoft.VisualStudio.Workload.NetWeb", # ASP.NET and web development
        "--add", "Microsoft.VisualStudio.Workload.ManagedDesktop", # .NET desktop development
        "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",  # Desktop development with C++
        "--includeRecommended"
    )
    winget install --id "Microsoft.VisualStudio.2022.Community" --override "$($vsWorkloads -join ' ')" --silent --accept-package-agreements --accept-source-agreements
    Write-Host "✅ Installed Visual Studio 2022 Community." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install Visual Studio 2022 Community. Skipping." -ForegroundColor Red
}


# --- 4. Final Steps ---
Write-Host "`n🎉 **Dependency Tools Setup Complete!**" -ForegroundColor Green
Write-Host "Please restart PowerShell and/or your computer to ensure Git, Node.js, and other tools are correctly added to your system PATH." -ForegroundColor Green
Write-Host "Run 'git --version', 'node --version', 'gcloud --version', 'code --version', 'wt -v', 'dotnet --version', 'kubectl version --client', 'terraform --version', and 'multipass --version' to confirm installation." -ForegroundColor Green
Write-Host "Visual Studio 2022 Community has also been installed." -ForegroundColor Green
