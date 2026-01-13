#!/bin/bash
# VLESS Account Creation

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        CREATE VLESS ACCOUNT             ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username
read -p "Duration (days): " days

# Generate UUID
uuid=$(cat /proc/sys/kernel/random/uuid)

# Calculate expiry
exp_date=$(date -d "+${days} days" +"%Y-%m-%d")
exp_timestamp=$(date -d "$exp_date" +%s)

# Get domain
domain=$(cat /root/domain.txt)

# Create JSON record
cat > /etc/tunneling/vless/${username}.json << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": 0,
    "limit_quota": 0
}
EOF

# Add to XRAY config
CONFIG_FILE="/usr/local/etc/xray/config.json"

# Check if user already exists in config
if grep -q "\"id\": \"$uuid\"" $CONFIG_FILE; then
    echo -e "${RED}User already exists in XRAY config!${NC}"
    exit 1
fi

# Add client to VLESS inbound
jq --arg uuid "$uuid" --arg email "$username@$domain" \
   '.inbounds |= map(if .protocol == "vless" then .settings.clients += [{"id": $uuid, "email": $email}] else . end)' \
   $CONFIG_FILE > /tmp/xray-config.tmp && mv /tmp/xray-config.tmp $CONFIG_FILE

# Restart XRAY
systemctl restart xray

# Generate vless:// link
# Link TLS (Port 443) - Recommended
vless_link_tls="vless://$uuid@$domain:443?path=%2Fvless&security=tls&encryption=none&type=ws&host=$domain&sni=$domain#$username-TLS"

# Link Non-TLS (Port 80)
vless_link_none="vless://$uuid@$domain:80?path=%2Fvless&security=none&encryption=none&type=ws&host=$domain#$username-HTTP"

echo ""
echo -e "${GREEN}✓ VLESS Account created successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username    :${NC} $username"
echo -e "${YELLOW}UUID        :${NC} $uuid"
echo -e "${YELLOW}Domain      :${NC} $domain"
echo -e "${YELLOW}Expired     :${NC} $exp_date"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[LINK TLS] (Port 443) - Recommended:${NC}"
echo -e "${YELLOW}$vless_link_tls${NC}"
echo ""
echo -e "${GREEN}[LINK HTTP] (Port 80):${NC}"
echo -e "${YELLOW}$vless_link_none${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Note: If one link doesn't work, try the other one.${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

