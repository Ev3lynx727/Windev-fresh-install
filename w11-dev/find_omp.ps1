# This script fully automates the setup for oh-my-posh on a new system.
# It installs a recommended font and configures the PowerShell profile.

# --- 1. FONT INSTALLATION ---
$fontName = "MesloLGM NF"
$fontFileName = "Meslo LG M Regular Nerd Font Complete.ttf"
$userFontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$fontPath = Join-Path $userFontDir $fontFileName

if (Test-Path $fontPath) {
    Write-Host "✅ Recommended font '$fontName' is already installed."
} else {
    Write-Host "Font '$fontName' not found. Starting download and installation..."
    $fontZipUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip"
    $tempDir = New-Item -ItemType Directory -Path (Join-Path $env:TEMP (New-Guid).Guid)
    $zipPath = Join-Path $tempDir "nerdfont.zip"

    try {
        Write-Host "Downloading from $fontZipUrl..."
        Invoke-WebRequest -Uri $fontZipUrl -OutFile $zipPath -UseBasicParsing
        Write-Host "Download complete. Extracting files..."
        Expand-Archive -Path $zipPath -DestinationPath $tempDir
        Write-Host "Installing fonts..."
        # Create the user font directory if it doesn't exist
        if (-not (Test-Path $userFontDir)) {
            New-Item -ItemType Directory -Path $userFontDir | Out-Null
        }
        Get-ChildItem -Path $tempDir -Include "*.ttf", "*.otf" -Recurse | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $userFontDir
        }
        Write-Host "✅ Font '$fontName' installed successfully for the current user."
        Write-Host "IMPORTANT: Please set your terminal's font to '$fontName' to see icons correctly."
    }
    catch {
        Write-Error "Font installation failed: $_"
    }
    finally {
        Write-Host "Cleaning up temporary files..."
        Remove-Item -Path $tempDir -Recurse -Force
    }
}

# --- 2. OH-MY-POSH PROFILE CONFIGURATION ---
Write-Host "`n--- Configuring PowerShell Profile ---"
$omp_path = Get-Command oh-my-posh -ErrorAction SilentlyContinue
if (-not $omp_path) {
    Write-Error "oh-my-posh is not found. Please install it first and ensure it's in your PATH."
    # For example, you can install it via winget:
    # winget install JanDeDobbeleer.OhMyPosh
    return
}

Write-Host "oh-my-posh executable found at: $($omp_path.Source)"
$initCommand = "oh-my-posh init pwsh | Invoke-Expression"

if (-not (Test-Path $PROFILE)) {
    Write-Host "PowerShell profile not found. Creating one at: $PROFILE"
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
}

$profileContent = Get-Content $PROFILE -Raw
if ($profileContent -match "oh-my-posh init pwsh") {
    Write-Host "✅ PowerShell profile is already configured for oh-my-posh."
} else {
    Write-Host "Adding oh-my-posh initialization to your PowerShell profile..."
    Add-Content -Path $PROFILE -Value "`n# Initialize oh-my-posh`n$initCommand"
    Write-Host "✅ Profile configuration complete!"
}

Write-Host "`nSetup finished. Please restart your shell or run '. `$PROFILE' to apply all changes."
