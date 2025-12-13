#!/bin/bash

# setup-aliases.sh: Auto-complete opendev-update alias in ~/.bashrc and /root/.bashrc

ALIAS_LINE="alias opendev-update='bash /root/windev-setup/opendev-update.sh'"
CHECKUP_ALIAS="alias Opendev-checkup='bash /root/windev-setup/wsl2-dev/system-checkup.sh'"

echo "Setting up opendev-update alias..."

# For user ~/.bashrc
if ! grep -q "alias opendev-update" ~/.bashrc; then
    echo "$ALIAS_LINE" >> ~/.bashrc
    echo "opendev-update alias added to ~/.bashrc"
else
    echo "opendev-update alias already exists in ~/.bashrc"
fi

if ! grep -q "alias Opendev-checkup" ~/.bashrc; then
    echo "$CHECKUP_ALIAS" >> ~/.bashrc
    echo "Opendev-checkup alias added to ~/.bashrc"
else
    echo "Opendev-checkup alias already exists in ~/.bashrc"
fi

# Source user bashrc
source ~/.bashrc

# For root /root/.bashrc
if sudo grep -q "alias opendev-update" /root/.bashrc; then
    echo "opendev-update alias already exists in /root/.bashrc"
else
    sudo sh -c "echo '$ALIAS_LINE' >> /root/.bashrc"
    echo "opendev-update alias added to /root/.bashrc"
fi

if sudo grep -q "alias Opendev-checkup" /root/.bashrc; then
    echo "Opendev-checkup alias already exists in /root/.bashrc"
else
    sudo sh -c "echo '$CHECKUP_ALIAS' >> /root/.bashrc"
    echo "Opendev-checkup alias added to /root/.bashrc"
fi

# Optional: Set up oh-my-posh or oh-my-zsh related completions if detected
if command -v oh-my-posh &> /dev/null; then
    OMP_ALIAS="alias omp='oh-my-posh'"
    if ! grep -q "alias omp" ~/.bashrc; then
        echo "$OMP_ALIAS" >> ~/.bashrc
        echo "oh-my-posh alias 'omp' added to ~/.bashrc"
    fi
    sudo sh -c "if ! grep -q 'alias omp' /root/.bashrc; then echo '$OMP_ALIAS' >> /root/.bashrc; fi"
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    ZSH_ALIAS="alias zshrc='nano ~/.zshrc'"
    if ! grep -q "alias zshrc" ~/.bashrc; then
        echo "$ZSH_ALIAS" >> ~/.bashrc
        echo "zshrc alias added to ~/.bashrc for oh-my-zsh"
    fi
    sudo sh -c "if ! grep -q 'alias zshrc' /root/.bashrc; then echo '$ZSH_ALIAS' >> /root/.bashrc; fi"
fi

echo "Alias setup complete. Run 'opendev-update' to test."