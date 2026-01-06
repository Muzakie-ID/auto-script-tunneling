#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                BOT TELEGRAM MENU                    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Setup Bot Telegram"
echo -e "${GREEN}  [2]${NC} Start Bot"
echo -e "${GREEN}  [3]${NC} Stop Bot"
echo -e "${GREEN}  [4]${NC} Restart Bot"
echo -e "${GREEN}  [5]${NC} Bot Status"
echo -e "${GREEN}  [6]${NC} Setup Auto Order"
echo -e "${GREEN}  [7]${NC} Payment Settings (QRIS)"
echo -e "${GREEN}  [8]${NC} Price List Settings"
echo -e "${GREEN}  [9]${NC} Notification Settings"
echo -e "${GREEN} [10]${NC} Test Bot"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-10]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/bot-setup.sh
        ;;
    2)
        /usr/local/sbin/tunneling/bot-start.sh
        ;;
    3)
        /usr/local/sbin/tunneling/bot-stop.sh
        ;;
    4)
        /usr/local/sbin/tunneling/bot-restart.sh
        ;;
    5)
        /usr/local/sbin/tunneling/bot-status.sh
        ;;
    6)
        /usr/local/sbin/tunneling/bot-auto-order.sh
        ;;
    7)
        /usr/local/sbin/tunneling/bot-payment.sh
        ;;
    8)
        /usr/local/sbin/tunneling/bot-price.sh
        ;;
    9)
        /usr/local/sbin/tunneling/bot-notification.sh
        ;;
    10)
        /usr/local/sbin/tunneling/bot-test.sh
        ;;
    0)
        /usr/local/sbin/tunneling/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/bot-menu.sh
        ;;
esac
