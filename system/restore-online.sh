#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           RESTORE FROM CLOUD STORAGE                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
    echo -e "${RED}Rclone is not installed!${NC}"
    echo ""
    read -p "Install rclone now? (y/n): " install_rc
    if [[ "$install_rc" == "y" || "$install_rc" == "Y" ]]; then
        bash /usr/local/sbin/tunneling/system/setup-rclone.sh
        exit 0
    else
        exit 1
    fi
fi

# Check if rclone is configured
if [ ! -f ~/.config/rclone/rclone.conf ] || [ ! -s ~/.config/rclone/rclone.conf ]; then
    echo -e "${RED}Rclone is not configured!${NC}"
    echo ""
    read -p "Configure rclone now? (y/n): " config_rc
    if [[ "$config_rc" == "y" || "$config_rc" == "Y" ]]; then
        bash /usr/local/sbin/tunneling/system/setup-rclone.sh
        exit 0
    else
        exit 1
    fi
fi

# Get available remotes
echo -e "${GREEN}Available cloud remotes:${NC}"
rclone listremotes
echo ""

# Get default remote or ask user
if [ -f /etc/tunneling/rclone-remote.txt ]; then
    DEFAULT_REMOTE=$(cat /etc/tunneling/rclone-remote.txt)
    read -p "Enter remote name [$DEFAULT_REMOTE]: " REMOTE_NAME
    REMOTE_NAME=${REMOTE_NAME:-$DEFAULT_REMOTE}
else
    read -p "Enter remote name: " REMOTE_NAME
fi

# Remove trailing colon if exists
REMOTE_NAME=${REMOTE_NAME%:}

# Verify remote exists
if ! rclone listremotes | grep -q "^${REMOTE_NAME}:$"; then
    echo -e "${RED}Remote '$REMOTE_NAME' not found!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Fetching available backups...${NC}"
echo ""

# List available backups
BACKUPS=$(rclone lsf "$REMOTE_NAME:/VPS-Backups/" --dirs-only 2>/dev/null)

if [[ -z "$BACKUPS" ]]; then
    echo -e "${RED}No backups found in cloud storage!${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    /usr/local/sbin/tunneling/menu/backup-menu.sh
    exit 0
fi

echo -e "${GREEN}Available backups:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Convert to array
mapfile -t BACKUP_ARRAY <<< "$BACKUPS"
counter=1

for backup in "${BACKUP_ARRAY[@]}"; do
    backup=$(echo "$backup" | tr -d '/')
    # Get backup info
    size=$(rclone size "$REMOTE_NAME:/VPS-Backups/$backup" 2>/dev/null | grep "Total size:" | awk '{print $3, $4}')
    echo -e "${GREEN}[$counter]${NC} $backup"
    echo "     Size: $size"
    counter=$((counter + 1))
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}[0]${NC} Cancel"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select backup to restore [0-$((counter-1))]: " selection

if [[ "$selection" == "0" ]]; then
    /usr/local/sbin/tunneling/menu/backup-menu.sh
    exit 0
fi

if [[ "$selection" -lt 1 || "$selection" -ge "$counter" ]]; then
    echo -e "${RED}Invalid selection!${NC}"
    exit 1
fi

# Get selected backup
SELECTED_BACKUP=$(echo "${BACKUP_ARRAY[$((selection-1))]}" | tr -d '/')

echo ""
echo -e "${YELLOW}Selected backup: ${GREEN}$SELECTED_BACKUP${NC}"
echo ""
echo -e "${RED}WARNING: This will overwrite current configurations!${NC}"
read -p "Continue with restore? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo -e "${YELLOW}Restore cancelled${NC}"
    exit 0
fi

# Create restore directory
RESTORE_DIR="/root/restore-online"
mkdir -p "$RESTORE_DIR"

# Download backup
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Downloading backup from cloud...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

rclone copy "$REMOTE_NAME:/VPS-Backups/$SELECTED_BACKUP" "$RESTORE_DIR/$SELECTED_BACKUP" --progress

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}✗ Download failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Download completed!${NC}"
echo ""
echo -e "${YELLOW}Restoring backup...${NC}"

# Restore files
cd "$RESTORE_DIR/$SELECTED_BACKUP"

# Backup current config before restore
BACKUP_CURRENT="/root/backup-before-restore-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_CURRENT"
cp -r /etc/tunneling "$BACKUP_CURRENT/" 2>/dev/null
cp -r /usr/local/etc/xray "$BACKUP_CURRENT/" 2>/dev/null
cp -r /etc/nginx "$BACKUP_CURRENT/" 2>/dev/null

echo -e "${GREEN}Current config backed up to: $BACKUP_CURRENT${NC}"
echo ""

# Extract and restore
for tar_file in *.tar.gz; do
    if [[ -f "$tar_file" ]]; then
        echo -e "${YELLOW}Restoring: $tar_file${NC}"
        tar -xzf "$tar_file" -C /
    fi
done

# Restore domain
if [[ -f "domain.txt" ]]; then
    cp domain.txt /root/domain.txt
fi

# Restart services
echo ""
echo -e "${YELLOW}Restarting services...${NC}"
systemctl restart nginx 2>/dev/null
systemctl restart xray 2>/dev/null

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Restore completed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Restored from:${NC} $SELECTED_BACKUP"
echo -e "${CYAN}Previous config saved at:${NC} $BACKUP_CURRENT"
echo ""

read -p "Delete downloaded backup? (y/n): " delete_dl
if [[ "$delete_dl" == "y" || "$delete_dl" == "Y" ]]; then
    rm -rf "$RESTORE_DIR/$SELECTED_BACKUP"
    echo -e "${GREEN}Downloaded backup deleted${NC}"
fi

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/backup-menu.sh
