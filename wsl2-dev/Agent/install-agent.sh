#!/bin/bash

# Install opencode agent and mgrep plugin via pnpm/bun

echo "Installing opencode agent and mgrep plugin..."

# Check for package manager
if command -v pnpm &> /dev/null; then
    PM="pnpm"
elif command -v bun &> /dev/null; then
    PM="bun"
elif command -v npm &> /dev/null; then
    PM="npm"
else
    echo "No package manager found. Install Node.js and pnpm/bun first."
    exit 1
fi

echo "Using $PM for installation..."

# Install opencode globally
echo "Installing opencode..."
$PM install -g opencode

# Install mgrep globally
echo "Installing mgrep..."
$PM install -g mgrep

# Verify
echo "Verifying installations..."
if command -v opencode &> /dev/null; then
    echo "opencode installed successfully."
else
    echo "opencode install failed."
fi

if command -v mgrep &> /dev/null; then
    echo "mgrep installed successfully."
    echo "Configuring mgrep for opencode..."
    mgrep login
    mgrep install-opencode
    echo "mgrep configured for opencode."
else
    echo "mgrep install failed."
fi

# MCP Server Setup
echo "Setting up MCP servers for opencode..."

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/config.jsonc"

mkdir -p "$CONFIG_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating opencode config with MCP servers..."
    cat > "$CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "mcp_everything": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-everything"],
      "enabled": true
    },
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
      },
      "enabled": true
    },
    "gh_grep": {
      "type": "remote",
      "url": "https://mcp.grep.app",
      "enabled": true
    }
  }
}
EOF
    echo "MCP config created at $CONFIG_FILE"
    echo "Note: Set CONTEXT7_API_KEY environment variable for Context7 server."
else
    echo "opencode config already exists. Manually add MCP servers if needed."
fi

echo "Installation complete."