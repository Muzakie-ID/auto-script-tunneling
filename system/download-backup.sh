#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="/etc/tunneling/backup"
DOMAIN=$(cat /root/domain.txt 2>/dev/null)
IP=$(curl -s ifconfig.me)
HOST=${DOMAIN:-$IP}

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}               DOWNLOAD BACKUP LINKS                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    echo -e "${RED}No backup files found.${NC}"
else
    for file in "$BACKUP_DIR"/*.tar.gz; do
        name=$(basename "$file")
        echo -e "${YELLOW}$name${NC}"
        echo "http://$HOST:89/backup/$name"
        echo ""
    done
fi

read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/menu/backup-menu.sh
