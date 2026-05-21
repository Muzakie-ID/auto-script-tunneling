#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="/etc/tunneling/backup"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                DELETE BACKUP                         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    echo -e "${RED}No backup files found.${NC}"
    echo ""
    read -n 1 -s -r -p "Press any key to back to menu"
    /usr/local/sbin/tunneling/menu/backup-menu.sh
    exit 1
fi

mapfile -t FILES < <(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null)
for i in "${!FILES[@]}"; do
    echo -e "${GREEN}[$((i+1))]${NC} $(basename "${FILES[$i]}")"
done

echo ""
read -p "Select backup to delete [1-${#FILES[@]}]: " pick

if ! [[ "$pick" =~ ^[0-9]+$ ]] || [ "$pick" -lt 1 ] || [ "$pick" -gt "${#FILES[@]}" ]; then
    echo -e "${RED}Invalid selection.${NC}"
    exit 1
fi

TARGET="${FILES[$((pick-1))]}"
read -p "Delete $(basename "$TARGET") ? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    rm -f "$TARGET"
    echo -e "${GREEN}Backup deleted.${NC}"
else
    echo -e "${YELLOW}Deletion canceled.${NC}"
fi

echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/menu/backup-menu.sh
