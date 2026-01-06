#!/bin/bash
# =========================================
# AUTOSCRIPT TUNNELING VPN
# Support: Ubuntu 22.04+ / Debian 11+
# Author: AUTOSCRIPT TUNNELING TEAM
# =========================================

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}" 
   exit 1
fi

# Check OS
if [[ -e /etc/debian_version ]]; then
    OS="debian"
    source /etc/os-release
    VER=$VERSION_ID
    if [[ "$ID" == "debian" && "$VER" -lt 11 ]]; then
        echo -e "${RED}Your Debian version is not supported. Minimum Debian 11${NC}"
        exit 1
    elif [[ "$ID" == "ubuntu" && "$VER" < "22.04" ]]; then
        echo -e "${RED}Your Ubuntu version is not supported. Minimum Ubuntu 22.04${NC}"
        exit 1
    fi
else
    echo -e "${RED}This OS is not supported${NC}"
    exit 1
fi

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         AUTOSCRIPT TUNNELING VPN INSTALLER         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}         • Support Ubuntu 22.04+ / Debian 11+       ${NC}"
echo -e "${YELLOW}         • Optimized for 1GB RAM / 1 CPU Core       ${NC}"
echo -e "${YELLOW}         • All Files Unlocked (Editable)            ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Set timezone
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Get domain
read -p "Enter your domain: " domain
if [[ -z $domain ]]; then
    echo -e "${RED}Domain cannot be empty!${NC}"
    exit 1
fi
echo "$domain" > /root/domain.txt

# Get email for SSL
read -p "Enter your email for SSL certificate: " email
if [[ -z $email ]]; then
    email="admin@${domain}"
fi

echo ""
echo -e "${GREEN}Starting installation...${NC}"
sleep 2

# Update and install dependencies
echo -e "${CYAN}[INFO]${NC} Updating system..."
apt-get update -y
apt-get upgrade -y

echo -e "${CYAN}[INFO]${NC} Installing dependencies..."
apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    python3 \
    python3-pip \
    build-essential \
    cmake \
    screen \
    cron \
    socat \
    netfilter-persistent \
    jq \
    vnstat \
    nginx \
    certbot \
    python3-certbot-nginx \
    squid \
    dropbear \
    stunnel4 \
    fail2ban \
    vnstat \
    htop \
    speedtest-cli \
    vnstat \
    net-tools \
    dnsutils \
    bc

# Install BBR
echo -e "${CYAN}[INFO]${NC} Installing BBR..."
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# Create directories
echo -e "${CYAN}[INFO]${NC} Creating directories..."
mkdir -p /etc/tunneling
mkdir -p /etc/tunneling/ssh
mkdir -p /etc/tunneling/xray
mkdir -p /etc/tunneling/vmess
mkdir -p /etc/tunneling/vless
mkdir -p /etc/tunneling/trojan
mkdir -p /etc/tunneling/backup
mkdir -p /etc/tunneling/bot
mkdir -p /var/log/tunneling
mkdir -p /usr/local/sbin/tunneling

# Save installation info
cat > /etc/tunneling/config.json << EOF
{
    "domain": "$domain",
    "email": "$email",
    "install_date": "$(date +%Y-%m-%d)",
    "version": "1.0.0",
    "status": "active"
}
EOF

# Download and install components
echo -e "${CYAN}[INFO]${NC} Downloading components..."
cd /usr/local/sbin/tunneling

# Base URL for scripts
BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main"

