#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                    SSH MENU                        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Create SSH Account"
echo -e "${GREEN}  [2]${NC} Trial SSH Account ${YELLOW}(1 Hour)${NC}"
echo -e "${GREEN}  [3]${NC} Renew SSH Account"
echo -e "${GREEN}  [4]${NC} Delete SSH Account"
echo -e "${GREEN}  [5]${NC} Check SSH Login"
echo -e "${GREEN}  [6]${NC} List All SSH Accounts"
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
        /usr/local/sbin/tunneling/ssh-create.sh
        ;;
    2)
        /usr/local/sbin/tunneling/ssh-trial.sh
        ;;
    3)
        /usr/local/sbin/tunneling/ssh-renew.sh
        ;;
    4)
        /usr/local/sbin/tunneling/ssh-delete.sh
        ;;
    5)
        /usr/local/sbin/tunneling/ssh-check.sh
        ;;
    6)
        /usr/local/sbin/tunneling/ssh-list.sh
        ;;
    7)
        /usr/local/sbin/tunneling/ssh-delete-expired.sh
        ;;
    8)
        /usr/local/sbin/tunneling/ssh-lock.sh
        ;;
    9)
        /usr/local/sbin/tunneling/ssh-unlock.sh
        ;;
    10)
        /usr/local/sbin/tunneling/ssh-detail.sh
        ;;
    11)
        /usr/local/sbin/tunneling/ssh-limit-ip.sh
        ;;
    12)
        /usr/local/sbin/tunneling/ssh-limit-quota.sh
        ;;
    0)
        /usr/local/sbin/tunneling/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/ssh-menu.sh
        ;;
esac
