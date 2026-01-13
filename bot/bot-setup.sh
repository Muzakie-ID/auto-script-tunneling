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
echo -e "${CYAN}[INFO]${NC} Updating package list..."
apt-get update -qq 2>&1 | grep -v "^Hit:" | grep -v "^Get:"

echo -e "${CYAN}[INFO]${NC} Installing Python packages (this may take a moment)..."
apt-get install -y python3 python3-pip python3-venv python3-full -qq

# Create virtual environment for bot
BOT_VENV="/opt/telegram-bot-venv"
echo -e "${CYAN}[INFO]${NC} Creating virtual environment..."
if [ -d "$BOT_VENV" ]; then
    rm -rf "$BOT_VENV"
fi
python3 -m venv "$BOT_VENV"

# Install Python dependencies in virtual environment
echo -e "${CYAN}[INFO]${NC} Installing pytelegrambotapi and requests..."
"$BOT_VENV/bin/pip" install --upgrade pip -q
"$BOT_VENV/bin/pip" install pytelegrambotapi requests -q

# Verify installation
if "$BOT_VENV/bin/python" -c "import telebot" 2>/dev/null; then
    echo -e "${GREEN}✓ Python packages installed successfully${NC}"
else
    echo -e "${RED}✗ Failed to install Python packages${NC}"
    echo -e "${YELLOW}Please install manually:${NC}"
    echo "  sudo $BOT_VENV/bin/pip install pytelegrambotapi requests"
    exit 1
fi

# Create systemd service
cat > /etc/systemd/system/telegram-bot.service << EOF
[Unit]
Description=Telegram VPN Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/sbin/tunneling/bot
ExecStart=/opt/telegram-bot-venv/bin/python /usr/local/sbin/tunneling/bot/telegram_bot.py
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
/usr/local/sbin/tunneling/menu/bot-menu.sh
