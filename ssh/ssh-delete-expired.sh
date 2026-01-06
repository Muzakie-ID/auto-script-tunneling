#!/bin/bash
# Delete Expired SSH Accounts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}     DELETE EXPIRED ACCOUNTS            ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

now=$(date +%s)
count=0

for user_json in /etc/tunneling/ssh/*.json; do
    if [ -f "$user_json" ]; then
        username=$(jq -r '.username' $user_json)
        expired=$(jq -r '.expired' $user_json)
        
        if [ $expired -lt $now ]; then
            echo -e "${RED}Deleting:${NC} $username"
            killall -u $username 2>/dev/null
            userdel -r $username 2>/dev/null
            rm -f $user_json
            ((count++))
        fi
    fi
done

echo ""
echo -e "${GREEN}✓ Deleted $count expired accounts${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
