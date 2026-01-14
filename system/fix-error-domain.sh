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

# Check existing certificate
CERT_FILE="/etc/letsencrypt/live/$domain/fullchain.pem"
LAST_RENEWAL_FILE="/root/.last_ssl_renewal"
COOLDOWN_HOURS=24

if [ -f "$CERT_FILE" ]; then
    echo -e "${YELLOW}Checking existing certificate...${NC}"
    
    # Get certificate expiry date
    EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "$EXPIRY_DATE" +%s 2>/dev/null)
    CURRENT_EPOCH=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
    
    echo -e "${CYAN}Certificate expires in: ${YELLOW}$DAYS_LEFT days${NC}"
    
    # Check if certificate still valid for more than 30 days
    if [ $DAYS_LEFT -gt 30 ]; then
        echo -e "${GREEN}Certificate is still valid!${NC}"
        echo -e "${YELLOW}No need to renew yet (renew when < 30 days).${NC}"
        echo ""
        read -p "Force renewal anyway? [y/n]: " force_renew
        
        if [[ ! $force_renew =~ ^[Yy]$ ]]; then
            echo -e "${GREEN}Renewal cancelled.${NC}"
            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            read -p "Press [Enter] to continue..."
            /usr/local/sbin/tunneling/menu/settings-menu.sh
            exit 0
        fi
    fi
    
    # Check cooldown (protect from rate limit abuse)
    if [ -f "$LAST_RENEWAL_FILE" ]; then
        LAST_RENEWAL=$(cat "$LAST_RENEWAL_FILE")
        TIME_DIFF=$(( ($CURRENT_EPOCH - $LAST_RENEWAL) / 3600 ))
        
        if [ $TIME_DIFF -lt $COOLDOWN_HOURS ]; then
            WAIT_TIME=$(( $COOLDOWN_HOURS - $TIME_DIFF ))
            echo -e "${RED}⚠ Rate limit protection active!${NC}"
            echo -e "${YELLOW}Last renewal was $TIME_DIFF hours ago.${NC}"
            echo -e "${YELLOW}Please wait $WAIT_TIME more hours before next renewal.${NC}"
            echo -e "${CYAN}This prevents Let's Encrypt rate limit (5 renewals/week).${NC}"
            echo ""
            read -p "Force renewal anyway? [y/n]: " force_cooldown
            
            if [[ ! $force_cooldown =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Renewal cancelled for safety.${NC}"
                echo ""
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                read -p "Press [Enter] to continue..."
                /usr/local/sbin/tunneling/menu/settings-menu.sh
                exit 0
            fi
        fi
    fi
fi

echo ""
echo -e "${CYAN}[1/5]${NC} Stopping services..."
if systemctl list-unit-files | grep -q "^nginx.service"; then
    systemctl stop nginx
fi
systemctl stop xray

echo -e "${CYAN}[2/5]${NC} Backing up & cleaning old certificates..."
# Backup existing certificate before removal
if [ -f "$CERT_FILE" ]; then
    BACKUP_DIR="/root/ssl-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r /etc/letsencrypt/live/"$domain" "$BACKUP_DIR/" 2>/dev/null
    echo -e "${GREEN}Backup saved to: $BACKUP_DIR${NC}"
fi

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
    
    # Record renewal timestamp
    date +%s > "$LAST_RENEWAL_FILE"
    
    echo -e "${CYAN}[5/5]${NC} Restarting services..."
    if systemctl list-unit-files | grep -q "^nginx.service"; then
        systemctl start nginx
    else
        echo -e "${YELLOW}Note: NGINX service not found, skipping...${NC}"
    fi
    systemctl start xray
    
    echo ""
    echo -e "${GREEN}✓ Domain errors fixed successfully!${NC}"
    
    # Show new expiry
    if [ -f "$CERT_FILE" ]; then
        NEW_EXPIRY=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
        echo -e "${CYAN}New certificate expires: ${YELLOW}$NEW_EXPIRY${NC}"
    fi
else
    if systemctl list-unit-files | grep -q "^nginx.service"; then
        systemctl start nginx
    fi
    systemctl start xray
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
