#!/bin/bash
# VLESS Account Renewal

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        RENEW VLESS ACCOUNT              ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username

json_file="/etc/tunneling/VLESS/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

read -p "Extend days (e.g., 30): " days

exp_date=$(date -d "+${days} days" +"%Y-%m-%d")
exp_timestamp=$(date -d "$exp_date" +%s)

# Update JSON
jq --arg exp "$exp_timestamp" '.expired = ($exp | tonumber)' $json_file > /tmp/${username}.json
mv /tmp/${username}.json $json_file

echo ""
echo -e "${GREEN}✓ Account renewed successfully!${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}New Expiry:${NC} $exp_date"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

