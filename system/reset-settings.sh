#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              RESET SETTINGS                       ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${RED}WARNING: This will reset all settings to default!${NC}"
echo ""
echo -e "${YELLOW}This will:${NC}"
echo "  • Remove domain configuration"
echo "  • Reset SSH banner"
echo "  • Reset service ports to default"
echo "  • Remove SSL certificates"
echo "  • Remove speed limits"
echo "  • Reset timezone to UTC"
echo "  • Keep user accounts intact"
echo ""
read -p "Are you sure? Type 'YES' to confirm: " confirm

if [[ "$confirm" != "YES" ]]; then
    echo -e "${YELLOW}Reset cancelled${NC}"
    sleep 2
    /usr/local/sbin/tunneling/settings-menu.sh
    exit 0
fi

echo ""
echo -e "${CYAN}[1/7]${NC} Resetting domain..."
rm -f /root/domain.txt /etc/xray/domain

echo -e "${CYAN}[2/7]${NC} Resetting SSH banner..."
cat > /etc/issue.net <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     WELCOME TO VPN TUNNELING SERVICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      Unauthorized access is prohibited
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

echo -e "${CYAN}[3/7]${NC} Resetting ports..."
# Reset SSH
sed -i 's/^Port .*/Port 22/' /etc/ssh/sshd_config
systemctl restart sshd

# Reset Dropbear
sed -i 's/DROPBEAR_PORT=.*/DROPBEAR_PORT="109"/' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=.*/DROPBEAR_EXTRA_ARGS="-p 143"/' /etc/default/dropbear
systemctl restart dropbear

# Reset Squid
cat > /etc/squid/squid.conf <<EOF
http_port 3128
http_port 8080
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl Safe_ports port 80
acl Safe_ports port 443
acl Safe_ports port 1025-65535
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access deny CONNECT !Safe_ports
http_access allow localnet
http_access allow localhost
http_access deny all
EOF
systemctl restart squid

echo -e "${CYAN}[4/7]${NC} Removing SSL certificates..."
rm -rf ~/.acme.sh/*
rm -f /etc/xray/xray.crt /etc/xray/xray.key

echo -e "${CYAN}[5/7]${NC} Removing speed limits..."
interface=$(ip route | grep default | awk '{print $5}' | head -n1)
tc qdisc del dev "$interface" root 2>/dev/null
rm -f /etc/tunneling/limit-speed.conf

echo -e "${CYAN}[6/7]${NC} Resetting timezone..."
timedatectl set-timezone UTC

echo -e "${CYAN}[7/7]${NC} Restarting services..."
systemctl restart nginx xray sshd dropbear squid stunnel4

echo ""
echo -e "${GREEN}✓ All settings have been reset to default!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Configure your domain"
echo "  2. Setup SSL certificate"
echo "  3. Adjust other settings as needed"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/settings-menu.sh
