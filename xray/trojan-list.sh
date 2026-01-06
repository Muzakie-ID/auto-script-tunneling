#!/bin/bash
# List All TROJAN Accounts

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                        ALL TROJAN ACCOUNTS                               ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
printf "${GREEN}%-15s %-15s %-12s %-10s${NC}\n" "Username" "Expired" "Status" "Limit IP"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

for user_json in /etc/tunneling/TROJAN/*.json; do
    if [ -f "$user_json" ]; then
        username=$(jq -r '.username' $user_json)
        expired=$(jq -r '.expired' $user_json)
        limit_ip=$(jq -r '.limit_ip // 0' $user_json)
        
        if [ "$limit_ip" == "0" ] || [ "$limit_ip" == "null" ]; then
            limit_ip="Unlimited"
        fi
        
        if [[ "$expired" =~ ^[0-9]+$ ]]; then
            exp_date=$(date -d @$expired +"%Y-%m-%d" 2>/dev/null || echo "Invalid")
            exp_timestamp=$expired
        else
            exp_date=$expired
            exp_timestamp=$(date -d "$expired" +%s 2>/dev/null || echo "0")
        fi
        
        now=$(date +%s)
        if [ "$exp_timestamp" != "0" ] && [ "$exp_timestamp" -lt "$now" ]; then
            status="Expired"
        else
            status="Active"
        fi
        
        if [ "$status" == "Expired" ]; then
            printf "%-15s %-15s ${RED}%-12s${NC} %-10s\n" "$username" "$exp_date" "$status" "$limit_ip"
        else
            printf "%-15s %-15s ${GREEN}%-12s${NC} %-10s\n" "$username" "$exp_date" "$status" "$limit_ip"
        fi
    fi
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Total Accounts:${NC} $(ls /etc/tunneling/TROJAN/*.json 2>/dev/null | wc -l)"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

