#!/bin/bash

# opendev-update: Pull updates from remote repo
# Designed to run as root for cron automation

LOG_FILE="/var/log/opendev-update.log"

echo "$(date): Starting opendev-update" >> "$LOG_FILE"

cd /root/windev-setup || { echo "Repo not found at /root/windev-setup" >> "$LOG_FILE"; exit 1; }

# Pull updates
if git pull origin main >> "$LOG_FILE" 2>&1; then
    echo "$(date): Pull successful" >> "$LOG_FILE"
else
    echo "$(date): Pull failed" >> "$LOG_FILE"
fi

echo "$(date): opendev-update complete" >> "$LOG_FILE"