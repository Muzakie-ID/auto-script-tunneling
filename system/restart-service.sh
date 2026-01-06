#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           RESTART SPECIFIC SERVICE               ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Available Services:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} SSH"
echo -e "${GREEN}  [2]${NC} Dropbear"
echo -e "${GREEN}  [3]${NC} Stunnel"
echo -e "${GREEN}  [4]${NC} Squid"
echo -e "${GREEN}  [5]${NC} XRAY"
echo -e "${GREEN}  [6]${NC} NGINX"
echo -e "${GREEN}  [7]${NC} Cron"
echo -e "${GREEN}  [8]${NC} Netfilter"
echo -e "${GREEN}  [9]${NC} fail2ban"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select service [0-9]: " service

case $service in
    1)
        echo -e "${YELLOW}Restarting SSH...${NC}"
        systemctl restart ssh
        if systemctl is-active --quiet ssh; then
            echo -e "${GREEN}✓ SSH restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart SSH${NC}"
        fi
        ;;
    2)
        echo -e "${YELLOW}Restarting Dropbear...${NC}"
        systemctl restart dropbear
        if systemctl is-active --quiet dropbear; then
            echo -e "${GREEN}✓ Dropbear restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart Dropbear${NC}"
        fi
        ;;
    3)
        echo -e "${YELLOW}Restarting Stunnel...${NC}"
        systemctl restart stunnel4
        if systemctl is-active --quiet stunnel4; then
            echo -e "${GREEN}✓ Stunnel restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart Stunnel${NC}"
        fi
        ;;
    4)
        echo -e "${YELLOW}Restarting Squid...${NC}"
        systemctl restart squid
        if systemctl is-active --quiet squid; then
            echo -e "${GREEN}✓ Squid restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart Squid${NC}"
        fi
        ;;
    5)
        echo -e "${YELLOW}Restarting XRAY...${NC}"
        systemctl restart xray
        if systemctl is-active --quiet xray; then
            echo -e "${GREEN}✓ XRAY restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart XRAY${NC}"
        fi
        ;;
    6)
        echo -e "${YELLOW}Restarting NGINX...${NC}"
        systemctl restart nginx
        if systemctl is-active --quiet nginx; then
            echo -e "${GREEN}✓ NGINX restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart NGINX${NC}"
        fi
        ;;
    7)
        echo -e "${YELLOW}Restarting Cron...${NC}"
        systemctl restart cron
        if systemctl is-active --quiet cron; then
            echo -e "${GREEN}✓ Cron restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart Cron${NC}"
        fi
        ;;
    8)
        echo -e "${YELLOW}Restarting Netfilter...${NC}"
        systemctl restart netfilter-persistent
        if systemctl is-active --quiet netfilter-persistent; then
            echo -e "${GREEN}✓ Netfilter restarted successfully${NC}"
        else
            echo -e "${RED}✗ Failed to restart Netfilter${NC}"
        fi
        ;;
    9)
        echo -e "${YELLOW}Restarting fail2ban...${NC}"
        if systemctl is-enabled --quiet fail2ban 2>/dev/null; then
            systemctl restart fail2ban
            if systemctl is-active --quiet fail2ban; then
                echo -e "${GREEN}✓ fail2ban restarted successfully${NC}"
            else
                echo -e "${RED}✗ Failed to restart fail2ban${NC}"
            fi
        else
            echo -e "${YELLOW}✓ fail2ban not installed${NC}"
        fi
        ;;
    0)
        /usr/local/sbin/tunneling/system-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/restart-service.sh
        exit 0
        ;;
esac

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/system-menu.sh
