#!/bin/bash

# Restore Let's Encrypt SSL Certificate

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         RESTORE SSL CERTIFICATE (Let's Encrypt)      ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

BACKUP_DIR="/root/ssl-backup"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}Backup directory not found!${NC}"
    echo -e "${YELLOW}Please upload your SSL backup file first.${NC}"
    echo ""
    echo -e "${GREEN}Upload command:${NC}"
    echo -e "${YELLOW}scp ssl-backup.tar.gz root@YOUR_SERVER_IP:/root/ssl-backup/${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    exit 1
fi

# List available backups
echo -e "${YELLOW}Available SSL Backups:${NC}"
echo ""
BACKUPS=($(ls -1t $BACKUP_DIR/*.tar.gz 2>/dev/null))

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${RED}No backup files found in $BACKUP_DIR${NC}"
    echo ""
    echo -e "${GREEN}Upload your backup:${NC}"
    echo -e "${YELLOW}scp ssl-backup.tar.gz root@YOUR_SERVER_IP:$BACKUP_DIR/${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    exit 1
fi

# Display backups with numbers
for i in "${!BACKUPS[@]}"; do
    SIZE=$(du -h "${BACKUPS[$i]}" | awk '{print $1}')
    FILENAME=$(basename "${BACKUPS[$i]}")
    echo -e "  ${GREEN}[$((i+1))]${NC} $FILENAME (${SIZE})"
done

echo ""
read -p "Select backup number [1-${#BACKUPS[@]}]: " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#BACKUPS[@]} ]; then
    echo -e "${RED}Invalid selection!${NC}"
    sleep 2
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$((selection-1))]}"
echo ""
echo -e "${YELLOW}Selected:${NC} $(basename $SELECTED_BACKUP)"
echo ""

# Confirm restore
read -p "This will overwrite existing SSL certificate. Continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo -e "${YELLOW}Restore cancelled.${NC}"
    sleep 2
    exit 0
fi

echo ""
echo -e "${CYAN}Restoring SSL certificate...${NC}"

# Stop nginx before restore
systemctl stop nginx

# Backup existing certificate (if any)
if [ -d "/etc/letsencrypt" ]; then
    echo -e "${YELLOW}Backing up existing certificate...${NC}"
    mv /etc/letsencrypt /etc/letsencrypt.old.$(date +%Y%m%d-%H%M%S)
fi

# Restore from backup
tar -xzf "$SELECTED_BACKUP" -C / 2>/dev/null

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ SSL Certificate restored successfully!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Get domain from restored file
    if [ -f "/root/domain.txt" ]; then
        DOMAIN=$(cat /root/domain.txt)
        echo -e "${YELLOW}Domain:${NC} $DOMAIN"
    fi
    
    # Check certificate
    if [ -d "/etc/letsencrypt/live" ]; then
        echo -e "${YELLOW}Certificates:${NC}"
        ls -1 /etc/letsencrypt/live/ | grep -v README | awk '{print "  - "$1}'
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Restarting Nginx...${NC}"
    systemctl start nginx
    
    if systemctl is-active --quiet nginx; then
        echo -e "${GREEN}✓ Nginx restarted successfully${NC}"
    else
        echo -e "${RED}✗ Nginx failed to start${NC}"
        echo -e "${YELLOW}Check configuration: nginx -t${NC}"
    fi
    
else
    echo ""
    echo -e "${RED}✗ Restore failed!${NC}"
    
    # Restore old certificate if available
    if [ -d "/etc/letsencrypt.old."* ]; then
        echo -e "${YELLOW}Restoring previous certificate...${NC}"
        rm -rf /etc/letsencrypt
        mv /etc/letsencrypt.old.* /etc/letsencrypt
    fi
    
    systemctl start nginx
    exit 1
fi

echo ""
read -p "Press [Enter] to continue..."
