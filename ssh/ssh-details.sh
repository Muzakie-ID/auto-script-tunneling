#!/bin/bash
# SSH Account Details

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        SSH ACCOUNT DETAILS             ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username

json_file="/etc/tunneling/ssh/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

# Read JSON data
username=$(jq -r '.username' $json_file)
password=$(jq -r '.password' $json_file)
expired=$(jq -r '.expired' $json_file)
created=$(jq -r '.created // empty' $json_file)
limit_ip=$(jq -r '.limit_ip // "Unlimited"' $json_file)
limit_quota=$(jq -r '.limit_quota // "Unlimited"' $json_file)

# Format dates
if [[ "$expired" =~ ^[0-9]+$ ]]; then
    exp_date=$(date -d @$expired +"%Y-%m-%d %H:%M" 2>/dev/null || echo "Invalid")
else
    exp_date=$expired
fi

if [ -n "$created" ] && [[ "$created" =~ ^[0-9]+$ ]]; then
    created_date=$(date -d @$created +"%Y-%m-%d %H:%M" 2>/dev/null || echo "N/A")
elif [ -n "$created" ]; then
    created_date=$created
else
    created_date="N/A"
fi

# Convert numeric limits
if [ "$limit_ip" == "0" ] || [ "$limit_ip" == "null" ]; then
    limit_ip="Unlimited"
fi

if [ "$limit_quota" == "0" ] || [ "$limit_quota" == "null" ]; then
    limit_quota="Unlimited"
else
    limit_quota="${limit_quota} GB"
fi

# Check active sessions
active=$(ps aux | grep -i "sshd: $username" | grep -v grep | wc -l)

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}Password:${NC} $password"
echo -e "${YELLOW}Created:${NC} $created_date"
echo -e "${YELLOW}Expired:${NC} $exp_date"
echo -e "${YELLOW}Limit IP:${NC} $limit_ip"
echo -e "${YELLOW}Limit Quota:${NC} $limit_quota"
echo -e "${YELLOW}Active Sessions:${NC} $active"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
