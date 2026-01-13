#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              FIX ERROR PROXY                      ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}This will fix common proxy issues:${NC}"
echo "  • Reset Squid configuration"
echo "  • Fix ACL rules"
echo "  • Restart proxy services"
echo ""
read -p "Continue? [y/n]: " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    /usr/local/sbin/tunneling/menu/settings-menu.sh
    exit 0
fi

echo ""
echo -e "${CYAN}[1/4]${NC} Stopping Squid..."
systemctl stop squid

echo -e "${CYAN}[2/4]${NC} Resetting configuration..."
cat > /etc/squid/squid.conf <<EOF
# Squid Proxy Configuration
http_port 3128
http_port 8080

# ACL Rules
acl localnet src 0.0.0.1-0.255.255.255
acl localnet src 10.0.0.0/8
acl localnet src 100.64.0.0/10
acl localnet src 169.254.0.0/16
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localnet src fc00::/7
acl localnet src fe80::/10

acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT

# Access Control
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localnet
http_access allow localhost
http_access deny all

# Cache Settings
cache_dir ufs /var/spool/squid 100 16 256
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320

# Misc
coredump_dir /var/spool/squid
visible_hostname proxy.tunneling
EOF

echo -e "${CYAN}[3/4]${NC} Rebuilding cache..."
squid -z

echo -e "${CYAN}[4/4]${NC} Starting Squid..."
systemctl start squid

if systemctl is-active --quiet squid; then
    echo ""
    echo -e "${GREEN}✓ Proxy errors fixed successfully!${NC}"
else
    echo ""
    echo -e "${RED}✗ Failed to start Squid!${NC}"
    echo -e "${YELLOW}Check logs: journalctl -u squid -n 50${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/settings-menu.sh
