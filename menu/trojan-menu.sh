#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                  TROJAN MENU                        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Create TROJAN Account"
echo -e "${GREEN}  [2]${NC} Trial TROJAN Account ${YELLOW}(1 Hour)${NC}"
echo -e "${GREEN}  [3]${NC} Renew TROJAN Account"
echo -e "${GREEN}  [4]${NC} Delete TROJAN Account"
echo -e "${GREEN}  [5]${NC} Check TROJAN Login"
echo -e "${GREEN}  [6]${NC} List All TROJAN Accounts"
echo -e "${GREEN}  [7]${NC} Delete Expired Accounts"
echo -e "${GREEN}  [8]${NC} Lock Account"
echo -e "${GREEN}  [9]${NC} Unlock Account"
echo -e "${GREEN} [10]${NC} Account Details"
echo -e "${GREEN} [11]${NC} Set Limit IP"
echo -e "${GREEN} [12]${NC} Set Limit Quota"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-12]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/trojan-create.sh
        ;;
    2)
        /usr/local/sbin/tunneling/trojan-trial.sh
        ;;
    3)
        /usr/local/sbin/tunneling/trojan-renew.sh
        ;;
    4)
        /usr/local/sbin/tunneling/trojan-delete.sh
        ;;
    5)
        /usr/local/sbin/tunneling/trojan-check.sh
        ;;
    6)
        /usr/local/sbin/tunneling/trojan-list.sh
        ;;
    7)
        /usr/local/sbin/tunneling/trojan-delete-expired.sh
        ;;
    8)
        /usr/local/sbin/tunneling/trojan-lock.sh
        ;;
    9)
        /usr/local/sbin/tunneling/trojan-unlock.sh
        ;;
    10)
        /usr/local/sbin/tunneling/trojan-detail.sh
        ;;
    11)
        /usr/local/sbin/tunneling/trojan-limit-ip.sh
        ;;
    12)
        /usr/local/sbin/tunneling/trojan-limit-quota.sh
        ;;
    0)
        /usr/local/sbin/tunneling/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/trojan-menu.sh
        ;;
esac
