#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                   VIEW LOGS                         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Select Log to View:${NC}"
echo ""
echo -e "${YELLOW}System Logs:${NC}"
echo -e "  ${GREEN}[1]${NC}  System Log (syslog)"
echo -e "  ${GREEN}[2]${NC}  Authentication Log (auth.log)"
echo -e "  ${GREEN}[3]${NC}  Kernel Log (dmesg)"
echo ""
echo -e "${YELLOW}Service Logs:${NC}"
echo -e "  ${GREEN}[4]${NC}  Nginx Access Log"
echo -e "  ${GREEN}[5]${NC}  Nginx Error Log"
echo -e "  ${GREEN}[6]${NC}  XRAY Access Log"
echo -e "  ${GREEN}[7]${NC}  XRAY Error Log"
echo -e "  ${GREEN}[8]${NC}  SSH Service Log"
echo -e "  ${GREEN}[9]${NC}  Dropbear Log"
echo -e "  ${GREEN}[10]${NC} Stunnel Log"
echo -e "  ${GREEN}[11]${NC} Squid Access Log"
echo -e "  ${GREEN}[12]${NC} Squid Cache Log"
echo ""
echo -e "${YELLOW}Application Logs:${NC}"
echo -e "  ${GREEN}[13]${NC} Telegram Bot Log"
echo -e "  ${GREEN}[14]${NC} Auto Backup Log"
echo -e "  ${GREEN}[15]${NC} Cron Log"
echo ""
echo -e "${YELLOW}Special:${NC}"
echo -e "  ${GREEN}[16]${NC} Let's Encrypt Log"
echo -e "  ${GREEN}[17]${NC} Fail2Ban Log"
echo -e "  ${GREEN}[18]${NC} UFW Firewall Log"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC}  Back to Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select log [0-18]: " choice

case $choice in
    1)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}         SYSTEM LOG (syslog)              ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        tail -f /var/log/syslog
        ;;
    2)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}      AUTHENTICATION LOG (auth.log)       ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        tail -f /var/log/auth.log
        ;;
    3)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}          KERNEL LOG (dmesg)              ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo ""
        dmesg | tail -100
        echo ""
        read -p "Press [Enter] to continue..."
        bash $0
        ;;
    4)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}         NGINX ACCESS LOG                 ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        tail -f /var/log/nginx/access.log
        ;;
    5)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}          NGINX ERROR LOG                 ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        tail -f /var/log/nginx/error.log
        ;;
    6)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}          XRAY ACCESS LOG                 ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        if [ -f /var/log/xray/access.log ]; then
            tail -f /var/log/xray/access.log
        else
            echo -e "${RED}Log file not found!${NC}"
            sleep 2
            bash $0
        fi
        ;;
    7)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}          XRAY ERROR LOG                  ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        if [ -f /var/log/xray/error.log ]; then
            tail -f /var/log/xray/error.log
        else
            echo -e "${RED}Log file not found!${NC}"
            sleep 2
            bash $0
        fi
        ;;
    8)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}         SSH SERVICE LOG                  ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        journalctl -u ssh -f
        ;;
    9)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}          DROPBEAR LOG                    ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        journalctl -u dropbear -f
        ;;
    10)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}          STUNNEL LOG                     ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        journalctl -u stunnel4 -f
        ;;
    11)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}         SQUID ACCESS LOG                 ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        if [ -f /var/log/squid/access.log ]; then
            tail -f /var/log/squid/access.log
        else
            echo -e "${RED}Log file not found!${NC}"
            sleep 2
            bash $0
        fi
        ;;
    12)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}         SQUID CACHE LOG                  ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        if [ -f /var/log/squid/cache.log ]; then
            tail -f /var/log/squid/cache.log
        else
            echo -e "${RED}Log file not found!${NC}"
            sleep 2
            bash $0
        fi
        ;;
    13)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}        TELEGRAM BOT LOG                  ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        journalctl -u telegram-bot -f
        ;;
    14)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}         AUTO BACKUP LOG                  ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo ""
        if [ -f /var/log/tunneling/auto-backup.log ]; then
            cat /var/log/tunneling/auto-backup.log | tail -100
        else
            echo -e "${RED}Log file not found!${NC}"
        fi
        echo ""
        read -p "Press [Enter] to continue..."
        bash $0
        ;;
    15)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}            CRON LOG                      ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo ""
        grep CRON /var/log/syslog | tail -50
        echo ""
        read -p "Press [Enter] to continue..."
        bash $0
        ;;
    16)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}       LET'S ENCRYPT LOG                  ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo ""
        if [ -f /var/log/letsencrypt/letsencrypt.log ]; then
            cat /var/log/letsencrypt/letsencrypt.log | tail -100
        else
            echo -e "${RED}Log file not found!${NC}"
        fi
        echo ""
        read -p "Press [Enter] to continue..."
        bash $0
        ;;
    17)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}          FAIL2BAN LOG                    ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        if [ -f /var/log/fail2ban.log ]; then
            tail -f /var/log/fail2ban.log
        else
            echo -e "${RED}Log file not found!${NC}"
            sleep 2
            bash $0
        fi
        ;;
    18)
        clear
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}        UFW FIREWALL LOG                  ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════${NC}"
        echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
        echo ""
        if [ -f /var/log/ufw.log ]; then
            tail -f /var/log/ufw.log
        else
            echo -e "${RED}Log file not found!${NC}"
            sleep 2
            bash $0
        fi
        ;;
    0)
        /usr/local/sbin/tunneling/menu/system-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        bash $0
        ;;
esac
