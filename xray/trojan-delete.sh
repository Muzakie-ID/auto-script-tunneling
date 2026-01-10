#!/bin/bash
# TROJAN Account Deletion

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}        DELETE TROJAN ACCOUNT             ${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show existing accounts
echo -e "${YELLOW}Existing TROJAN Accounts:${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d /etc/tunneling/trojan ] && [ "$(ls -A /etc/tunneling/trojan/*.json 2>/dev/null)" ]; then
    for user_json in /etc/tunneling/trojan/*.json; do
        username_list=$(jq -r '.username' $user_json 2>/dev/null)
        echo -e "  • $username_list"
    done
else
    echo -e "${RED}  No accounts found${NC}"
fi
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to delete: " username

json_file="/etc/tunneling/TROJAN/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

read -p "Are you sure? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Cancelled."
    exit 0
fi

# Get UUID before deleting
uuid=$(jq -r '.uuid' $json_file)

# Remove from XRAY config
CONFIG_FILE="/etc/xray/config.json"
jq --arg password "$uuid" \
   '(.inbounds[] | select(.protocol=="trojan") | .settings.clients) |= map(select(.password != $password))' \
   $CONFIG_FILE > /tmp/xray-config.tmp && mv /tmp/xray-config.tmp $CONFIG_FILE

# Delete JSON
rm -f $json_file

# Restart XRAY
systemctl restart xray

echo ""
echo -e "${GREEN}✓ Account deleted successfully!${NC}"
echo -e "${YELLOW}Note: XRAY config reload required${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

