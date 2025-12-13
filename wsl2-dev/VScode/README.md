# VS Code Extensions Management

This folder contains scripts to backup and restore VS Code extensions in JSON format.

## Usage

1. After installing VS Code (e.g., via Install-fullstack-dev.ps1), log into WSL2.

2. To backup current extensions:
   ```bash
   chmod +x backup-extensions.sh
   ./backup-extensions.sh
   ```
   This creates/updates `extensions.json` with your current extensions.

3. To install extensions on a new setup:
   ```bash
   chmod +x install-extensions.sh
   ./install-extensions.sh
   ```
   This installs all extensions listed in `extensions.json`.

## Requirements

- VS Code installed on Windows.
- WSL2 access to Windows `code` command.
- `jq` for JSON handling (installed automatically if missing).

## Notes

- Edit `extensions.json` manually to add/remove extensions (shared with Windows via symlink).
- Run from WSL2 shell after Windows setup.
- For Windows-native management, see `w11-dev/VScode/`.