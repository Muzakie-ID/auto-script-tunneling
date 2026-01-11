#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              START BOT TELEGRAM                   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if bot is configured
if [ ! -f "/etc/tunneling/bot/config.json" ]; then
    echo -e "${RED}Bot not configured yet!${NC}"
    echo -e "${YELLOW}Please run Setup Bot Telegram first (option 1)${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    /usr/local/sbin/tunneling/menu/bot-menu.sh
    exit 1
fi

# Check if bot is already running
if systemctl is-active --quiet telegram-bot; then
    echo -e "${GREEN}✓ Bot is already running!${NC}"
    echo ""
    systemctl status telegram-bot --no-pager
else
    # Bot not running, check virtual environment
    BOT_VENV="/opt/telegram-bot-venv"
    
    # Check if venv and packages exist
    if [ ! -d "$BOT_VENV" ] || ! "$BOT_VENV/bin/python" -c "import telebot" 2>/dev/null; then
        echo -e "${RED}✗ Virtual environment not properly configured!${NC}"
        echo -e "${YELLOW}Please run Setup Bot Telegram first (option 1)${NC}"
        echo ""
        read -p "Press [Enter] to continue..."
        /usr/local/sbin/tunneling/menu/bot-menu.sh
        exit 1
    fi
    
    # Start bot
    echo -e "${YELLOW}Starting bot...${NC}"
    systemctl start telegram-bot
    sleep 2
    
    if systemctl is-active --quiet telegram-bot; then
        echo -e "${GREEN}✓ Bot started successfully!${NC}"
    else
        echo -e "${RED}✗ Failed to start bot${NC}"
        echo ""
        echo -e "${YELLOW}Error logs:${NC}"
        journalctl -u telegram-bot -n 20 --no-pager
    fi
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/bot-menu.sh
