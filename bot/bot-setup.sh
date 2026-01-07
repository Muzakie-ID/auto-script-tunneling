#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           SETUP TELEGRAM BOT                        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Steps:${NC}"
echo "1. Open @BotFather in Telegram"
echo "2. Send /newbot"
echo "3. Follow instructions to create bot"
echo "4. Copy the bot token"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Enter Bot Token: " bot_token
if [[ -z $bot_token ]]; then
    echo -e "${RED}Bot token cannot be empty!${NC}"
    exit 1
fi

read -p "Enter Your Telegram User ID (Admin): " admin_id
if [[ -z $admin_id ]]; then
    echo -e "${RED}Admin ID cannot be empty!${NC}"
    exit 1
fi

# Create bot config directory
mkdir -p /etc/tunneling/bot
mkdir -p /etc/tunneling/bot/orders

# Save config
cat > /etc/tunneling/bot/config.json << EOF
{
    "token": "$bot_token",
    "admin_id": "$admin_id",
    "auto_approve": false,
    "trial_enabled": true,
    "created": "$(date +%Y-%m-%d)"
}
EOF

# Install Python and pip if not installed
echo -e "${CYAN}[INFO]${NC} Checking Python dependencies..."
apt-get update > /dev/null 2>&1
apt-get install -y python3 python3-pip > /dev/null 2>&1

# Install Python dependencies
echo -e "${CYAN}[INFO]${NC} Installing Python packages..."
pip3 install --upgrade pip > /dev/null 2>&1
pip3 install pytelegrambotapi requests > /dev/null 2>&1

# Verify installation
if python3 -c "import telebot" 2>/dev/null; then
    echo -e "${GREEN}✓ Python packages installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install Python packages${NC}"
    echo -e "${YELLOW}Trying alternative installation method...${NC}"
    python3 -m pip install pytelegrambotapi requests
fi

# Copy bot script
cp /usr/local/sbin/tunneling/telegram_bot.py /etc/tunneling/bot/

# Create systemd service
cat > /etc/systemd/system/telegram-bot.service << EOF
[Unit]
Description=Telegram VPN Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/tunneling/bot
ExecStart=/usr/bin/python3 /etc/tunneling/bot/telegram_bot.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable telegram-bot
systemctl start telegram-bot

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        TELEGRAM BOT SETUP COMPLETED!                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Bot Status:${NC} $(systemctl is-active telegram-bot)"
echo -e "${YELLOW}Admin ID:${NC} $admin_id"
echo ""
echo -e "${GREEN}Your bot is now running!${NC}"
echo -e "Open your bot in Telegram and send ${CYAN}/start${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/bot-menu.sh
