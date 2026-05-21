#!/bin/bash
# ZIVPN Trial Account (1 Hour)

source /usr/local/sbin/tunneling/xray/zivpn-common.sh 2>/dev/null || source "$(dirname "$0")/zivpn-common.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}      CREATE TRIAL ZIVPN ACCOUNT        ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

username="trialz$(date +%s)"
uuid=$(cat /proc/sys/kernel/random/uuid)
exp_date=$(date -d "+1 hours" +"%Y-%m-%d %H:%M")
exp_timestamp=$(date -d "+1 hours" +%s)
domain=$(cat /root/domain.txt 2>/dev/null)

ensure_zivpn_dirs
password=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 10)
[ -z "$password" ] && password="trialzivpn"

cat > /etc/tunneling/zivpn/${username}.json << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "password": "$password",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": 1,
    "limit_quota": 1
}
EOF

sync_zivpn_auth_config

echo ""
echo -e "${GREEN}✓ ZIVPN Trial created successfully!${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}Expired:${NC} $exp_date (1 Hour)"
echo -e "${YELLOW}Limit:${NC} 1 IP, 1 GB"
echo -e "${YELLOW}UDP Password:${NC} $password"
echo -e "${YELLOW}UDP Endpoint:${NC} ${domain}:5667"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
