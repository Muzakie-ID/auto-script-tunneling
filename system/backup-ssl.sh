#!/bin/bash

# Backup Let's Encrypt SSL Certificate

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          BACKUP SSL CERTIFICATE (Let's Encrypt)      ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if Let's Encrypt directory exists
if [ ! -d "/etc/letsencrypt" ]; then
    echo -e "${RED}Let's Encrypt directory not found!${NC}"
    echo -e "${YELLOW}No SSL certificate installed.${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    exit 1
fi

# Get domain
DOMAIN=$(cat /root/domain.txt 2>/dev/null || echo "unknown")
BACKUP_DIR="/root/ssl-backup"
BACKUP_FILE="$BACKUP_DIR/letsencrypt-$DOMAIN-$(date +%Y%m%d-%H%M%S).tar.gz"

# Create backup directory
mkdir -p $BACKUP_DIR

echo -e "${YELLOW}Domain:${NC} $DOMAIN"
echo -e "${YELLOW}Backup Location:${NC} $BACKUP_FILE"
echo ""
echo -e "${CYAN}Creating backup...${NC}"

# Backup Let's Encrypt directory
tar -czf "$BACKUP_FILE" \
    /etc/letsencrypt/ \
    /root/domain.txt \
    2>/dev/null

if [ $? -eq 0 ] && [ -f "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | awk '{print $1}')
    
    echo ""
    echo -e "${GREEN}✓ SSL Certificate backed up successfully!${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Backup File:${NC} $BACKUP_FILE"
    echo -e "${YELLOW}Size:${NC} $BACKUP_SIZE"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Download this file to your local machine:${NC}"
    echo -e "${YELLOW}scp root@YOUR_SERVER_IP:$BACKUP_FILE ./ssl-backup.tar.gz${NC}"
    echo ""
    echo -e "${GREEN}Or view backup location directly:${NC}"
    echo -e "${YELLOW}ls -lh $BACKUP_DIR/${NC}"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # List all backups
    echo -e "${YELLOW}All SSL Backups:${NC}"
    ls -lh $BACKUP_DIR/*.tar.gz 2>/dev/null | awk '{print "  "$9" ("$5")"}'
    
else
    echo ""
    echo -e "${RED}✗ Backup failed!${NC}"
    exit 1
fi

echo ""
read -p "Press [Enter] to continue..."