# Download all menu scripts
echo -e "${CYAN}[INFO]${NC} Downloading menu scripts..."
wget -q -O main-menu.sh "${BASE_URL}/menu/main-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/main-menu.sh" -o main-menu.sh
wget -q -O ssh-menu.sh "${BASE_URL}/menu/ssh-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/ssh-menu.sh" -o ssh-menu.sh
wget -q -O vmess-menu.sh "${BASE_URL}/menu/vmess-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/vmess-menu.sh" -o vmess-menu.sh
wget -q -O vless-menu.sh "${BASE_URL}/menu/vless-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/vless-menu.sh" -o vless-menu.sh
wget -q -O trojan-menu.sh "${BASE_URL}/menu/trojan-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/trojan-menu.sh" -o trojan-menu.sh
wget -q -O system-menu.sh "${BASE_URL}/menu/system-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/system-menu.sh" -o system-menu.sh
wget -q -O backup-menu.sh "${BASE_URL}/menu/backup-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/backup-menu.sh" -o backup-menu.sh
wget -q -O bot-menu.sh "${BASE_URL}/menu/bot-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/bot-menu.sh" -o bot-menu.sh
wget -q -O settings-menu.sh "${BASE_URL}/menu/settings-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/settings-menu.sh" -o settings-menu.sh
wget -q -O info-menu.sh "${BASE_URL}/menu/info-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/info-menu.sh" -o info-menu.sh

# Download SSH scripts
echo -e "${CYAN}[INFO]${NC} Downloading SSH scripts..."
wget -q -O ssh-create.sh "${BASE_URL}/ssh/ssh-create.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-create.sh" -o ssh-create.sh
wget -q -O ssh-trial.sh "${BASE_URL}/ssh/ssh-trial.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-trial.sh" -o ssh-trial.sh
wget -q -O ssh-renew.sh "${BASE_URL}/ssh/ssh-renew.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-renew.sh" -o ssh-renew.sh
wget -q -O ssh-delete.sh "${BASE_URL}/ssh/ssh-delete.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-delete.sh" -o ssh-delete.sh
wget -q -O ssh-check.sh "${BASE_URL}/ssh/ssh-check.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-check.sh" -o ssh-check.sh
wget -q -O ssh-list.sh "${BASE_URL}/ssh/ssh-list.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-list.sh" -o ssh-list.sh
wget -q -O ssh-delete-expired.sh "${BASE_URL}/ssh/ssh-delete-expired.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-delete-expired.sh" -o ssh-delete-expired.sh
wget -q -O ssh-lock.sh "${BASE_URL}/ssh/ssh-lock.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-lock.sh" -o ssh-lock.sh
wget -q -O ssh-unlock.sh "${BASE_URL}/ssh/ssh-unlock.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-unlock.sh" -o ssh-unlock.sh
wget -q -O ssh-details.sh "${BASE_URL}/ssh/ssh-details.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-details.sh" -o ssh-details.sh
wget -q -O ssh-limit-ip.sh "${BASE_URL}/ssh/ssh-limit-ip.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-limit-ip.sh" -o ssh-limit-ip.sh
wget -q -O ssh-limit-quota.sh "${BASE_URL}/ssh/ssh-limit-quota.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/ssh-limit-quota.sh" -o ssh-limit-quota.sh
wget -q -O setup-dropbear.sh "${BASE_URL}/ssh/setup-dropbear.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/setup-dropbear.sh" -o setup-dropbear.sh
wget -q -O setup-stunnel.sh "${BASE_URL}/ssh/setup-stunnel.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/setup-stunnel.sh" -o setup-stunnel.sh
wget -q -O setup-squid.sh "${BASE_URL}/ssh/setup-squid.sh" 2>/dev/null || curl -sL "${BASE_URL}/ssh/setup-squid.sh" -o setup-squid.sh

