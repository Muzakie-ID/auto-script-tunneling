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
cat > /etc/tunneling/VLESS/${username}.json << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": 0,
    "limit_quota": 0
}
EOF

# TODO: Add to XRAY config (will be implemented)

# Generate vless:// link
vless_link="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&type=ws&host=$domain&sni=$domain#$username-$domain"

echo ""
echo -e "${GREEN}✓ VLESS Account created successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Username:${NC} $username"
echo -e "${YELLOW}UUID:${NC} $uuid"
echo -e "${YELLOW}Domain:${NC} $domain"
echo -e "${YELLOW}Expired:${NC} $exp_date"
echo -e "${YELLOW}Port TLS:${NC} 443"
echo -e "${YELLOW}Network:${NC} WebSocket (ws)"
echo -e "${YELLOW}Path:${NC} /vless"
echo -e "${YELLOW}Security:${NC} TLS"
echo -e "${YELLOW}Encryption:${NC} none"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}VLESS Link (Copy below):${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}$vless_link${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Note: Import link above to V2RayNG/V2RayN/Clash${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."

