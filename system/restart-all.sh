#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}            RESTART ALL SERVICES                   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}Restarting all VPN services...${NC}"
echo ""

# Restart SSH services
echo -e "${CYAN}[1/7] Restarting SSH services...${NC}"
systemctl restart ssh
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart squid
echo -e "${GREEN}✓ SSH services restarted${NC}"
echo ""

# Restart XRAY
echo -e "${CYAN}[2/7] Restarting XRAY...${NC}"
systemctl restart xray
echo -e "${GREEN}✓ XRAY restarted${NC}"
echo ""

# Restart NGINX
echo -e "${CYAN}[3/7] Restarting NGINX...${NC}"
systemctl restart nginx
echo -e "${GREEN}✓ NGINX restarted${NC}"
echo ""

# Restart Cron
echo -e "${CYAN}[4/7] Restarting Cron...${NC}"
systemctl restart cron
echo -e "${GREEN}✓ Cron restarted${NC}"
echo ""

# Restart Netfilter
echo -e "${CYAN}[5/7] Restarting Netfilter...${NC}"
systemctl restart netfilter-persistent
echo -e "${GREEN}✓ Netfilter restarted${NC}"
echo ""

# Restart fail2ban if installed
echo -e "${CYAN}[6/7] Restarting fail2ban...${NC}"
if systemctl is-active --quiet fail2ban; then
    systemctl restart fail2ban
    echo -e "${GREEN}✓ fail2ban restarted${NC}"
else
    echo -e "${YELLOW}✓ fail2ban not installed${NC}"
fi
echo ""

# Clear cache
echo -e "${CYAN}[7/7] Clearing cache...${NC}"
sync; echo 3 > /proc/sys/vm/drop_caches
echo -e "${GREEN}✓ Cache cleared${NC}"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}All services restarted successfully!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/system-menu.sh
