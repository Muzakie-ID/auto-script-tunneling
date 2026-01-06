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
echo -e "${GREEN}            SETUP AUTO ORDER                       ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Bot not configured yet!${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    /usr/local/sbin/tunneling/bot-menu.sh
    exit 1
fi

# Get current status
CURRENT_STATUS=$(jq -r '.auto_order // "false"' $CONFIG_FILE)

echo -e "${YELLOW}Auto Order Settings:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Current Status: ${CYAN}$CURRENT_STATUS${NC}"
echo ""
echo -e "${YELLOW}Description:${NC}"
echo "When enabled, orders will be automatically processed"
echo "after payment confirmation without admin approval."
echo ""
echo -e "${YELLOW}When disabled:${NC}"
echo "Admin must manually approve each order via bot."
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}  [1]${NC} Enable Auto Order"
echo -e "${GREEN}  [2]${NC} Disable Auto Order"
echo -e "${RED}  [0]${NC} Back"
echo ""
read -p "Select option [0-2]: " option

case $option in
    1)
        jq '.auto_order = true' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
        echo ""
        echo -e "${GREEN}✓ Auto Order enabled!${NC}"
        echo ""
        echo -e "${YELLOW}Restarting bot...${NC}"
        systemctl restart telegram-bot
        sleep 2
        ;;
    2)
        jq '.auto_order = false' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
        echo ""
        echo -e "${GREEN}✓ Auto Order disabled!${NC}"
        echo ""
        echo -e "${YELLOW}Restarting bot...${NC}"
        systemctl restart telegram-bot
        sleep 2
        ;;
    0)
        /usr/local/sbin/tunneling/bot-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        ;;
esac

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/bot-menu.sh