# Download system scripts
echo -e "${CYAN}[INFO]${NC} Downloading system scripts..."
wget -q -O check-services.sh "${BASE_URL}/system/check-services.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/check-services.sh" -o check-services.sh
wget -q -O monitor-vps.sh "${BASE_URL}/system/monitor-vps.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/monitor-vps.sh" -o monitor-vps.sh
wget -q -O backup-now.sh "${BASE_URL}/system/backup-now.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/backup-now.sh" -o backup-now.sh
wget -q -O restore-backup.sh "${BASE_URL}/system/restore-backup.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/restore-backup.sh" -o restore-backup.sh
wget -q -O auto-backup.sh "${BASE_URL}/system/auto-backup.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/auto-backup.sh" -o auto-backup.sh
wget -q -O delete-expired.sh "${BASE_URL}/system/delete-expired.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/delete-expired.sh" -o delete-expired.sh
wget -q -O setup-nginx.sh "${BASE_URL}/system/setup-nginx.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/setup-nginx.sh" -o setup-nginx.sh
wget -q -O restart-all.sh "${BASE_URL}/system/restart-all.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/restart-all.sh" -o restart-all.sh
wget -q -O restart-service.sh "${BASE_URL}/system/restart-service.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/restart-service.sh" -o restart-service.sh
wget -q -O speedtest.sh "${BASE_URL}/system/speedtest.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/speedtest.sh" -o speedtest.sh
wget -q -O delete-all-expired.sh "${BASE_URL}/system/delete-all-expired.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/delete-all-expired.sh" -o delete-all-expired.sh
wget -q -O limit-speed.sh "${BASE_URL}/system/limit-speed.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/limit-speed.sh" -o limit-speed.sh
wget -q -O monitor-service.sh "${BASE_URL}/system/monitor-service.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/monitor-service.sh" -o monitor-service.sh
wget -q -O check-logs.sh "${BASE_URL}/system/check-logs.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/check-logs.sh" -o check-logs.sh
wget -q -O auto-reboot-settings.sh "${BASE_URL}/system/auto-reboot-settings.sh" 2>/dev/null || curl -sL "${BASE_URL}/system/auto-reboot-settings.sh" -o auto-reboot-settings.sh

# Download XRAY script
echo -e "${CYAN}[INFO]${NC} Downloading XRAY script..."
wget -q -O setup-xray.sh "${BASE_URL}/xray/setup-xray.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/setup-xray.sh" -o setup-xray.sh
wget -q -O vmess-create.sh "${BASE_URL}/xray/vmess-create.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-create.sh" -o vmess-create.sh
wget -q -O vmess-trial.sh "${BASE_URL}/xray/vmess-trial.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-trial.sh" -o vmess-trial.sh
wget -q -O vmess-list.sh "${BASE_URL}/xray/vmess-list.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-list.sh" -o vmess-list.sh
wget -q -O vmess-renew.sh "${BASE_URL}/xray/vmess-renew.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-renew.sh" -o vmess-renew.sh
wget -q -O vmess-delete.sh "${BASE_URL}/xray/vmess-delete.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-delete.sh" -o vmess-delete.sh
wget -q -O vmess-check.sh "${BASE_URL}/xray/vmess-check.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-check.sh" -o vmess-check.sh
wget -q -O vmess-delete-expired.sh "${BASE_URL}/xray/vmess-delete-expired.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-delete-expired.sh" -o vmess-delete-expired.sh
wget -q -O vmess-lock.sh "${BASE_URL}/xray/vmess-lock.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-lock.sh" -o vmess-lock.sh
wget -q -O vmess-unlock.sh "${BASE_URL}/xray/vmess-unlock.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-unlock.sh" -o vmess-unlock.sh
wget -q -O vmess-details.sh "${BASE_URL}/xray/vmess-details.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-details.sh" -o vmess-details.sh
wget -q -O vmess-limit-ip.sh "${BASE_URL}/xray/vmess-limit-ip.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-limit-ip.sh" -o vmess-limit-ip.sh
wget -q -O vmess-limit-quota.sh "${BASE_URL}/xray/vmess-limit-quota.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vmess-limit-quota.sh" -o vmess-limit-quota.sh

# VLESS scripts (same pattern)
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O vless-${script}.sh "${BASE_URL}/xray/vless-${script}.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/vless-${script}.sh" -o vless-${script}.sh
done

# TROJAN scripts (same pattern)
for script in create trial list renew delete check delete-expired lock unlock details limit-ip limit-quota; do
    wget -q -O trojan-${script}.sh "${BASE_URL}/xray/trojan-${script}.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/trojan-${script}.sh" -o trojan-${script}.sh
done

wget -q -O placeholder.sh "${BASE_URL}/xray/placeholder.sh" 2>/dev/null || curl -sL "${BASE_URL}/xray/placeholder.sh" -o placeholder.sh

