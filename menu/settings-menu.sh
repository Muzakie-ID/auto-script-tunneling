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
        bash /usr/local/sbin/tunneling/system/change-domain.sh
        ;;
    2)
        bash /usr/local/sbin/tunneling/system/change-banner.sh
        ;;
    3)
        bash /usr/local/sbin/tunneling/system/change-port.sh
        ;;
    4)
        bash /usr/local/sbin/tunneling/system/change-timezone.sh
        ;;
    5)
        bash /usr/local/sbin/tunneling/system/fix-error-domain.sh
        ;;
    6)
        bash /usr/local/sbin/tunneling/system/fix-error-proxy.sh
        ;;
    7)
        bash /usr/local/sbin/tunneling/system/renew-ssl.sh
        ;;
    8)
        bash /usr/local/sbin/tunneling/system/auto-record-wildcard.sh
        ;;
    9)
        bash /usr/local/sbin/tunneling/system/limit-speed-settings.sh
        ;;
    10)
        bash /usr/local/sbin/tunneling/system/reset-settings.sh
        ;;
    0)
        /usr/local/sbin/tunneling/menu/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/menu/settings-menu.sh
        ;;
esac
