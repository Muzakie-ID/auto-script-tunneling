#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get system info
DOMAIN=$(cat /root/domain.txt)
IP=$(curl -s ifconfig.me)
RAM=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')
CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\n", $(NF-2)}')
UPTIME=$(uptime -p | cut -d " " -f 2-10)

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           AUTOSCRIPT TUNNELING VPN PANEL           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW} Domain    ${NC}: ${GREEN}$DOMAIN${NC}"
echo -e "${YELLOW} IP Server ${NC}: ${GREEN}$IP${NC}"
echo -e "${YELLOW} RAM Usage ${NC}: ${GREEN}$RAM${NC}"
echo -e "${YELLOW} CPU Load  ${NC}: ${GREEN}$CPU${NC}"
echo -e "${YELLOW} Uptime    ${NC}: ${GREEN}$UPTIME${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}             [ PROTOCOL MENU ]${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} SSH Menu ${YELLOW}(WS, SSL, UDP)${NC}"
echo -e "${GREEN}  [2]${NC} VMESS Menu"
echo -e "${GREEN}  [3]${NC} VLESS Menu"
echo -e "${GREEN}  [4]${NC} TROJAN Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}             [ SYSTEM MENU ]${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [5]${NC} System Management"
echo -e "${GREEN}  [6]${NC} Backup & Restore"
echo -e "${GREEN}  [7]${NC} Bot Telegram"
echo -e "${GREEN}  [8]${NC} Settings"
echo -e "${GREEN}  [9]${NC} Information & Status"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Exit"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-9]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/ssh-menu.sh
        ;;
    2)
        /usr/local/sbin/tunneling/vmess-menu.sh
        ;;
    3)
        /usr/local/sbin/tunneling/vless-menu.sh
        ;;
    4)
        /usr/local/sbin/tunneling/trojan-menu.sh
        ;;
    5)
        /usr/local/sbin/tunneling/system-menu.sh
        ;;
    6)
        /usr/local/sbin/tunneling/backup-menu.sh
        ;;
    7)
        /usr/local/sbin/tunneling/bot-menu.sh
        ;;
    8)
        /usr/local/sbin/tunneling/settings-menu.sh
        ;;
    9)
        /usr/local/sbin/tunneling/info-menu.sh
        ;;
    0)
        clear
        echo -e "${GREEN}Thank you for using AUTOSCRIPT TUNNELING VPN${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/main-menu.sh
        ;;
esac
