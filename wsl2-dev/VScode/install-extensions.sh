#!/bin/bash

# Install VS Code extensions from JSON

CODE_PATH="/mnt/c/Program Files/Microsoft VS Code/bin/code"

if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing..."
    sudo apt update && sudo apt install -y jq
fi

if [ ! -f extensions.json ]; then
    echo "extensions.json not found. Run backup-extensions.sh first."
    exit 1
fi

echo "Installing extensions from extensions.json..."

jq -r '.extensions[]' extensions.json | while read -r ext; do
    echo "Installing $ext..."
    $CODE_PATH --install-extension "$ext"
done

echo "Extensions installation complete."