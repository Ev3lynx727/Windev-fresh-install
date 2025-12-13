#!/bin/bash

# Backup VS Code extensions to JSON

CODE_PATH="/mnt/c/Program Files/Microsoft VS Code/bin/code"

if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing..."
    sudo apt update && sudo apt install -y jq
fi

echo "Backing up extensions..."

$CODE_PATH --list-extensions | jq -R -s 'split("\n") | map(select(. != "")) | {"extensions": .}' > extensions.json

echo "Extensions backed up to extensions.json"