# Download bot scripts
echo -e "${CYAN}[INFO]${NC} Downloading bot scripts..."
wget -q -O telegram_bot.py "${BASE_URL}/bot/telegram_bot.py" 2>/dev/null || curl -sL "${BASE_URL}/bot/telegram_bot.py" -o telegram_bot.py
wget -q -O bot-setup.sh "${BASE_URL}/bot/bot-setup.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-setup.sh" -o bot-setup.sh
wget -q -O bot-start.sh "${BASE_URL}/bot/bot-start.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-start.sh" -o bot-start.sh
wget -q -O bot-stop.sh "${BASE_URL}/bot/bot-stop.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-stop.sh" -o bot-stop.sh
wget -q -O bot-restart.sh "${BASE_URL}/bot/bot-restart.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-restart.sh" -o bot-restart.sh
wget -q -O bot-status.sh "${BASE_URL}/bot/bot-status.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-status.sh" -o bot-status.sh
wget -q -O bot-auto-order.sh "${BASE_URL}/bot/bot-auto-order.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-auto-order.sh" -o bot-auto-order.sh
wget -q -O bot-payment.sh "${BASE_URL}/bot/bot-payment.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-payment.sh" -o bot-payment.sh
wget -q -O bot-price.sh "${BASE_URL}/bot/bot-price.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-price.sh" -o bot-price.sh
wget -q -O bot-notification.sh "${BASE_URL}/bot/bot-notification.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-notification.sh" -o bot-notification.sh
wget -q -O bot-test.sh "${BASE_URL}/bot/bot-test.sh" 2>/dev/null || curl -sL "${BASE_URL}/bot/bot-test.sh" -o bot-test.sh

# Set permissions
chmod +x /usr/local/sbin/tunneling/*.sh

# Install XRAY
echo -e "${CYAN}[INFO]${NC} Installing XRAY..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Setup SSL Certificate
echo -e "${CYAN}[INFO]${NC} Setting up SSL certificate..."
systemctl stop nginx
certbot certonly --standalone --preferred-challenges http --agree-tos --email $email -d $domain
systemctl start nginx

# Link certificates
mkdir -p /etc/xray/certs
ln -s /etc/letsencrypt/live/$domain/fullchain.pem /etc/xray/certs/fullchain.pem
ln -s /etc/letsencrypt/live/$domain/privkey.pem /etc/xray/certs/privkey.pem

# Configure cron for SSL renewal
echo "0 3 * * * root certbot renew --quiet --post-hook 'systemctl reload nginx'" > /etc/cron.d/ssl-renewal

# Setup auto reboot
echo "0 5 * * * root /sbin/reboot" > /etc/cron.d/auto-reboot

# Setup auto delete expired accounts
echo "0 0 * * * root /usr/local/sbin/tunneling/delete-expired.sh" > /etc/cron.d/delete-expired

# Setup auto backup
echo "0 2 * * * root /usr/local/sbin/tunneling/auto-backup.sh" > /etc/cron.d/auto-backup

# Configure firewall
echo -e "${CYAN}[INFO]${NC} Configuring firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 2082/tcp
ufw allow 2086/tcp
ufw allow 2087/tcp
ufw allow 2095/tcp
ufw allow 2096/tcp
ufw allow 3128/tcp
ufw allow 7300/tcp
ufw allow 109/tcp
ufw allow 143/tcp
ufw allow 442/tcp
ufw reload

# Create menu command
cat > /usr/bin/menu << 'EOF'
#!/bin/bash
/usr/local/sbin/tunneling/main-menu.sh
EOF
chmod +x /usr/bin/menu

# Final setup
echo -e "${CYAN}[INFO]${NC} Finalizing installation..."
systemctl enable nginx
systemctl enable xray
systemctl enable fail2ban
systemctl restart nginx
systemctl restart xray

# Clean up
apt-get clean
apt-get autoremove -y

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          INSTALLATION COMPLETED SUCCESSFULLY!        ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Domain       : ${NC}$domain"
echo -e "${YELLOW}IP Address   : ${NC}$(curl -s ifconfig.me)"
echo -e "${YELLOW}Install Date : ${NC}$(date +%Y-%m-%d)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Type 'menu' to access the control panel${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
rm -f setup.sh
