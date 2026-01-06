#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              SYSTEM MANAGEMENT MENU                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Check Running Services"
echo -e "${GREEN}  [2]${NC} Restart All Services"
echo -e "${GREEN}  [3]${NC} Restart Specific Service"
echo -e "${GREEN}  [4]${NC} Monitor VPS (CPU, RAM, Bandwidth)"
echo -e "${GREEN}  [5]${NC} Speedtest"
echo -e "${GREEN}  [6]${NC} Delete All Expired Accounts"
echo -e "${GREEN}  [7]${NC} Limit Speed VPS"
echo -e "${GREEN}  [8]${NC} Monitor Service Status"
echo -e "${GREEN}  [9]${NC} Check Logs"
echo -e "${GREEN} [10]${NC} Auto Reboot Settings"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-10]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/check-services.sh
        ;;
    2)
        /usr/local/sbin/tunneling/restart-all.sh
        ;;
    3)
        /usr/local/sbin/tunneling/restart-service.sh
        ;;
    4)
        /usr/local/sbin/tunneling/monitor-vps.sh
        ;;
    5)
        /usr/local/sbin/tunneling/speedtest.sh
        ;;
    6)
        /usr/local/sbin/tunneling/delete-all-expired.sh
        ;;
    7)
        /usr/local/sbin/tunneling/limit-speed.sh
        ;;
    8)
        /usr/local/sbin/tunneling/monitor-service.sh
        ;;
    9)
        /usr/local/sbin/tunneling/check-logs.sh
        ;;
    10)
        /usr/local/sbin/tunneling/auto-reboot-settings.sh
        ;;
    0)
        /usr/local/sbin/tunneling/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/system-menu.sh
        ;;
esac
