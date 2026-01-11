#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              CHANGE DOMAIN                        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show current domain
if [ -f "/root/domain.txt" ]; then
    CURRENT_DOMAIN=$(cat /root/domain.txt)
    echo -e "${YELLOW}Current Domain:${NC} $CURRENT_DOMAIN"
else
    echo -e "${YELLOW}No domain configured yet${NC}"
fi

echo ""
read -p "Enter New Domain: " new_domain

if [[ -z $new_domain ]]; then
    echo -e "${RED}Domain cannot be empty!${NC}"
    sleep 2
    /usr/local/sbin/tunneling/menu/settings-menu.sh
    exit 1
fi

# Validate domain format (allow subdomain)
if [[ ! $new_domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$ ]]; then
    echo -e "${RED}Invalid domain format!${NC}"
    sleep 2
    /usr/local/sbin/tunneling/menu/settings-menu.sh
    exit 1
fi

echo ""
echo -e "${YELLOW}Changing domain to: $new_domain${NC}"
echo ""

# Save new domain
echo "$new_domain" > /root/domain.txt
echo "$new_domain" > /etc/xray/domain

# Renew SSL certificate
echo -e "${CYAN}[INFO]${NC} Requesting SSL certificate..."
systemctl stop nginx >/dev/null 2>&1

# Request new certificate
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d "$new_domain" --standalone -k ec-256

if [ $? -eq 0 ]; then
    # Install certificate
    ~/.acme.sh/acme.sh --installcert -d "$new_domain" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    
    # Restart services
    systemctl start nginx
    systemctl restart xray
    
    echo ""
    echo -e "${GREEN}✓ Domain changed successfully!${NC}"
    echo -e "${GREEN}✓ SSL certificate installed${NC}"
else
    echo ""
    echo -e "${RED}✗ Failed to get SSL certificate!${NC}"
    echo -e "${YELLOW}Make sure:${NC}"
    echo "  1. Domain is pointed to this server IP"
    echo "  2. Port 80 is not blocked by firewall"
    echo "  3. No other web server is running"
    
    systemctl start nginx
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/settings-menu.sh
