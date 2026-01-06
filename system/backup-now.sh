#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                  BACKUP NOW                         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create backup directory
BACKUP_DIR="/etc/tunneling/backup"
mkdir -p $BACKUP_DIR

# Backup filename with timestamp
BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S).tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

echo -e "${CYAN}[INFO]${NC} Creating backup..."

# Create backup
tar -czf $BACKUP_PATH \
    /etc/tunneling/ssh \
    /etc/tunneling/xray \
    /etc/tunneling/vmess \
    /etc/tunneling/vless \
    /etc/tunneling/trojan \
    /etc/tunneling/config.json \
    /etc/tunneling/bot/config.json \
    /etc/xray/config.json \
    /etc/nginx/conf.d/ \
    /root/domain.txt \
    2>/dev/null

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h $BACKUP_PATH | awk '{print $1}')
    
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}            BACKUP CREATED SUCCESSFULLY!             ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Backup Name:${NC} $BACKUP_NAME"
    echo -e "${YELLOW}Backup Size:${NC} $BACKUP_SIZE"
    echo -e "${YELLOW}Backup Path:${NC} $BACKUP_PATH"
    echo -e "${YELLOW}Created:${NC} $(date)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Download Link:${NC}"
    echo -e "http://$(curl -s ifconfig.me):89/backup/$BACKUP_NAME"
    echo ""
else
    echo -e "${RED}[ERROR]${NC} Backup failed!"
fi

echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/backup-menu.sh
