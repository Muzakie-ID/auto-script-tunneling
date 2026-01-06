#!/bin/bash
# Set Quota Limit for SSH Account

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        SET QUOTA LIMIT                 ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username

json_file="/etc/tunneling/ssh/${username}.json"
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
echo -e "${YELLOW}Note: Quota monitoring requires vnstat configuration${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
