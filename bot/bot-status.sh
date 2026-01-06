#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="/etc/tunneling/bot/config.json"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              BOT STATUS                           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if bot is configured
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}✗ Bot not configured${NC}"
    echo -e "${YELLOW}Please run Setup Bot Telegram first (option 1)${NC}"
else
    echo -e "${YELLOW}Configuration:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    TOKEN=$(jq -r '.token // "Not set"' $CONFIG_FILE)
    ADMIN_ID=$(jq -r '.admin_id // "Not set"' $CONFIG_FILE)
    AUTO_ORDER=$(jq -r '.auto_order // "false"' $CONFIG_FILE)
    
    echo -e "Token     : ${TOKEN:0:20}..."
    echo -e "Admin ID  : $ADMIN_ID"
    echo -e "Auto Order: $AUTO_ORDER"
    echo ""
    
    # Check service status
    echo -e "${YELLOW}Service Status:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if systemctl is-active --quiet telegram-bot; then
        echo -e "${GREEN}✓ Bot is running${NC}"
        
        # Get uptime
        UPTIME=$(systemctl show telegram-bot --property=ActiveEnterTimestamp --value)
        if [ -n "$UPTIME" ]; then
            echo -e "Started   : $UPTIME"
        fi
        
        # Get PID
        PID=$(systemctl show telegram-bot --property=MainPID --value)
        if [ "$PID" != "0" ]; then
            echo -e "PID       : $PID"
            
            # Get memory usage
            MEM=$(ps -p $PID -o rss= 2>/dev/null)
            if [ -n "$MEM" ]; then
                MEM_MB=$(echo "scale=2; $MEM/1024" | bc)
                echo -e "Memory    : ${MEM_MB} MB"
            fi
        fi
    else
        echo -e "${RED}✗ Bot is not running${NC}"
    fi
    
    echo ""
    
    # Show recent logs
    echo -e "${YELLOW}Recent Logs (last 10):${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    journalctl -u telegram-bot -n 10 --no-pager 2>/dev/null || echo -e "${YELLOW}No logs available${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/bot-menu.sh
