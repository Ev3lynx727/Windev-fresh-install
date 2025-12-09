#!/bin/bash
#
# This script fully automates the setup for oh-my-posh in Git Bash on Windows.
# It handles locating oh-my-posh, installing a Nerd Font, and configuring .bashrc.

set -e

echo "🚀 Starting automated oh-my-posh configuration for Git Bash..."

# --- Step 1: Locate oh-my-posh.exe ---
OMP_EXECUTABLE=$(command -v oh-my-posh.exe)

if [ -z "$OMP_EXECUTABLE" ]; then
    echo "❌ oh-my-posh.exe not found in your PATH."
    echo "Please ensure oh-my-posh is installed (e.g., via winget install JanDeDobbeleer.OhMyPosh) and added to your system's PATH."
    exit 1
fi

echo "✅ Found oh-my-posh.exe at: $OMP_EXECUTABLE"

# --- Step 2: Automate Font Installation via PowerShell script ---
PWSH_EXECUTABLE=$(command -v pwsh.exe)
if [ -z "$PWSH_EXECUTABLE" ]; then
    echo "⚠️ PowerShell (pwsh.exe) not found in PATH. Skipping automated font installation."
    echo "   Please install PowerShell (e.g., via winget install Microsoft.PowerShell) to use the font installer."
    echo "   Alternatively, manually install a Nerd Font like 'MesloLGM NF' (Meslo LG M Regular Nerd Font Complete.ttf)."
else
    echo "Running automated font installation using PowerShell script..."
    # Execute the PowerShell script in the same directory
    "$PWSH_EXECUTABLE" -ExecutionPolicy Bypass -File "$(dirname "$0")/find_omp.ps1"
    echo "✅ Font installation script executed. Check output above for details."
    echo "ℹ️ Remember to manually set '$fontName' as your terminal's font for icons to display correctly."
fi

# --- Step 3: Configure .bashrc ---
BASHRC_FILE="$HOME/.bashrc"
# Use the full path to the executable within the eval command for robustness
INIT_LINE="eval \"\$(\"$OMP_EXECUTABLE\" init bash)\""
# Example for theme configuration:
# INIT_LINE_THEME="eval \"\$(\"$OMP_EXECUTABLE\" init bash --config ~/AppData/Local/Programs/oh-my-posh/themes/jandedobbeleer.omp.json)\""


if [ -f "$BASHRC_FILE" ] && grep -q 'oh-my-posh init bash' "$BASHRC_FILE"; then
    echo "✅ oh-my-posh is already configured in $BASHRC_FILE."
else
    echo "🔧 Configuring $BASHRC_FILE..."
    # Create the file if it doesn't exist
    touch "$BASHRC_FILE"
    echo -e "\n# Initialize oh-my-posh for Git Bash" >> "$BASHRC_FILE"
    echo "$INIT_LINE" >> "$BASHRC_FILE"
    # echo "# Uncomment the line below and customize your theme path if you want a specific theme." >> "$BASHRC_FILE"
    # echo "# $INIT_LINE_THEME" >> "$BASHRC_FILE"
    echo "✅ $BASHRC_FILE configured."
fi

# --- Step 4: Final Instructions ---
echo -e "\n🎉 --- Configuration Complete! --- 🎉"
echo "Please close and reopen your Git Bash terminal to see the new prompt."
echo "If you have issues, ensure your terminal's font is set to 'MesloLGM NF' (or your chosen Nerd Font)."
