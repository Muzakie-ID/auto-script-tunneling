#!/bin/bash
# Delete Expired ZIVPN Accounts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}     DELETE EXPIRED ZIVPN ACCOUNTS      ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

now=$(date +%s)
count=0

for user_json in /etc/tunneling/zivpn/*.json; do
    if [ -f "$user_json" ]; then
        username=$(jq -r '.username' "$user_json")
        expired=$(jq -r '.expired' "$user_json")

        if [[ "$expired" =~ ^[0-9]+$ ]]; then
            exp_timestamp=$expired
        else
            exp_timestamp=$(date -d "$expired" +%s 2>/dev/null || echo "0")
        fi

        if [ "$exp_timestamp" != "0" ] && [ "$exp_timestamp" -lt "$now" ]; then
            echo -e "${RED}Deleting:${NC} $username"
            rm -f "$user_json"
            ((count++))
        fi
    fi
done

echo ""
echo -e "${GREEN}✓ Deleted $count expired accounts${NC}"

source /usr/local/sbin/tunneling/xray/zivpn-common.sh 2>/dev/null || source $(dirname "$0")/zivpn-common.sh
sync_zivpn_auth_config

echo ""
read -n 1 -s -r -p "Press any key to continue..."
