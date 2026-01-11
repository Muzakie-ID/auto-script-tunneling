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
echo ""
echo -e "${YELLOW}Local Backup:${NC}"
echo -e "${GREEN}  [1]${NC} Backup Now"
echo -e "${GREEN}  [2]${NC} Restore Backup"
echo -e "${GREEN}  [3]${NC} List Backups"
echo -e "${GREEN}  [4]${NC} Delete Backup"
echo -e "${GREEN}  [5]${NC} Auto Backup Settings"
echo -e "${GREEN}  [6]${NC} Download Backup"
echo ""
echo -e "${YELLOW}Cloud Backup:${NC}"
echo -e "${GREEN}  [7]${NC} Setup Cloud Storage (Rclone)"
echo -e "${GREEN}  [8]${NC} Backup to Cloud"
echo -e "${GREEN}  [9]${NC} Restore from Cloud"
echo -e "${GREEN} [10]${NC} Auto Backup Online Settings"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back to Main Menu"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select Menu [0-10]: " menu

case $menu in
    1)
        /usr/local/sbin/tunneling/system/backup-now.sh
        ;;
    2)
        /usr/local/sbin/tunneling/system/restore-backup.sh
        ;;
    3)
        /usr/local/sbin/tunneling/system/list-backups.sh
        ;;
    4)
        /usr/local/sbin/tunneling/system/delete-backup.sh
        ;;
    5)
        /usr/local/sbin/tunneling/system/auto-backup-settings.sh
        ;;
    6)
        /usr/local/sbin/tunneling/system/download-backup.sh
        ;;
    7)
        /usr/local/sbin/tunneling/system/setup-rclone.sh
        ;;
    8)
        /usr/local/sbin/tunneling/system/backup-online.sh
        ;;
    9)
        /usr/local/sbin/tunneling/system/restore-online.sh
        ;;
    10)
        /usr/local/sbin/tunneling/system/auto-backup-online.sh
        ;;
    0)
        /usr/local/sbin/tunneling/menu/main-menu.sh
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/menu/backup-menu.sh
        ;;
esac
