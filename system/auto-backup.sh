#!/bin/bash

# Auto Backup Script
# Run daily via cron at 02:00

BACKUP_DIR="/etc/tunneling/backup"
MAX_BACKUPS=7  # Keep last 7 backups
LOG_FILE="/var/log/tunneling/auto-backup.log"

mkdir -p $BACKUP_DIR
mkdir -p /var/log/tunneling

echo "==================================" >> $LOG_FILE
echo "Auto Backup - $(date)" >> $LOG_FILE
echo "==================================" >> $LOG_FILE

# Backup filename with timestamp
BACKUP_NAME="auto-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Create backup
tar -czf $BACKUP_PATH \
    /etc/tunneling/ssh \
    /etc/tunneling/xray \
    /etc/tunneling/vmess \
    /etc/tunneling/vless \
    /etc/tunneling/trojan \
    /etc/tunneling/config.json \
    /etc/tunneling/bot/config.json \
    /usr/local/etc/xray/config.json \
    /etc/nginx/conf.d/ \
    /root/domain.txt \
    2>/dev/null

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h $BACKUP_PATH | awk '{print $1}')
    echo "✓ Backup created: $BACKUP_NAME ($BACKUP_SIZE)" >> $LOG_FILE
    
    # Delete old backups (keep only last MAX_BACKUPS)
    cd $BACKUP_DIR
    ls -t auto-backup-*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
    
    REMAINING=$(ls -1 auto-backup-*.tar.gz 2>/dev/null | wc -l)
    echo "✓ Remaining backups: $REMAINING" >> $LOG_FILE
    
    # Send notification to Telegram bot if configured
    if [ -f /etc/tunneling/bot/config.json ]; then
        BOT_TOKEN=$(jq -r '.token' /etc/tunneling/bot/config.json)
        ADMIN_ID=$(jq -r '.admin_id' /etc/tunneling/bot/config.json)
        
        if [ ! -z "$BOT_TOKEN" ] && [ ! -z "$ADMIN_ID" ]; then
            MESSAGE="💾 Auto Backup Success\n\nFile: $BACKUP_NAME\nSize: $BACKUP_SIZE\nDate: $(date)"
            curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
                -d chat_id="${ADMIN_ID}" \
                -d text="${MESSAGE}" \
                -d parse_mode="HTML" > /dev/null 2>&1
        fi
    fi
else
    echo "✗ Backup failed!" >> $LOG_FILE
    
    # Send error notification
    if [ -f /etc/tunneling/bot/config.json ]; then
        BOT_TOKEN=$(jq -r '.token' /etc/tunneling/bot/config.json)
        ADMIN_ID=$(jq -r '.admin_id' /etc/tunneling/bot/config.json)
        
        if [ ! -z "$BOT_TOKEN" ] && [ ! -z "$ADMIN_ID" ]; then
            MESSAGE="❌ Auto Backup Failed\n\nDate: $(date)\nPlease check the server!"
            curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
                -d chat_id="${ADMIN_ID}" \
                -d text="${MESSAGE}" \
                -d parse_mode="HTML" > /dev/null 2>&1
        fi
    fi
fi

echo "==================================" >> $LOG_FILE
echo "" >> $LOG_FILE

exit 0
