#!/bin/bash
# Check VMESS Active Connections

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        ACTIVE VMESS CONNECTIONS         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check XRAY logs for active connections
if [ -f /var/log/xray/access.log ]; then
    echo -e "${GREEN}Recent connections (last 50):${NC}"
    tail -n 50 /var/log/xray/access.log | grep "vmess" | tail -10
else
    echo -e "${YELLOW}XRAY access log not found${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Note: Install XRAY with logging enabled for detailed stats${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
