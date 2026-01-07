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
    /usr/local/sbin/tunneling/bot-menu.sh
    exit 1
fi

# Check Python dependencies
echo -e "${CYAN}Checking Python dependencies...${NC}"
if ! python3 -c "import telebot" 2>/dev/null; then
    echo -e "${YELLOW}Installing missing Python packages...${NC}"
    
    # Update package manager
    apt-get update > /dev/null 2>&1
    
    # Install pip if not exists
    if ! command -v pip3 &> /dev/null; then
        echo -e "${YELLOW}Installing pip3...${NC}"
        apt-get install -y python3-pip > /dev/null 2>&1
    fi
    
    # Try multiple installation methods
    pip3 install pytelegrambotapi requests 2>&1 | grep -v "WARNING" || \
    python3 -m pip install pytelegrambotapi requests 2>&1 | grep -v "WARNING" || \
    apt-get install -y python3-pip && pip3 install pytelegrambotapi requests 2>&1 | grep -v "WARNING"
    
    sleep 2
    
    # Verify installation
    if ! python3 -c "import telebot" 2>/dev/null; then
        echo -e "${RED}✗ Failed to install Python packages${NC}"
        echo ""
        echo -e "${YELLOW}Please try manual installation:${NC}"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install -y python3-pip"
        echo "  sudo pip3 install pytelegrambotapi requests"
        echo ""
        read -p "Press [Enter] to continue..."
        /usr/local/sbin/tunneling/bot-menu.sh
        exit 1
    fi
    echo -e "${GREEN}✓ Dependencies installed${NC}"
fi
echo ""

# Check if bot is already running
if systemctl is-active --quiet telegram-bot; then
    echo -e "${YELLOW}Bot is already running!${NC}"
    echo ""
    systemctl status telegram-bot --no-pager
else
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
/usr/local/sbin/tunneling/bot-menu.sh
