#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              BACKUP TO CLOUD STORAGE                 ${NC}"
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
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      Select Backup Type:                            ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}[1]${NC} Full Backup (All accounts + configs)"
echo -e "${GREEN}[2]${NC} Config Only (SSH, XRAY, System configs)"
echo -e "${GREEN}[3]${NC} SSL Certificates Only"
echo -e "${GREEN}[4]${NC} Database/Accounts Only"
echo -e "${GREEN}[5]${NC} Custom (Select directories)"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}[0]${NC} Cancel"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select backup type [0-5]: " backup_type

# Get domain
DOMAIN=$(cat /root/domain.txt 2>/dev/null || echo "vps")
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="backup-${DOMAIN}-${TIMESTAMP}"
BACKUP_DIR="/root/backup-online"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Create backup directory
mkdir -p "$BACKUP_DIR"

case $backup_type in
    1)
        # Full backup
        echo ""
        echo -e "${YELLOW}Creating full backup...${NC}"
        mkdir -p "$BACKUP_PATH"
        
        # Backup all important directories
        tar -czf "$BACKUP_PATH/tunneling-config.tar.gz" /etc/tunneling 2>/dev/null
        tar -czf "$BACKUP_PATH/xray-config.tar.gz" /usr/local/etc/xray 2>/dev/null
        tar -czf "$BACKUP_PATH/nginx-config.tar.gz" /etc/nginx 2>/dev/null
        tar -czf "$BACKUP_PATH/ssl-certificates.tar.gz" /etc/letsencrypt 2>/dev/null
        
        # Save domain info
        cp /root/domain.txt "$BACKUP_PATH/" 2>/dev/null
        
        # Create info file
        cat > "$BACKUP_PATH/backup-info.txt" << EOF
Backup Type: Full Backup
Domain: $DOMAIN
Date: $(date)
Server: $(hostname)
IP: $(curl -s ifconfig.me)
EOF
        
        UPLOAD_PATH="$BACKUP_PATH"
        ;;
    2)
        # Config only
        echo ""
        echo -e "${YELLOW}Creating config backup...${NC}"
        mkdir -p "$BACKUP_PATH"
        
        tar -czf "$BACKUP_PATH/tunneling-config.tar.gz" /etc/tunneling 2>/dev/null
        tar -czf "$BACKUP_PATH/xray-config.tar.gz" /usr/local/etc/xray 2>/dev/null
        tar -czf "$BACKUP_PATH/nginx-config.tar.gz" /etc/nginx 2>/dev/null
        cp /root/domain.txt "$BACKUP_PATH/" 2>/dev/null
        
        UPLOAD_PATH="$BACKUP_PATH"
        ;;
    3)
        # SSL only
        echo ""
        echo -e "${YELLOW}Creating SSL backup...${NC}"
        mkdir -p "$BACKUP_PATH"
        
        tar -czf "$BACKUP_PATH/ssl-certificates.tar.gz" /etc/letsencrypt 2>/dev/null
        cp /root/domain.txt "$BACKUP_PATH/" 2>/dev/null
        
        UPLOAD_PATH="$BACKUP_PATH"
        ;;
    4)
        # Accounts only
        echo ""
        echo -e "${YELLOW}Creating accounts backup...${NC}"
        mkdir -p "$BACKUP_PATH"
        
        tar -czf "$BACKUP_PATH/accounts.tar.gz" /etc/tunneling 2>/dev/null
        
        UPLOAD_PATH="$BACKUP_PATH"
        ;;
    5)
        # Custom
        echo ""
        echo -e "${YELLOW}Enter directory paths to backup (one per line, empty to finish):${NC}"
        CUSTOM_DIRS=()
        while true; do
            read -p "Directory: " custom_dir
            if [[ -z "$custom_dir" ]]; then
                break
            fi
            if [[ -d "$custom_dir" ]]; then
                CUSTOM_DIRS+=("$custom_dir")
            else
                echo -e "${RED}Directory not found: $custom_dir${NC}"
            fi
        done
        
        if [[ ${#CUSTOM_DIRS[@]} -eq 0 ]]; then
            echo -e "${RED}No directories selected!${NC}"
            exit 1
        fi
        
        mkdir -p "$BACKUP_PATH"
        for dir in "${CUSTOM_DIRS[@]}"; do
            dir_name=$(basename "$dir")
            tar -czf "$BACKUP_PATH/${dir_name}.tar.gz" "$dir" 2>/dev/null
        done
        
        UPLOAD_PATH="$BACKUP_PATH"
        ;;
    0)
        /usr/local/sbin/tunneling/menu/backup-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        exit 1
        ;;
esac

# Upload to cloud
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Uploading to cloud storage...${NC}"
echo -e "${CYAN}Remote: ${GREEN}$REMOTE_NAME${NC}"
echo -e "${CYAN}Path: ${GREEN}/VPS-Backups/$BACKUP_NAME${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Upload with progress
rclone copy "$UPLOAD_PATH" "$REMOTE_NAME:/VPS-Backups/$BACKUP_NAME" --progress

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Backup uploaded successfully!${NC}"
    echo ""
    echo -e "${CYAN}Backup Details:${NC}"
    echo -e "Name: ${GREEN}$BACKUP_NAME${NC}"
    echo -e "Location: ${GREEN}$REMOTE_NAME:/VPS-Backups/$BACKUP_NAME${NC}"
    echo -e "Size: $(du -sh "$UPLOAD_PATH" | cut -f1)"
    
    # Save backup info
    echo "$REMOTE_NAME:/VPS-Backups/$BACKUP_NAME|$(date)|$backup_type" >> /etc/tunneling/backup-online-history.txt
    
    # Clean local backup
    echo ""
    read -p "Delete local backup? (y/n): " delete_local
    if [[ "$delete_local" == "y" || "$delete_local" == "Y" ]]; then
        rm -rf "$BACKUP_PATH"
        echo -e "${GREEN}Local backup deleted${NC}"
    fi
else
    echo ""
    echo -e "${RED}✗ Upload failed!${NC}"
    echo -e "${YELLOW}Local backup saved at: $BACKUP_PATH${NC}"
fi

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/backup-menu.sh
