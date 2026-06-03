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

uuid=$(cat /proc/sys/kernel/random/uuid)
exp_date=$(date -d "+${days} days" +"%Y-%m-%d")
exp_timestamp=$(date -d "$exp_date" +%s)
domain=$(cat /root/domain.txt 2>/dev/null)

mkdir -p /etc/tunneling/vless
cat > "/etc/tunneling/vless/${username}.json" << EOF
{
    "username": "$username",
    "uuid": "$uuid",
    "created": $(date +%s),
    "expired": $exp_timestamp,
    "limit_ip": $limit_ip,
    "limit_quota": $limit_quota
}
EOF

CONFIG_FILE="/usr/local/etc/xray/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}XRAY config not found, regenerating...${NC}"
    bash /usr/local/sbin/tunneling/xray/setup-xray.sh 2>/dev/null
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}XRAY config not found: $CONFIG_FILE${NC}"
        rm -f "/etc/tunneling/vless/${username}.json"
        exit 1
    fi
fi

# Validate config is valid JSON with proper structure
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${YELLOW}XRAY config is corrupt, regenerating...${NC}"
    bash /usr/local/sbin/tunneling/xray/setup-xray.sh 2>/dev/null
    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${RED}Failed to regenerate XRAY config!${NC}"
        rm -f "/etc/tunneling/vless/${username}.json"
        exit 1
    fi
fi

# Validate inbounds structure exists
if [ "$(jq '.inbounds' "$CONFIG_FILE" 2>/dev/null)" = "null" ]; then
    echo -e "${YELLOW}XRAY config missing inbounds, regenerating...${NC}"
    bash /usr/local/sbin/tunneling/xray/setup-xray.sh 2>/dev/null
fi

if grep -q "\"email\": \"$username@$domain\"" "$CONFIG_FILE"; then
    echo -e "${RED}Username already exists in XRAY config!${NC}"
    rm -f "/etc/tunneling/vless/${username}.json"
    exit 1
fi

cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

jq --arg uuid "$uuid" --arg email "$username@$domain" \
   '.inbounds |= map(if .protocol == "vless" then .settings.clients += [{"id": $uuid, "email": $email}] else . end)' \
   "$CONFIG_FILE" > /tmp/xray-config.tmp && mv /tmp/xray-config.tmp "$CONFIG_FILE"

echo -e "${CYAN}Validating XRAY config...${NC}"
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${RED}Invalid JSON config! Restoring backup...${NC}"
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE"
    rm -f "/etc/tunneling/vless/${username}.json"
    exit 1
fi

echo -e "${CYAN}Restarting XRAY service...${NC}"
systemctl restart xray
sleep 2

if ! systemctl is-active --quiet xray; then
    echo -e "${RED}Failed to start XRAY! Restoring backup...${NC}"
    mv "${CONFIG_FILE}.bak" "$CONFIG_FILE"
    systemctl restart xray
    rm -f "/etc/tunneling/vless/${username}.json"
    exit 1
fi

echo -e "${GREEN}XRAY service running successfully!${NC}"

vless_link_tls="vless://$uuid@$domain:443?path=%2Fvless&security=tls&encryption=none&type=ws&host=$domain&sni=$domain#$username-TLS"
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
read -n 1 -s -r -p "Press any key to continue..."
