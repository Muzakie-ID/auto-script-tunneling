#!/bin/bash
# ZIVPN Account Creation

source /usr/local/sbin/tunneling/xray/zivpn-common.sh 2>/dev/null || source "$(dirname "$0")/zivpn-common.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        CREATE ZIVPN ACCOUNT             ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username
read -p "Duration (days): " days
read -p "Limit IP (0=unlimited): " limit_ip
read -p "Limit Quota GB (0=unlimited): " limit_quota

limit_ip=${limit_ip:-0}
limit_quota=${limit_quota:-0}

if [[ -z "$username" ]] || [[ ! "$username" =~ ^[a-zA-Z0-9_]{3,32}$ ]]; then
    echo -e "${RED}Invalid username! Use 3-32 chars: letters, numbers, underscore only.${NC}"
    exit 1
fi

if ! [[ "$days" =~ ^[0-9]+$ ]] || [ "$days" -le 0 ]; then
    echo -e "${RED}Duration must be a positive number.${NC}"
    exit 1
fi

if ! [[ "$limit_ip" =~ ^[0-9]+$ ]] || ! [[ "$limit_quota" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Limit IP and Limit Quota must be numeric (0 or greater).${NC}"
    exit 1
fi

ensure_zivpn_dirs

if [ -f "/etc/tunneling/zivpn/${username}.json" ]; then
    echo -e "${RED}Username already exists!${NC}"
    exit 1
fi

uuid=$(cat /proc/sys/kernel/random/uuid)
exp_date=$(date -d "+${days} days" +"%Y-%m-%d")
exp_timestamp=$(date -d "$exp_date" +%s)
domain=$(cat /root/domain.txt 2>/dev/null)

password=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)
[ -z "$password" ] && password="z${uuid//-/}"

cat > "/etc/tunneling/zivpn/${username}.json" << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "password": "$password",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": $limit_ip,
    "limit_quota": $limit_quota
}
EOF

sync_zivpn_auth_config

echo ""
echo -e "${GREEN}✓ ZIVPN Account created successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}UUID:${NC} $uuid"
echo -e "${YELLOW}UDP Password:${NC} $password"
echo -e "${YELLOW}Domain:${NC} $domain"
echo -e "${YELLOW}Expired:${NC} $exp_date"
echo -e "${YELLOW}Limit IP:${NC} $limit_ip"
echo -e "${YELLOW}Limit Quota:${NC} ${limit_quota}GB"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}ZIVPN UDP Endpoint:${NC}"
echo -e "${YELLOW}${domain}:5667${NC} (or 6000-19999/udp forwarded)"
echo -e "${YELLOW}Auth Password:${NC} ${password}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
