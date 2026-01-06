#!/bin/bash
# =========================================
# Fix Missing Scripts - Download All Files
# Run this if you get "No such file" errors
# =========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}       Fix Installation - Download Missing Files     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main"
INSTALL_DIR="/usr/local/sbin/tunneling"

cd $INSTALL_DIR || exit 1

echo -e "${CYAN}[1/4]${NC} Downloading menu scripts..."
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

echo -e "${CYAN}[2/4]${NC} Downloading SSH scripts..."
wget -q -O ssh-create.sh "${BASE_URL}/ssh/ssh-create.sh"
wget -q -O ssh-trial.sh "${BASE_URL}/ssh/ssh-trial.sh"
wget -q -O ssh-renew.sh "${BASE_URL}/ssh/ssh-renew.sh"
wget -q -O ssh-delete.sh "${BASE_URL}/ssh/ssh-delete.sh"
wget -q -O ssh-check.sh "${BASE_URL}/ssh/ssh-check.sh"
wget -q -O ssh-list.sh "${BASE_URL}/ssh/ssh-list.sh"
wget -q -O ssh-delete-expired.sh "${BASE_URL}/ssh/ssh-delete-expired.sh"
wget -q -O ssh-lock.sh "${BASE_URL}/ssh/ssh-lock.sh"
wget -q -O ssh-unlock.sh "${BASE_URL}/ssh/ssh-unlock.sh"
wget -q -O ssh-details.sh "${BASE_URL}/ssh/ssh-details.sh"
wget -q -O ssh-limit-ip.sh "${BASE_URL}/ssh/ssh-limit-ip.sh"
wget -q -O ssh-limit-quota.sh "${BASE_URL}/ssh/ssh-limit-quota.sh"
wget -q -O setup-dropbear.sh "${BASE_URL}/ssh/setup-dropbear.sh"
wget -q -O setup-stunnel.sh "${BASE_URL}/ssh/setup-stunnel.sh"
wget -q -O setup-squid.sh "${BASE_URL}/ssh/setup-squid.sh"

echo -e "${CYAN}[3/4]${NC} Downloading system scripts..."
wget -q -O check-services.sh "${BASE_URL}/system/check-services.sh"
wget -q -O monitor-vps.sh "${BASE_URL}/system/monitor-vps.sh"
wget -q -O backup-now.sh "${BASE_URL}/system/backup-now.sh"
wget -q -O restore-backup.sh "${BASE_URL}/system/restore-backup.sh"
wget -q -O auto-backup.sh "${BASE_URL}/system/auto-backup.sh"
wget -q -O delete-expired.sh "${BASE_URL}/system/delete-expired.sh"
wget -q -O setup-nginx.sh "${BASE_URL}/system/setup-nginx.sh"

echo -e "${CYAN}[4/5]${NC} Downloading XRAY scripts..."
wget -q -O setup-xray.sh "${BASE_URL}/xray/setup-xray.sh"

# VMESS
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O vmess-${script}.sh "${BASE_URL}/xray/vmess-${script}.sh"
done

# VLESS
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O vless-${script}.sh "${BASE_URL}/xray/vless-${script}.sh"
done

# TROJAN
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O trojan-${script}.sh "${BASE_URL}/xray/trojan-${script}.sh"
done

wget -q -O placeholder.sh "${BASE_URL}/xray/placeholder.sh"

echo ""
echo -e "${CYAN}[INFO]${NC} Setting permissions..."
chmod +x $INSTALL_DIR/*.sh

echo ""
echo -e "${GREEN}✓ All scripts downloaded successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}You can now run: menu${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
