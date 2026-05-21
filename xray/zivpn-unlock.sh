#!/bin/bash
# Unlock ZIVPN Account

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         UNLOCK ZIVPN ACCOUNT           ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Existing ZIVPN Accounts:${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d /etc/tunneling/zivpn ] && [ "$(ls -A /etc/tunneling/zivpn/*.json 2>/dev/null)" ]; then
    for user_json in /etc/tunneling/zivpn/*.json; do
        username_list=$(jq -r '.username' "$user_json" 2>/dev/null)
        echo -e "  • $username_list"
    done
else
    echo -e "${RED}  No accounts found${NC}"
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to unlock: " username
json_file="/etc/tunneling/zivpn/${username}.json"

if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

jq '.locked = false' "$json_file" > "/tmp/${username}.json"
mv "/tmp/${username}.json" "$json_file"

source /usr/local/sbin/tunneling/xray/zivpn-common.sh 2>/dev/null || source "$(dirname "$0")/zivpn-common.sh"
sync_zivpn_auth_config

echo ""
echo -e "${GREEN}✓ Account $username has been unlocked${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
