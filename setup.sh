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

# Base URL for scripts (will be updated)
BASE_URL="https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main"

# Download all scripts
wget -q -O ssh-menu.sh "${BASE_URL}/menu/ssh-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/ssh-menu.sh" -o ssh-menu.sh
wget -q -O xray-menu.sh "${BASE_URL}/menu/xray-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/xray-menu.sh" -o xray-menu.sh
wget -q -O main-menu.sh "${BASE_URL}/menu/main-menu.sh" 2>/dev/null || curl -sL "${BASE_URL}/menu/main-menu.sh" -o main-menu.sh

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
