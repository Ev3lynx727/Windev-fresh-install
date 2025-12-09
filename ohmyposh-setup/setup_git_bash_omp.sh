#!/bin/bash
#
# This script configures oh-my-posh for Git Bash on Windows.
# It assumes you have already installed oh-my-posh on Windows (e.g., for PowerShell).
#
# It will:
# 1. Locate the oh-my-posh.exe executable.
# 2. Add the correct initialization command to your ~/.bashrc file.
# 3. Provide instructions for final manual setup steps.

set -e

echo "🚀 Configuring oh-my-posh for Git Bash on Windows..."

# --- Step 1: Locate oh-my-posh.exe ---
# The default install path when using the installer or winget.
OMP_EXECUTABLE="$HOME/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe"

if [ -f "$OMP_EXECUTABLE" ]; then
    echo "✅ Found oh-my-posh.exe at: $OMP_EXECUTABLE"
else
    echo "❌ Could not find oh-my-posh.exe at the default location."
    echo "Please find your 'oh-my-posh.exe' and manually add the init command to your ~/.bashrc file."
    echo "Example: eval \"$('/path/to/your/oh-my-posh.exe' init bash)\""
    exit 1
fi

# --- Step 2: Configure .bashrc ---
BASHRC_FILE="$HOME/.bashrc"
# Use the full path to the executable within the eval command
INIT_LINE="eval \"$('$OMP_EXECUTABLE' init bash)\""

if [ -f "$BASHRC_FILE" ] && grep -q 'oh-my-posh init bash' "$BASHRC_FILE"; then
    echo "✅ oh-my-posh is already configured in $BASHRC_FILE."
else
    echo "🔧 Configuring $BASHRC_FILE..."
    # Create the file if it doesn't exist
    touch "$BASHRC_FILE"
    echo -e "\n# Initialize oh-my-posh for Git Bash" >> "$BASHRC_FILE"
    echo "$INIT_LINE" >> "$BASHRC_FILE"
    echo "✅ $BASHRC_FILE configured."
fi

# --- Step 3: Final Instructions ---
echo -e "\n🎉 --- Configuration Complete! --- 🎉"
echo ""
echo "🚨 IMPORTANT FINAL STEPS (Manual):"
echo ""
echo "1. INSTALL A NERD FONT:"
echo "   If you haven't already for PowerShell, download and install a Nerd Font."
echo "   - Recommended: MesloLGS NF -> https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
echo "   - Unzip and right-click each .ttf file and select 'Install'."
echo ""
echo "2. CONFIGURE GIT BASH TERMINAL FONT:"
echo "   - Right-click on the top bar of the Git Bash window."
echo "   - Go to 'Options...' -> 'Text'."
echo "   - Under 'Font', click 'Select...' and choose 'MesloLGS NF' (or your chosen Nerd Font)."
echo "   - Click 'Apply' and 'Save'."
echo ""
echo "3. RESTART GIT BASH:"
echo "   Close and reopen your Git Bash terminal to see the new prompt."
echo ""
echo "4. CUSTOMIZE THEME:"
echo "   To change your theme, edit the command in '$BASHRC_FILE'."
echo "   Example: eval \"$('$OMP_EXECUTABLE' init bash --config /path/to/theme.omp.json)\""
echo "   Your themes are likely in: ~/AppData/Local/Programs/oh-my-posh/themes"
echo ""
