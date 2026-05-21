#!/bin/bash
# Set Quota Limit for ZIVPN Account

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        SET QUOTA LIMIT (ZIVPN)         ${NC}"
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

read -p "Quota Limit in GB (e.g., 50): " quota
if ! [[ "$quota" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Quota must be numeric.${NC}"
    exit 1
fi

jq --arg quota "$quota" '.limit_quota = ($quota | tonumber)' "$json_file" > "/tmp/${username}.json"
mv "/tmp/${username}.json" "$json_file"

echo ""
echo -e "${GREEN}✓ Quota limit set to ${quota}GB for $username${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
