#!/bin/bash
# Set IP Limit for ZIVPN Account

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         SET IP LIMIT (ZIVPN)           ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Existing ZIVPN Accounts:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d /etc/tunneling/zivpn ] && [ "$(ls -A /etc/tunneling/zivpn/*.json 2>/dev/null)" ]; then
    for user_json in /etc/tunneling/zivpn/*.json; do
        username_list=$(jq -r '.username' "$user_json" 2>/dev/null)
        echo -e "  • $username_list"
    done
else
    echo -e "${RED}  No accounts found${NC}"
fi
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username

json_file="/etc/tunneling/zivpn/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

read -p "IP Limit (e.g., 2): " limit
if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}IP limit must be numeric.${NC}"
    exit 1
fi

jq --arg limit "$limit" '.limit_ip = ($limit | tonumber)' "$json_file" > "/tmp/${username}.json"
mv "/tmp/${username}.json" "$json_file"

echo ""
echo -e "${GREEN}✓ IP limit set to $limit for $username${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
