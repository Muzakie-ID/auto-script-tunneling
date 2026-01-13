#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                CHECK SERVICES STATUS                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to check service status
check_service() {
    if systemctl is-active --quiet $1; then
        echo -e "${GREEN}[✓]${NC} $1 is ${GREEN}running${NC}"
    else
        echo -e "${RED}[✗]${NC} $1 is ${RED}stopped${NC}"
    fi
}

echo -e "${YELLOW}Core Services:${NC}"
check_service ssh
check_service dropbear
check_service stunnel4
check_service squid
check_service nginx
check_service xray
check_service fail2ban

echo ""
echo -e "${YELLOW}Additional Services:${NC}"
check_service telegram-bot
check_service cron
check_service vnstat

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/menu/system-menu.sh
