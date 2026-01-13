#!/bin/bash
# Set Quota Limit for VLESS Account

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        SET QUOTA LIMIT (VLESS)         ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show existing accounts
echo -e "${YELLOW}Existing VLESS Accounts:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d /etc/tunneling/vless ] && [ "$(ls -A /etc/tunneling/vless/*.json 2>/dev/null)" ]; then
    for user_json in /etc/tunneling/vless/*.json; do
        username_list=$(jq -r '.username' $user_json 2>/dev/null)
        echo -e "  • $username_list"
    done
else
    echo -e "${RED}  No accounts found${NC}"
fi
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username

json_file="/etc/tunneling/VLESS/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

read -p "Quota Limit in GB (e.g., 50): " quota

# Update JSON
jq --arg quota "$quota" '.limit_quota = ($quota | tonumber)' $json_file > /tmp/${username}.json
mv /tmp/${username}.json $json_file

echo ""
echo -e "${GREEN}✓ Quota limit set to ${quota}GB for $username${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

