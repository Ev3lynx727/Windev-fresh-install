# VS Code Extensions Management (Windows)

This folder contains PowerShell scripts to backup and restore VS Code extensions in JSON format.

## Usage

1. After installing VS Code (e.g., via Install-fullstack-dev.ps1), open PowerShell.

2. To backup current extensions:
   ```powershell
   .\backup-extensions.ps1
   ```
   This creates/updates `extensions.json` with your current extensions.

3. To install extensions on a new setup:
   ```powershell
   .\install-extensions.ps1
   ```
   This installs all extensions listed in `extensions.json`.

## Requirements

- VS Code installed on Windows.
- PowerShell with execution policy allowing scripts.

## Notes

- `extensions.json` is symlinked from `wsl2-dev/VScode/` for shared management.
- Edit `extensions.json` manually to add/remove extensions.
- Run on Windows for native management.