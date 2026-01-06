#!/bin/bash
# Lock VMESS Account

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}           LOCK VMESS ACCOUNT            ${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to lock: " username

json_file="/etc/tunneling/vmess/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

# Add locked flag
jq '.locked = true' $json_file > /tmp/${username}.json
mv /tmp/${username}.json $json_file

echo ""
echo -e "${GREEN}✓ Account $username has been locked${NC}"
echo -e "${YELLOW}Note: XRAY config reload required${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
