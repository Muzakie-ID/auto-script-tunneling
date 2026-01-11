#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                CHECK LOGS                        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Select log to view:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} SSH Logs"
echo -e "${GREEN}  [2]${NC} Dropbear Logs"
echo -e "${GREEN}  [3]${NC} Stunnel Logs"
echo -e "${GREEN}  [4]${NC} Squid Logs"
echo -e "${GREEN}  [5]${NC} XRAY Logs"
echo -e "${GREEN}  [6]${NC} NGINX Access Logs"
echo -e "${GREEN}  [7]${NC} NGINX Error Logs"
echo -e "${GREEN}  [8]${NC} System Logs (syslog)"
echo -e "${GREEN}  [9]${NC} Authentication Logs"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select log [0-9]: " log

case $log in
    1)
        echo ""
        echo -e "${YELLOW}SSH Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        journalctl -u ssh -n 50 --no-pager
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Dropbear Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        journalctl -u dropbear -n 50 --no-pager
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Stunnel Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        journalctl -u stunnel4 -n 50 --no-pager
        ;;
    4)
        echo ""
        echo -e "${YELLOW}Squid Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [ -f /var/log/squid/access.log ]; then
            tail -n 50 /var/log/squid/access.log
        else
            echo -e "${RED}Log file not found${NC}"
        fi
        ;;
    5)
        echo ""
        echo -e "${YELLOW}XRAY Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        journalctl -u xray -n 50 --no-pager
        ;;
    6)
        echo ""
        echo -e "${YELLOW}NGINX Access Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [ -f /var/log/nginx/access.log ]; then
            tail -n 50 /var/log/nginx/access.log
        else
            echo -e "${RED}Log file not found${NC}"
        fi
        ;;
    7)
        echo ""
        echo -e "${YELLOW}NGINX Error Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        if [ -f /var/log/nginx/error.log ]; then
            tail -n 50 /var/log/nginx/error.log
        else
            echo -e "${RED}Log file not found${NC}"
        fi
        ;;
    8)
        echo ""
        echo -e "${YELLOW}System Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        tail -n 50 /var/log/syslog
        ;;
    9)
        echo ""
        echo -e "${YELLOW}Authentication Logs (last 50 lines):${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        tail -n 50 /var/log/auth.log
        ;;
    0)
        /usr/local/sbin/tunneling/menu/system-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/check-logs.sh
        exit 0
        ;;
esac

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/system-menu.sh
