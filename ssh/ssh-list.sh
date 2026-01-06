#!/bin/bash
# List All SSH Accounts

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                        ALL SSH ACCOUNTS                                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
printf "${GREEN}%-15s %-15s %-12s %-10s${NC}\n" "Username" "Expired" "Status" "Limit IP"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

for user_json in /etc/tunneling/ssh/*.json; do
    if [ -f "$user_json" ]; then
        username=$(jq -r '.username' $user_json)
        expired=$(jq -r '.expired' $user_json)
        limit_ip=$(jq -r '.limit_ip // "Unlimited"' $user_json)
        
        exp_date=$(date -d @$expired +"%Y-%m-%d" 2>/dev/null || echo "Invalid")
        
        now=$(date +%s)
        if [ $expired -lt $now ]; then
            status="${RED}Expired${NC}"
        else
            status="${GREEN}Active${NC}"
        fi
        
        printf "%-15s %-15s %-20s %-10s\n" "$username" "$exp_date" "$status" "$limit_ip"
    fi
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Total Accounts:${NC} $(ls /etc/tunneling/ssh/*.json 2>/dev/null | wc -l)"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
