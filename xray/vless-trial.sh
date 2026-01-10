#!/bin/bash
# VLESS Trial Account (1 Hour)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}      CREATE TRIAL VLESS ACCOUNT        ${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Generate random username
username="trial$(date +%s)"

# Generate UUID
uuid=$(cat /proc/sys/kernel/random/uuid)

# Calculate expiry (1 hour)
exp_date=$(date -d "+1 hours" +"%Y-%m-%d %H:%M")
exp_timestamp=$(date -d "+1 hours" +%s)

# Get domain
domain=$(cat /root/domain.txt)

# Create JSON record
cat > /etc/tunneling/vless/${username}.json << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": 1,
    "limit_quota": 1
}
EOF

# Add to XRAY config
CONFIG_FILE="/usr/local/etc/xray/config.json"
jq --arg uuid "$uuid" --arg email "TRIAL-$username@$domain" \
   '.inbounds[] | select(.protocol=="vless") | .settings.clients += [{"id": $uuid, "email": $email}]' \
   $CONFIG_FILE > /tmp/xray-config.tmp && mv /tmp/xray-config.tmp $CONFIG_FILE
systemctl restart xray

# Generate vless:// link
vless_link="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&type=ws&host=$domain&sni=$domain#TRIAL-$username-$domain"

echo ""
echo -e "${GREEN}✓ VLESS Trial created successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}UUID:${NC} $uuid"
echo -e "${YELLOW}Domain:${NC} $domain"
echo -e "${YELLOW}Expired:${NC} $exp_date (1 Hour)"
echo -e "${YELLOW}Path:${NC} /vless"
echo -e "${YELLOW}Limit:${NC} 1 IP, 1 GB"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}VLESS Link (Copy below):${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}$vless_link${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Note: Import link above to V2RayNG/V2RayN/Clash${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

