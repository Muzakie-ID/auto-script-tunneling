#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              FIX ERROR DOMAIN                     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}This will fix common domain issues:${NC}"
echo "  • Reset SSL certificates"
echo "  • Fix DNS records"
echo "  • Restart related services"
echo ""
read -p "Continue? [y/n]: " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    /usr/local/sbin/tunneling/menu/settings-menu.sh
    exit 0
fi

# Get domain
if [ -f "/root/domain.txt" ]; then
    domain=$(cat /root/domain.txt)
else
    read -p "Enter domain: " domain
    echo "$domain" > /root/domain.txt
fi

echo ""
echo -e "${CYAN}[1/5]${NC} Stopping services..."
systemctl stop nginx xray

echo -e "${CYAN}[2/5]${NC} Cleaning old certificates..."
rm -rf /etc/letsencrypt/live/"$domain"
rm -rf /etc/letsencrypt/archive/"$domain"
rm -rf /etc/letsencrypt/renewal/"$domain".conf

echo -e "${CYAN}[3/5]${NC} Requesting new certificate..."
# Get email
if [ -f /root/email.txt ]; then
    email=$(cat /root/email.txt)
else
    email="admin@${domain}"
fi

certbot certonly --standalone --non-interactive --agree-tos --email "$email" -d "$domain"

if [ $? -eq 0 ]; then
    echo -e "${CYAN}[4/5]${NC} Installing certificate..."
    ln -sf /etc/letsencrypt/live/"$domain"/fullchain.pem /etc/xray/xray.crt
    ln -sf /etc/letsencrypt/live/"$domain"/privkey.pem /etc/xray/xray.key
    
    echo -e "${CYAN}[5/5]${NC} Restarting services..."
    systemctl start nginx xray
    
    echo ""
    echo -e "${GREEN}✓ Domain errors fixed successfully!${NC}"
else
    systemctl start nginx xray
    echo ""
    echo -e "${RED}✗ Failed to fix domain errors!${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo "  1. Domain DNS is pointed to this server"
    echo "  2. Port 80/443 are open"
    echo "  3. No other web server is running"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/settings-menu.sh
