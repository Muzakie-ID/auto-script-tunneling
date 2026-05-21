#!/bin/bash
# Check ZIVPN UDP Service Status

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      ZIVPN UDP SERVICE STATUS          ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

DOMAIN=$(cat /root/domain.txt 2>/dev/null || echo "N/A")

if systemctl list-unit-files | grep -q "^zivpn\.service"; then
    if systemctl is-active --quiet zivpn; then
        STATUS="RUNNING"
        COLOR="$GREEN"
    else
        STATUS="STOPPED"
        COLOR="$RED"
    fi
else
    STATUS="NOT INSTALLED"
    COLOR="$RED"
fi

echo -e "Service      : ${COLOR}${STATUS}${NC}"
echo -e "UDP Endpoint : ${YELLOW}${DOMAIN}:5667${NC}"
echo -e "UDP Forward  : ${YELLOW}6000-19999/udp -> 5667/udp${NC}"

if [ -f /etc/zivpn/config.json ]; then
    PASS_COUNT=$(jq '.auth.config | length' /etc/zivpn/config.json 2>/dev/null || echo "0")
    echo -e "Auth Entries : ${YELLOW}${PASS_COUNT}${NC}"
else
    echo -e "Auth Entries : ${RED}Config not found${NC}"
fi

echo ""
echo -e "${CYAN}Systemd (last 5 lines):${NC}"
if systemctl list-unit-files | grep -q "^zivpn\.service"; then
    systemctl --no-pager -l status zivpn | tail -n 5
else
    echo "zivpn.service not found"
fi

echo ""
read -n 1 -s -r -p "Press any key to continue..."
