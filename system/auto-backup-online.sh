#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}       AUTO BACKUP ONLINE CONFIGURATION              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if rclone is installed and configured
if ! command -v rclone &> /dev/null; then
    echo -e "${RED}Rclone is not installed!${NC}"
    echo ""
    read -p "Install and configure rclone now? (y/n): " install_rc
    if [[ "$install_rc" == "y" || "$install_rc" == "Y" ]]; then
        bash /usr/local/sbin/tunneling/system/setup-rclone.sh
    fi
    exit 0
fi

if [ ! -f ~/.config/rclone/rclone.conf ] || [ ! -s ~/.config/rclone/rclone.conf ]; then
    echo -e "${RED}Rclone is not configured!${NC}"
    echo ""
    read -p "Configure rclone now? (y/n): " config_rc
    if [[ "$config_rc" == "y" || "$config_rc" == "Y" ]]; then
        bash /usr/local/sbin/tunneling/system/setup-rclone.sh
    fi
    exit 0
fi

# Check current cron job
CRON_FILE="/etc/cron.d/auto-backup-online"
if [ -f "$CRON_FILE" ]; then
    echo -e "${GREEN}Auto backup online is currently enabled${NC}"
    echo ""
    
    CURRENT_SCHEDULE=$(grep "backup-online-script.sh" "$CRON_FILE" 2>/dev/null | awk '{print $1, $2, $3, $4, $5}')
    if [[ -n "$CURRENT_SCHEDULE" ]]; then
        echo -e "${CYAN}Current schedule:${NC} $CURRENT_SCHEDULE"
        
        # Parse schedule
        case "$CURRENT_SCHEDULE" in
            "0 2 * * *")
                echo -e "${CYAN}Description:${NC} Daily at 2:00 AM"
                ;;
            "0 2 * * 0")
                echo -e "${CYAN}Description:${NC} Weekly on Sunday at 2:00 AM"
                ;;
            "0 2 1 * *")
                echo -e "${CYAN}Description:${NC} Monthly on 1st at 2:00 AM"
                ;;
            *)
                echo -e "${CYAN}Description:${NC} Custom schedule"
                ;;
        esac
    fi
    
    echo ""
    echo -e "${GREEN}[1]${NC} Modify Schedule"
    echo -e "${GREEN}[2]${NC} Disable Auto Backup"
    echo -e "${GREEN}[3]${NC} Test Backup Now"
    echo -e "${RED}[0]${NC} Back"
    echo ""
    read -p "Select option [0-3]: " mod_choice
    
    case $mod_choice in
        1)
            # Continue to setup
            ;;
        2)
            rm -f "$CRON_FILE"
            systemctl restart cron
            echo ""
            echo -e "${GREEN}Auto backup online disabled${NC}"
            echo ""
            read -p "Press [Enter] to continue..."
            /usr/local/sbin/tunneling/menu/backup-menu.sh
            exit 0
            ;;
        3)
            echo ""
            echo -e "${YELLOW}Running backup test...${NC}"
            bash /usr/local/sbin/tunneling/system/backup-online-script.sh
            exit 0
            ;;
        0)
            /usr/local/sbin/tunneling/menu/backup-menu.sh
            exit 0
            ;;
    esac
fi

# Setup new schedule
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      Select Backup Schedule:                        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}[1]${NC} Daily (at 2:00 AM)"
echo -e "${GREEN}[2]${NC} Weekly (Sunday at 2:00 AM)"
echo -e "${GREEN}[3]${NC} Monthly (1st day at 2:00 AM)"
echo -e "${GREEN}[4]${NC} Custom Schedule"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}[0]${NC} Cancel"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select schedule [0-4]: " schedule

case $schedule in
    1)
        CRON_SCHEDULE="0 2 * * *"
        SCHEDULE_DESC="Daily at 2:00 AM"
        ;;
    2)
        CRON_SCHEDULE="0 2 * * 0"
        SCHEDULE_DESC="Weekly on Sunday at 2:00 AM"
        ;;
    3)
        CRON_SCHEDULE="0 2 1 * *"
        SCHEDULE_DESC="Monthly on 1st at 2:00 AM"
        ;;
    4)
        echo ""
        echo -e "${YELLOW}Custom Schedule (Cron Format: minute hour day month weekday)${NC}"
        echo -e "${CYAN}Examples:${NC}"
        echo "  0 3 * * * - Daily at 3:00 AM"
        echo "  0 */6 * * * - Every 6 hours"
        echo "  0 0 * * 1 - Every Monday at midnight"
        echo ""
        read -p "Enter cron schedule: " CRON_SCHEDULE
        SCHEDULE_DESC="Custom: $CRON_SCHEDULE"
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

# Get remote name
echo ""
if [ -f /etc/tunneling/rclone-remote.txt ]; then
    DEFAULT_REMOTE=$(cat /etc/tunneling/rclone-remote.txt)
    read -p "Enter remote name [$DEFAULT_REMOTE]: " REMOTE_NAME
    REMOTE_NAME=${REMOTE_NAME:-$DEFAULT_REMOTE}
