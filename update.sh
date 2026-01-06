#!/bin/bash

# Update Script for AUTOSCRIPT TUNNELING

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         AUTOSCRIPT TUNNELING UPDATE                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get current version
CURRENT_VERSION=$(jq -r '.version' /etc/tunneling/config.json 2>/dev/null || echo "Unknown")
echo -e "${YELLOW}Current Version:${NC} $CURRENT_VERSION"
echo ""

# Backup before update
echo -e "${CYAN}[INFO]${NC} Creating backup before update..."
BACKUP_FILE="/etc/tunneling/backup/pre-update-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf $BACKUP_FILE \
    /etc/tunneling \
    /usr/local/sbin/tunneling \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓]${NC} Backup created: $(basename $BACKUP_FILE)"
else
    echo -e "${RED}[✗]${NC} Backup failed!"
    read -p "Continue without backup? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${CYAN}[INFO]${NC} Downloading latest version..."

# Download update
cd /tmp
BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main"

# Download updated scripts
wget -q -O main-menu.sh "${BASE_URL}/menu/main-menu.sh"
wget -q -O ssh-menu.sh "${BASE_URL}/menu/ssh-menu.sh"
wget -q -O vmess-menu.sh "${BASE_URL}/menu/vmess-menu.sh"
wget -q -O vless-menu.sh "${BASE_URL}/menu/vless-menu.sh"
wget -q -O trojan-menu.sh "${BASE_URL}/menu/trojan-menu.sh"
wget -q -O system-menu.sh "${BASE_URL}/menu/system-menu.sh"
wget -q -O backup-menu.sh "${BASE_URL}/menu/backup-menu.sh"
wget -q -O bot-menu.sh "${BASE_URL}/menu/bot-menu.sh"
wget -q -O settings-menu.sh "${BASE_URL}/menu/settings-menu.sh"
wget -q -O info-menu.sh "${BASE_URL}/menu/info-menu.sh"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓]${NC} Download completed"
    
    # Install updates
    echo -e "${CYAN}[INFO]${NC} Installing updates..."
    
    cp -f main-menu.sh /usr/local/sbin/tunneling/
    cp -f ssh-menu.sh /usr/local/sbin/tunneling/
    cp -f vmess-menu.sh /usr/local/sbin/tunneling/
    cp -f vless-menu.sh /usr/local/sbin/tunneling/
    cp -f trojan-menu.sh /usr/local/sbin/tunneling/
    cp -f system-menu.sh /usr/local/sbin/tunneling/
    cp -f backup-menu.sh /usr/local/sbin/tunneling/
    cp -f bot-menu.sh /usr/local/sbin/tunneling/
    cp -f settings-menu.sh /usr/local/sbin/tunneling/
    cp -f info-menu.sh /usr/local/sbin/tunneling/
    
    chmod +x /usr/local/sbin/tunneling/*.sh
    
    # Update version
    NEW_VERSION="1.0.1"
    jq ".version = \"$NEW_VERSION\" | .updated = \"$(date +%Y-%m-%d)\"" \
        /etc/tunneling/config.json > /tmp/config.json.tmp && \
        mv /tmp/config.json.tmp /etc/tunneling/config.json
    
    # Clean up
    rm -f /tmp/*.sh
    
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}            UPDATE COMPLETED SUCCESSFULLY!           ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Previous Version:${NC} $CURRENT_VERSION"
    echo -e "${YELLOW}Current Version:${NC}  $NEW_VERSION"
    echo -e "${YELLOW}Updated:${NC}          $(date)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Please restart services or reboot VPS${NC}"
    echo ""
else
    echo -e "${RED}[✗]${NC} Download failed!"
    echo -e "Please check your internet connection"
    exit 1
fi

read -n 1 -s -r -p "Press any key to continue"
