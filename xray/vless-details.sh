#!/bin/bash
# VLESS Account Details

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        VLESS ACCOUNT DETAILS           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show existing accounts
echo -e "${YELLOW}Existing VLESS Accounts:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d /etc/tunneling/vless ] && [ "$(ls -A /etc/tunneling/vless/*.json 2>/dev/null)" ]; then
    for user_json in /etc/tunneling/vless/*.json; do
        username_list=$(jq -r '.username' $user_json 2>/dev/null)
        echo -e "  • $username_list"
    done
else
    echo -e "${RED}  No accounts found${NC}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username

json_file="/etc/tunneling/VLESS/${username}.json"
if [ ! -f "$json_file" ]; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

# Read JSON data
username=$(jq -r '.username' $json_file)
uuid=$(jq -r '.uuid' $json_file)
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
else
    created_date="N/A"
fi

if [ "$limit_ip" == "0" ] || [ "$limit_ip" == "null" ]; then
    limit_ip="Unlimited"
fi

if [ "$limit_quota" == "0" ] || [ "$limit_quota" == "null" ]; then
    limit_quota="Unlimited"
else
    limit_quota="${limit_quota} GB"
fi

# Get domain
domain=$(cat /root/domain.txt 2>/dev/null || echo "N/A")

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}UUID:${NC} $uuid"
echo -e "${YELLOW}Domain:${NC} $domain"
echo -e "${YELLOW}Created:${NC} $created_date"
echo -e "${YELLOW}Expired:${NC} $exp_date"
echo -e "${YELLOW}Limit IP:${NC} $limit_ip"
echo -e "${YELLOW}Limit Quota:${NC} $limit_quota"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

