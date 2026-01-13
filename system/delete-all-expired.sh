#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}         DELETE ALL EXPIRED ACCOUNTS              ${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}This will delete all expired accounts from all protocols!${NC}"
echo ""
read -p "Are you sure? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo -e "${GREEN}Operation cancelled${NC}"
    sleep 1
    /usr/local/sbin/tunneling/menu/system-menu.sh
    exit 0
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Deleting expired accounts...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Delete expired SSH accounts
echo -e "${CYAN}[1/4] Checking SSH accounts...${NC}"
if [ -f /usr/local/sbin/tunneling/ssh-delete-expired.sh ]; then
    bash /usr/local/sbin/tunneling/ssh-delete-expired.sh
    echo -e "${GREEN}✓ SSH accounts checked${NC}"
else
    echo -e "${YELLOW}✓ SSH delete script not found${NC}"
fi
echo ""

# Delete expired VMESS accounts
echo -e "${CYAN}[2/4] Checking VMESS accounts...${NC}"
if [ -f /usr/local/sbin/tunneling/vmess-delete-expired.sh ]; then
    bash /usr/local/sbin/tunneling/vmess-delete-expired.sh
    echo -e "${GREEN}✓ VMESS accounts checked${NC}"
else
    echo -e "${YELLOW}✓ VMESS delete script not found${NC}"
fi
echo ""

# Delete expired VLESS accounts
echo -e "${CYAN}[3/4] Checking VLESS accounts...${NC}"
if [ -f /usr/local/sbin/tunneling/vless-delete-expired.sh ]; then
    bash /usr/local/sbin/tunneling/vless-delete-expired.sh
    echo -e "${GREEN}✓ VLESS accounts checked${NC}"
else
    echo -e "${YELLOW}✓ VLESS delete script not found${NC}"
fi
echo ""

# Delete expired TROJAN accounts
echo -e "${CYAN}[4/4] Checking TROJAN accounts...${NC}"
if [ -f /usr/local/sbin/tunneling/trojan-delete-expired.sh ]; then
    bash /usr/local/sbin/tunneling/trojan-delete-expired.sh
    echo -e "${GREEN}✓ TROJAN accounts checked${NC}"
else
    echo -e "${YELLOW}✓ TROJAN delete script not found${NC}"
fi
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}All expired accounts have been deleted!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/system-menu.sh
