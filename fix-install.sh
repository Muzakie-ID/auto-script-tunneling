#!/bin/bash
# =========================================
# Fix Missing Scripts - Download All Files
# Run this if you get "No such file" errors
# =========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}       Fix Installation - Download Missing Files     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main"
INSTALL_DIR="/usr/local/sbin/tunneling"
BACKUP_DIR="/usr/local/sbin/tunneling/backup_$(date +%Y%m%d_%H%M%S)"

cd $INSTALL_DIR || exit 1

# Ask for backup
echo -e "${YELLOW}Existing files will be replaced.${NC}"
read -p "Create backup before replacing? (y/n): " do_backup
echo ""

if [[ "$do_backup" == "y" ]]; then
    echo -e "${CYAN}Creating backup...${NC}"
    mkdir -p $BACKUP_DIR
    cp -r $INSTALL_DIR/menu $BACKUP_DIR/ 2>/dev/null
    cp -r $INSTALL_DIR/ssh $BACKUP_DIR/ 2>/dev/null
    cp -r $INSTALL_DIR/system $BACKUP_DIR/ 2>/dev/null
    cp -r $INSTALL_DIR/xray $BACKUP_DIR/ 2>/dev/null
    cp -r $INSTALL_DIR/bot $BACKUP_DIR/ 2>/dev/null
    cp $INSTALL_DIR/*.sh $BACKUP_DIR/ 2>/dev/null
    echo -e "${GREEN}✓ Backup created at: $BACKUP_DIR${NC}"
    echo ""
fi

# Create directory structure
mkdir -p "$INSTALL_DIR/menu"
mkdir -p "$INSTALL_DIR/ssh"
mkdir -p "$INSTALL_DIR/system"
mkdir -p "$INSTALL_DIR/xray"
mkdir -p "$INSTALL_DIR/bot"

echo -e "${CYAN}[1/5]${NC} Downloading menu scripts..."
MENU_FILES="main-menu ssh-menu vmess-menu vless-menu trojan-menu zivpn-menu system-menu backup-menu bot-menu settings-menu info-menu"
for file in $MENU_FILES; do
    wget -q -O "$INSTALL_DIR/menu/${file}.sh" "${BASE_URL}/menu/${file}.sh"
done

echo -e "${CYAN}[2/5]${NC} Downloading SSH scripts..."
SSH_FILES="ssh-create ssh-trial ssh-renew ssh-delete ssh-check ssh-list ssh-delete-expired ssh-lock ssh-unlock ssh-details ssh-limit-ip ssh-limit-quota setup-dropbear setup-stunnel setup-squid setup-tuntap setup-ws setup-badvpn"
for file in $SSH_FILES; do
    wget -q -O "$INSTALL_DIR/ssh/${file}.sh" "${BASE_URL}/ssh/${file}.sh"
done

echo -e "${CYAN}[3/5]${NC} Downloading system scripts..."
SYSTEM_FILES="check-services monitor-vps backup-now restore-backup auto-backup delete-expired setup-nginx restart-all restart-service speedtest delete-all-expired limit-speed monitor-service check-logs view-logs auto-reboot-settings change-domain change-banner change-port change-timezone fix-error-domain fix-error-proxy renew-ssl backup-ssl restore-ssl auto-record-wildcard limit-speed-settings reset-settings enable-ssh-root setup-rclone setup-rclone-manual backup-online restore-online auto-backup-online auto-add-bug list-bug remove-bug view-auto-ssl-analytics fix-metrics-php auto-setup-cloudflare-dns fix-cloudflare-dns check-cloudflare-dns fix-xray-config setup-zivpn create-clash-converter update-firewall quick-fix-metrics setup-cloudflare-interactive list-backups delete-backup auto-backup-settings download-backup"
for file in $SYSTEM_FILES; do
    wget -q -O "$INSTALL_DIR/system/${file}.sh" "${BASE_URL}/system/${file}.sh"
done

echo -e "${CYAN}[4/5]${NC} Downloading XRAY scripts..."
wget -q -O "$INSTALL_DIR/xray/setup-xray.sh" "${BASE_URL}/xray/setup-xray.sh"
wget -q -O "$INSTALL_DIR/xray/placeholder.sh" "${BASE_URL}/xray/placeholder.sh"

# VMESS, VLESS, TROJAN, ZIVPN
for proto in vmess vless trojan zivpn; do
    for action in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
        wget -q -O "$INSTALL_DIR/xray/${proto}-${action}.sh" "${BASE_URL}/xray/${proto}-${action}.sh"
    done
done
wget -q -O "$INSTALL_DIR/xray/zivpn-common.sh" "${BASE_URL}/xray/zivpn-common.sh"

echo -e "${CYAN}[5/5]${NC} Downloading bot scripts..."
wget -q -O "$INSTALL_DIR/bot/telegram_bot.py" "${BASE_URL}/bot/telegram_bot.py"
BOT_FILES="bot-setup bot-start bot-stop bot-restart bot-status bot-auto-order bot-payment bot-price bot-notification bot-test"
for file in $BOT_FILES; do
    wget -q -O "$INSTALL_DIR/bot/${file}.sh" "${BASE_URL}/bot/${file}.sh"
done

# Download root maintenance scripts
wget -q -O "$INSTALL_DIR/fix-install.sh" "${BASE_URL}/fix-install.sh"
wget -q -O "$INSTALL_DIR/update.sh" "${BASE_URL}/update.sh"
wget -q -O "$INSTALL_DIR/make-executable.sh" "${BASE_URL}/make-executable.sh"

echo ""
echo -e "${CYAN}[INFO]${NC} Setting permissions..."
chmod +x $INSTALL_DIR/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/menu/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/ssh/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/system/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/xray/*.sh 2>/dev/null
chmod +x $INSTALL_DIR/bot/*.sh 2>/dev/null

# Recreate symlink
ln -sf "$INSTALL_DIR/menu/main-menu.sh" /usr/bin/menu

echo ""
echo -e "${GREEN}✓ All scripts downloaded successfully!${NC}"

if [[ "$do_backup" == "y" ]]; then
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Backup location: $BACKUP_DIR${NC}"
    echo -e "${YELLOW}To restore backup: cp -r $BACKUP_DIR/* $INSTALL_DIR/${NC}"
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}You can now run: menu${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
