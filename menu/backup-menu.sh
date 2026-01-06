#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}               BACKUP & RESTORE MENU                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Backup Now"
echo -e "${GREEN}  [2]${NC} Restore Backup"
echo -e "${GREEN}  [3]${NC} List Backups"
echo -e "${GREEN}  [4]${NC} Delete Backup"
echo -e "${GREEN}  [5]${NC} Auto Backup Settings"
echo -e "${GREEN}  [6]${NC} Download Backup"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-6]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/backup-now.sh
        ;;
    2)
        /usr/local/sbin/tunneling/restore-backup.sh
        ;;
    3)
        /usr/local/sbin/tunneling/list-backups.sh
        ;;
    4)
        /usr/local/sbin/tunneling/delete-backup.sh
        ;;
    5)
        /usr/local/sbin/tunneling/auto-backup-settings.sh
        ;;
    6)
        /usr/local/sbin/tunneling/download-backup.sh
        ;;
    0)
        /usr/local/sbin/tunneling/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/backup-menu.sh
        ;;
esac
