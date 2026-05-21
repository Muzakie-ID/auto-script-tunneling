#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CRON_FILE="/etc/cron.d/auto-backup"
SCRIPT_PATH="/usr/local/sbin/tunneling/system/auto-backup.sh"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}             AUTO BACKUP SETTINGS                    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[1]${NC} Enable Daily (02:00)"
echo -e "${GREEN}[2]${NC} Enable Every 6 Hours"
echo -e "${GREEN}[3]${NC} Disable Auto Backup"
echo -e "${GREEN}[4]${NC} Run Backup Now (Test)"
echo -e "${RED}[0]${NC} Back"
echo ""
read -p "Select option [0-4]: " opt

case "$opt" in
  1)
    echo "0 2 * * * root $SCRIPT_PATH" > "$CRON_FILE"
    systemctl restart cron
    echo -e "${GREEN}Daily auto backup enabled.${NC}"
    ;;
  2)
    echo "0 */6 * * * root $SCRIPT_PATH" > "$CRON_FILE"
    systemctl restart cron
    echo -e "${GREEN}Auto backup every 6 hours enabled.${NC}"
    ;;
  3)
    rm -f "$CRON_FILE"
    systemctl restart cron
    echo -e "${YELLOW}Auto backup disabled.${NC}"
    ;;
  4)
    bash "$SCRIPT_PATH"
    echo -e "${GREEN}Manual auto-backup test executed.${NC}"
    ;;
  0)
    /usr/local/sbin/tunneling/menu/backup-menu.sh
    exit 0
    ;;
  *)
    echo -e "${RED}Invalid option.${NC}"
    ;;
esac

echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/menu/backup-menu.sh
