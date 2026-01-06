#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                  SETTINGS MENU                      ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Change Domain"
echo -e "${GREEN}  [2]${NC} Change Banner"
echo -e "${GREEN}  [3]${NC} Change Port"
echo -e "${GREEN}  [4]${NC} Change Timezone"
echo -e "${GREEN}  [5]${NC} Fix Error Domain"
echo -e "${GREEN}  [6]${NC} Fix Error Proxy"
echo -e "${GREEN}  [7]${NC} Renew SSL Certificate"
echo -e "${GREEN}  [8]${NC} Auto Record Wildcard Domain"
echo -e "${GREEN}  [9]${NC} Limit Speed Settings"
echo -e "${GREEN} [10]${NC} Reset Settings"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-10]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/change-domain.sh
        ;;
    2)
        /usr/local/sbin/tunneling/change-banner.sh
        ;;
    3)
        /usr/local/sbin/tunneling/change-port.sh
        ;;
    4)
        /usr/local/sbin/tunneling/change-timezone.sh
        ;;
    5)
        /usr/local/sbin/tunneling/fix-domain.sh
        ;;
    6)
        /usr/local/sbin/tunneling/fix-proxy.sh
        ;;
    7)
        /usr/local/sbin/tunneling/renew-ssl.sh
        ;;
    8)
        /usr/local/sbin/tunneling/auto-record-domain.sh
        ;;
    9)
        /usr/local/sbin/tunneling/limit-speed-settings.sh
        ;;
    10)
        /usr/local/sbin/tunneling/reset-settings.sh
        ;;
    0)
        /usr/local/sbin/tunneling/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/settings-menu.sh
        ;;
esac
