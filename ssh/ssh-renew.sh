#!/bin/bash
# SSH Account Renewal

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        RENEW SSH ACCOUNT                ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username

if ! id "$username" &>/dev/null; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

read -p "Extend days (e.g., 30): " days

exp_date=$(date -d "+${days} days" +"%Y-%m-%d")
exp_seconds=$(date -d "$exp_date" +%s)

# Update expiration
chage -E $exp_date $username

# Update JSON
if [ -f /etc/tunneling/ssh/${username}.json ]; then
    jq --arg exp "$exp_seconds" '.expired = ($exp | tonumber)' /etc/tunneling/ssh/${username}.json > /tmp/${username}.json
    mv /tmp/${username}.json /etc/tunneling/ssh/${username}.json
fi

echo ""
echo -e "${GREEN}✓ Account renewed successfully!${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}New Expiry:${NC} $exp_date"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
