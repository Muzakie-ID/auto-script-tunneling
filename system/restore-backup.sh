#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}            RESTORE BACKUP                           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

BACKUP_DIR="/etc/tunneling/backup"

# List available backups
echo -e "${YELLOW}Available Backups:${NC}"
echo ""

if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR)" ]; then
    echo -e "${RED}No backup files found!${NC}"
    echo ""
    read -n 1 -s -r -p "Press any key to back to menu"
    /usr/local/sbin/tunneling/menu/backup-menu.sh
    exit 1
fi

count=1
declare -A backups
for backup in $(ls -t $BACKUP_DIR/*.tar.gz 2>/dev/null); do
    filename=$(basename $backup)
    size=$(du -h $backup | awk '{print $1}')
    date=$(stat -c %y $backup | cut -d' ' -f1,2 | cut -d'.' -f1)
    
    echo -e "${GREEN}[$count]${NC} $filename"
    echo -e "    Size: $size | Date: $date"
    echo ""
    
    backups[$count]=$backup
    ((count++))
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -p "Select backup to restore [1-$((count-1))]: " selection

if [[ ! ${backups[$selection]} ]]; then
    echo -e "${RED}Invalid selection!${NC}"
    exit 1
fi

BACKUP_FILE=${backups[$selection]}

echo ""
echo -e "${YELLOW}⚠️  WARNING!${NC}"
echo -e "This will restore your system to the selected backup."
echo -e "Current configuration will be overwritten!"
echo ""
read -p "Are you sure? (yes/no): " confirm

if [[ $confirm != "yes" ]]; then
    echo -e "${RED}Restore cancelled!${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}[INFO]${NC} Restoring backup..."

# Stop services
systemctl stop xray nginx telegram-bot

# Restore backup
tar -xzf $BACKUP_FILE -C / 2>/dev/null

if [ $? -eq 0 ]; then
    # Restart services
    systemctl restart xray nginx telegram-bot
    
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}           BACKUP RESTORED SUCCESSFULLY!             ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Backup File:${NC} $(basename $BACKUP_FILE)"
    echo -e "${YELLOW}Restored:${NC} $(date)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${RED}[ERROR]${NC} Restore failed!"
    systemctl restart xray nginx telegram-bot
fi

echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/menu/backup-menu.sh