else
    echo -e "${GREEN}Available remotes:${NC}"
    rclone listremotes
    echo ""
    read -p "Enter remote name: " REMOTE_NAME
fi

REMOTE_NAME=${REMOTE_NAME%:}

# Select backup type
echo ""
echo -e "${GREEN}Select backup type:${NC}"
echo -e "${GREEN}[1]${NC} Full Backup"
echo -e "${GREEN}[2]${NC} Config Only"
echo -e "${GREEN}[3]${NC} SSL Certificates Only"
echo ""
read -p "Select type [1-3]: " backup_type_choice

case $backup_type_choice in
    1) BACKUP_TYPE="full" ;;
    2) BACKUP_TYPE="config" ;;
    3) BACKUP_TYPE="ssl" ;;
    *) BACKUP_TYPE="full" ;;
esac

# Create backup script
BACKUP_SCRIPT="/usr/local/sbin/tunneling/system/backup-online-script.sh"
cat > "$BACKUP_SCRIPT" << 'EOFSCRIPT'
#!/bin/bash

# Auto Backup Online Script
REMOTE_NAME="__REMOTE_NAME__"
BACKUP_TYPE="__BACKUP_TYPE__"
DOMAIN=$(cat /root/domain.txt 2>/dev/null || echo "vps")
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="backup-${DOMAIN}-${TIMESTAMP}"
BACKUP_DIR="/root/backup-online"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
LOG_FILE="/var/log/tunneling/auto-backup-online.log"

# Create log directory
mkdir -p /var/log/tunneling

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "Starting auto backup online..."

# Create backup directory
mkdir -p "$BACKUP_PATH"

# Backup based on type
case $BACKUP_TYPE in
    full)
        tar -czf "$BACKUP_PATH/tunneling-config.tar.gz" /etc/tunneling 2>/dev/null
        tar -czf "$BACKUP_PATH/xray-config.tar.gz" /usr/local/etc/xray 2>/dev/null
        tar -czf "$BACKUP_PATH/nginx-config.tar.gz" /etc/nginx 2>/dev/null
        tar -czf "$BACKUP_PATH/ssl-certificates.tar.gz" /etc/letsencrypt 2>/dev/null
        cp /root/domain.txt "$BACKUP_PATH/" 2>/dev/null
        ;;
    config)
        tar -czf "$BACKUP_PATH/tunneling-config.tar.gz" /etc/tunneling 2>/dev/null
        tar -czf "$BACKUP_PATH/xray-config.tar.gz" /usr/local/etc/xray 2>/dev/null
        tar -czf "$BACKUP_PATH/nginx-config.tar.gz" /etc/nginx 2>/dev/null
        cp /root/domain.txt "$BACKUP_PATH/" 2>/dev/null
        ;;
    ssl)
        tar -czf "$BACKUP_PATH/ssl-certificates.tar.gz" /etc/letsencrypt 2>/dev/null
        cp /root/domain.txt "$BACKUP_PATH/" 2>/dev/null
        ;;
esac

# Upload to cloud
log "Uploading to $REMOTE_NAME:/VPS-Backups/$BACKUP_NAME"
rclone copy "$BACKUP_PATH" "$REMOTE_NAME:/VPS-Backups/$BACKUP_NAME" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    log "Backup uploaded successfully"
    
    # Clean old backups (keep last 7)
    BACKUP_COUNT=$(rclone lsf "$REMOTE_NAME:/VPS-Backups/" --dirs-only | wc -l)
    if [ $BACKUP_COUNT -gt 7 ]; then
        log "Cleaning old backups..."
        rclone delete "$REMOTE_NAME:/VPS-Backups/" --min-age 7d >> "$LOG_FILE" 2>&1
    fi
    
    # Remove local backup
    rm -rf "$BACKUP_PATH"
    log "Local backup removed"
else
    log "ERROR: Upload failed"
fi

log "Auto backup completed"
EOFSCRIPT

# Replace placeholders
sed -i "s|__REMOTE_NAME__|$REMOTE_NAME|g" "$BACKUP_SCRIPT"
sed -i "s|__BACKUP_TYPE__|$BACKUP_TYPE|g" "$BACKUP_SCRIPT"
chmod +x "$BACKUP_SCRIPT"

# Create cron job
cat > "$CRON_FILE" << EOF
# Auto Backup Online - $SCHEDULE_DESC
$CRON_SCHEDULE root bash /usr/local/sbin/tunneling/system/backup-online-script.sh
EOF

# Restart cron
systemctl restart cron

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Auto backup online configured successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Configuration:${NC}"
echo -e "Schedule: ${GREEN}$SCHEDULE_DESC${NC}"
echo -e "Remote: ${GREEN}$REMOTE_NAME${NC}"
echo -e "Backup Type: ${GREEN}$BACKUP_TYPE${NC}"
echo -e "Retention: ${GREEN}Keep last 7 backups${NC}"
echo -e "Log File: ${GREEN}/var/log/tunneling/auto-backup-online.log${NC}"
echo ""
echo -e "${YELLOW}Next backup will run according to schedule${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/backup-menu.sh
