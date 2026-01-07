#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          AUTO RECORD WILDCARD DOMAIN              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}This feature requires Cloudflare API Token${NC}"
echo ""

# Get main domain
read -p "Enter your main domain (e.g., example.com): " main_domain

if [[ -z $main_domain ]]; then
    echo -e "${RED}Domain cannot be empty!${NC}"
    sleep 2
    /usr/local/sbin/tunneling/settings-menu.sh
    exit 1
fi

# Get Cloudflare credentials
read -p "Enter Cloudflare Email: " cf_email
read -p "Enter Cloudflare API Token: " cf_token

if [[ -z $cf_email ]] || [[ -z $cf_token ]]; then
    echo -e "${RED}Credentials cannot be empty!${NC}"
    sleep 2
    /usr/local/sbin/tunneling/settings-menu.sh
    exit 1
fi

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)
echo ""
echo -e "${YELLOW}Server IP:${NC} $SERVER_IP"

# Save credentials
mkdir -p /root/.cloudflare
cat > /root/.cloudflare/credentials <<EOF
CF_Email="$cf_email"
CF_Token="$cf_token"
EOF

echo ""
echo -e "${CYAN}[INFO]${NC} Installing acme.sh DNS API..."
source /root/.cloudflare/credentials

# Issue wildcard certificate
echo -e "${CYAN}[INFO]${NC} Requesting wildcard certificate..."
~/.acme.sh/acme.sh --issue --dns dns_cf -d "$main_domain" -d "*.$main_domain" --force

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Wildcard certificate obtained!${NC}"
    
    # Install certificate
    ~/.acme.sh/acme.sh --installcert -d "$main_domain" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key
    
    # Save wildcard domain
    echo "$main_domain" > /root/domain.txt
    echo "wildcard" > /root/domain-type.txt
    
    # Restart services
    systemctl restart xray nginx
    
    echo ""
    echo -e "${GREEN}✓ Wildcard domain configured successfully!${NC}"
    echo -e "${YELLOW}You can now use:${NC}"
    echo "  • $main_domain"
    echo "  • *.${main_domain}"
else
    echo ""
    echo -e "${RED}✗ Failed to get wildcard certificate!${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "  1. Cloudflare credentials are correct"
    echo "  2. Domain is managed by Cloudflare"
    echo "  3. API Token has DNS edit permission"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/settings-menu.sh
