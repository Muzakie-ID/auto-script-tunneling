#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                   VLESS MENU                        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Create VLESS Account"
echo -e "${GREEN}  [2]${NC} Trial VLESS Account ${YELLOW}(1 Hour)${NC}"
echo -e "${GREEN}  [3]${NC} Renew VLESS Account"
echo -e "${GREEN}  [4]${NC} Delete VLESS Account"
echo -e "${GREEN}  [5]${NC} Check VLESS Login"
echo -e "${GREEN}  [6]${NC} List All VLESS Accounts"
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
        /usr/local/sbin/tunneling/xray/vless-create.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    2)
        /usr/local/sbin/tunneling/xray/vless-trial.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    3)
        /usr/local/sbin/tunneling/xray/vless-renew.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    4)
        /usr/local/sbin/tunneling/xray/vless-delete.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    5)
        /usr/local/sbin/tunneling/xray/vless-check.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    6)
        /usr/local/sbin/tunneling/xray/vless-list.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    7)
        /usr/local/sbin/tunneling/xray/vless-delete-expired.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    8)
        /usr/local/sbin/tunneling/xray/vless-lock.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    9)
        /usr/local/sbin/tunneling/xray/vless-unlock.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    10)
        /usr/local/sbin/tunneling/xray/vless-details.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    11)
        /usr/local/sbin/tunneling/xray/vless-limit-ip.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    12)
        /usr/local/sbin/tunneling/xray/vless-limit-quota.sh
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
    0)
        /usr/local/sbin/tunneling/menu/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/menu/vless-menu.sh
        ;;
esac

