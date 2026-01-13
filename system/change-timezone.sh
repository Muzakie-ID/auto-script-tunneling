#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              CHANGE TIMEZONE                      ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show current timezone
CURRENT_TZ=$(timedatectl | grep "Time zone" | awk '{print $3}')
echo -e "${YELLOW}Current Timezone:${NC} $CURRENT_TZ"
echo ""

echo -e "${YELLOW}Available Timezones:${NC}"
echo "  [1] Asia/Jakarta (WIB - GMT+7)"
echo "  [2] Asia/Makassar (WITA - GMT+8)"
echo "  [3] Asia/Jayapura (WIT - GMT+9)"
echo "  [4] Asia/Singapore (SGT - GMT+8)"
echo "  [5] Asia/Kuala_Lumpur (MYT - GMT+8)"
echo "  [6] Custom"
echo ""
read -p "Select [1-6]: " choice

case $choice in
    1)
        timezone="Asia/Jakarta"
        ;;
    2)
        timezone="Asia/Makassar"
        ;;
    3)
        timezone="Asia/Jayapura"
        ;;
    4)
        timezone="Asia/Singapore"
        ;;
    5)
        timezone="Asia/Kuala_Lumpur"
        ;;
    6)
        read -p "Enter timezone (e.g., America/New_York): " timezone
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 2
        /usr/local/sbin/tunneling/menu/settings-menu.sh
        exit 1
        ;;
esac

# Set timezone
if timedatectl set-timezone "$timezone" 2>/dev/null; then
    echo ""
    echo -e "${GREEN}✓ Timezone changed to $timezone${NC}"
    echo -e "${YELLOW}Current Time:${NC} $(date)"
else
    echo ""
    echo -e "${RED}✗ Failed to set timezone!${NC}"
    echo -e "${YELLOW}Check timezone name is correct${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/settings-menu.sh
