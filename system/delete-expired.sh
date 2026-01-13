#!/bin/bash

# Auto Delete Expired Accounts Script
# Run daily via cron

LOG_FILE="/var/log/tunneling/delete-expired.log"
mkdir -p /var/log/tunneling

echo "==================================" >> $LOG_FILE
echo "Auto Delete Expired - $(date)" >> $LOG_FILE
echo "==================================" >> $LOG_FILE

deleted_count=0

# Delete expired SSH accounts
for user_file in /etc/tunneling/ssh/*.json; do
    if [ -f "$user_file" ]; then
        username=$(basename "$user_file" .json)
        expired_date=$(jq -r '.expired' "$user_file")
        
        # Convert to timestamp
        exp_timestamp=$(date -d "$expired_date" +%s 2>/dev/null)
        now_timestamp=$(date +%s)
        
        if [ ! -z "$exp_timestamp" ] && [ $exp_timestamp -lt $now_timestamp ]; then
            # Delete user
            userdel -f $username 2>/dev/null
            rm -f "$user_file"
            echo "Deleted SSH user: $username (expired: $expired_date)" >> $LOG_FILE
            ((deleted_count++))
        fi
    fi
done

# Delete expired VMESS accounts
for user_file in /etc/tunneling/vmess/*.json; do
    if [ -f "$user_file" ]; then
        username=$(basename "$user_file" .json)
        expired_date=$(jq -r '.expired' "$user_file")
        exp_timestamp=$(date -d "$expired_date" +%s 2>/dev/null)
        now_timestamp=$(date +%s)
        
        if [ ! -z "$exp_timestamp" ] && [ $exp_timestamp -lt $now_timestamp ]; then
            rm -f "$user_file"
            echo "Deleted VMESS user: $username (expired: $expired_date)" >> $LOG_FILE
            ((deleted_count++))
        fi
    fi
done

# Delete expired VLESS accounts
for user_file in /etc/tunneling/vless/*.json; do
    if [ -f "$user_file" ]; then
        username=$(basename "$user_file" .json)
        expired_date=$(jq -r '.expired' "$user_file")
        exp_timestamp=$(date -d "$expired_date" +%s 2>/dev/null)
        now_timestamp=$(date +%s)
        
        if [ ! -z "$exp_timestamp" ] && [ $exp_timestamp -lt $now_timestamp ]; then
            rm -f "$user_file"
            echo "Deleted VLESS user: $username (expired: $expired_date)" >> $LOG_FILE
            ((deleted_count++))
        fi
    fi
done

# Delete expired TROJAN accounts
for user_file in /etc/tunneling/trojan/*.json; do
    if [ -f "$user_file" ]; then
        username=$(basename "$user_file" .json)
        expired_date=$(jq -r '.expired' "$user_file")
        exp_timestamp=$(date -d "$expired_date" +%s 2>/dev/null)
        now_timestamp=$(date +%s)
        
        if [ ! -z "$exp_timestamp" ] && [ $exp_timestamp -lt $now_timestamp ]; then
            rm -f "$user_file"
            echo "Deleted TROJAN user: $username (expired: $expired_date)" >> $LOG_FILE
            ((deleted_count++))
        fi
    fi
done

echo "Total deleted: $deleted_count accounts" >> $LOG_FILE
echo "==================================" >> $LOG_FILE
echo "" >> $LOG_FILE

# Send notification to Telegram bot if configured
if [ -f /etc/tunneling/bot/config.json ]; then
    BOT_TOKEN=$(jq -r '.token' /etc/tunneling/bot/config.json)
    ADMIN_ID=$(jq -r '.admin_id' /etc/tunneling/bot/config.json)
    
    if [ ! -z "$BOT_TOKEN" ] && [ ! -z "$ADMIN_ID" ]; then
        MESSAGE="🗑️ Auto Delete Expired\n\nTotal deleted: $deleted_count accounts\nDate: $(date)"
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -d chat_id="${ADMIN_ID}" \
            -d text="${MESSAGE}" \
            -d parse_mode="HTML" > /dev/null 2>&1
    fi
fi

exit 0
