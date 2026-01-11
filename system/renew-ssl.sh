#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              RENEW SSL CERTIFICATE                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get domain
if [ -f "/root/domain.txt" ]; then
    domain=$(cat /root/domain.txt)
    echo -e "${YELLOW}Domain:${NC} $domain"
else
    echo -e "${RED}No domain configured!${NC}"
    echo "Please configure domain first."
    sleep 2
    /usr/local/sbin/tunneling/menu/settings-menu.sh
    exit 1
fi

# Check certificate expiry
if [ -f "/etc/xray/xray.crt" ]; then
    expiry_date=$(openssl x509 -enddate -noout -in /etc/xray/xray.crt | cut -d= -f2)
    echo -e "${YELLOW}Current Certificate Expires:${NC} $expiry_date"
fi

echo ""
read -p "Renew SSL certificate? [y/n]: " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    /usr/local/sbin/tunneling/menu/settings-menu.sh
    exit 0
fi

echo ""
echo -e "${CYAN}[1/4]${NC} Stopping services..."
systemctl stop nginx

echo -e "${CYAN}[2/4]${NC} Renewing certificate..."
~/.acme.sh/acme.sh --renew -d "$domain" --force --ecc

if [ $? -eq 0 ]; then
    echo -e "${CYAN}[3/4]${NC} Installing certificate..."
    ~/.acme.sh/acme.sh --installcert -d "$domain" --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    
    echo -e "${CYAN}[4/4]${NC} Restarting services..."
    systemctl start nginx
    systemctl restart xray
    
    echo ""
    echo -e "${GREEN}✓ SSL certificate renewed successfully!${NC}"
    
    # Show new expiry
    new_expiry=$(openssl x509 -enddate -noout -in /etc/xray/xray.crt | cut -d= -f2)
    echo -e "${YELLOW}New Expiry Date:${NC} $new_expiry"
else
    systemctl start nginx
    echo ""
    echo -e "${RED}✗ Failed to renew certificate!${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "  1. Domain DNS is correct"
    echo "  2. Port 80 is accessible"
    echo "  3. ACME account is valid"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/settings-menu.sh
