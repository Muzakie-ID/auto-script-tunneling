#!/bin/bash

# Make all scripts executable
# Run this after cloning the repository

echo "Setting permissions for all scripts..."

# Main setup script
chmod +x setup.sh
chmod +x update.sh

# Menu scripts
chmod +x menu/*.sh

# SSH scripts
chmod +x ssh/*.sh

# XRAY scripts
chmod +x xray/*.sh

# System scripts
chmod +x system/*.sh

# Bot scripts
chmod +x bot/*.sh
chmod +x bot/telegram_bot.py

echo "✓ All scripts are now executable"
echo ""
echo "You can now run: ./setup.sh"
