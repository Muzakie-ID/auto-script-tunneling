#!/bin/bash
# Unlock TROJAN Account

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         UNLOCK TROJAN ACCOUNT           ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to unlock: " username

json_file="/etc/tunneling/TROJAN/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

# Remove locked flag
jq '.locked = false' $json_file > /tmp/${username}.json
mv /tmp/${username}.json $json_file

echo ""
echo -e "${GREEN}✓ Account $username has been unlocked${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

