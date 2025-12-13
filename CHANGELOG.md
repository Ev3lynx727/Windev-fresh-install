# Changelog

## [Unreleased]

### Added
- **VS Code Extensions Management**: New `VScode/` folder with scripts to backup and restore VS Code extensions in JSON format.
  - `backup-extensions.sh`: Exports current extensions to `extensions.json`.
  - `install-extensions.sh`: Installs extensions from `extensions.json`.
  - `extensions.json`: Stores extension IDs as a JSON array.
  - `README.md`: Usage instructions.
  - Run from WSL2 after VS Code installation for easy setup on new machines or VMs.
- **Windows Mirroring**: Added `w11-dev/VScode/` with PowerShell equivalents (`backup-extensions.ps1`, `install-extensions.ps1`) for native Windows management. `extensions.json` is symlinked for shared cross-platform use.
- **Agent Installer**: Added `wsl2-dev/Agent/` folder with `install-agent.sh` to install opencode agent and mgrep plugin via pnpm/bun/npm globally, with automatic mgrep configuration for opencode and MCP server setup.
- **Deployment Guide**: Added `DEPLOYMENT.md` with hybrid workflow for fresh installs, including user/root phases, repo cloning to root, locking for restricted systems, and cron/alias setup for automated updates.
- **Update Script**: Added `opendev-update.sh` for pulling repo updates from remote, designed for root cron execution.
- **Alias Setup Script**: Added `setup-aliases.sh` for auto-completing `opendev-update` and `Opendev-checkup` aliases in `~/.bashrc` and `/root/.bashrc`, with optional support for oh-my-posh and oh-my-zsh aliases.
- **System Checkup Updates**: Enhanced `wsl2-dev/system-checkup.sh` with checks for opencode, mgrep, MCP servers, package managers, shell enhancements, lazydocker, speedtest2, dnsenum, and neovim.