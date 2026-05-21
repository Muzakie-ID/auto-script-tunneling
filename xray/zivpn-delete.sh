#!/bin/bash
# ZIVPN Account Deletion

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}        DELETE ZIVPN ACCOUNT             ${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Existing ZIVPN Accounts:${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d /etc/tunneling/zivpn ] && [ "$(ls -A /etc/tunneling/zivpn/*.json 2>/dev/null)" ]; then
    for user_json in /etc/tunneling/zivpn/*.json; do
        username_list=$(jq -r '.username' "$user_json" 2>/dev/null)
        echo -e "  • $username_list"
    done
else
    echo -e "${RED}  No accounts found${NC}"
fi
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to delete: " username

json_file="/etc/tunneling/zivpn/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

read -p "Are you sure? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Cancelled."
    exit 0
fi

uuid=$(jq -r '.uuid' "$json_file")
rm -f "$json_file"

source /usr/local/sbin/tunneling/xray/zivpn-common.sh 2>/dev/null || source $(dirname "$0")/zivpn-common.sh
sync_zivpn_auth_config

echo ""
echo -e "${GREEN}✓ Account deleted successfully!${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
