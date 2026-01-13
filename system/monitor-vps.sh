#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}                  VPS MONITORING                     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# System info
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | cut -d " " -f 2-10)

# CPU info
CPU_MODEL=$(lscpu | grep "Model name" | cut -d ":" -f2 | xargs)
CPU_CORES=$(nproc)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

# Memory info
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f MB", $2}')
USED_RAM=$(free -m | awk 'NR==2{printf "%.0f MB", $3}')
FREE_RAM=$(free -m | awk 'NR==2{printf "%.0f MB", $4}')
RAM_PERCENT=$(free | awk 'NR==2{printf "%.2f%%", $3*100/$2}')

# Disk info
TOTAL_DISK=$(df -h / | awk 'NR==2{print $2}')
USED_DISK=$(df -h / | awk 'NR==2{print $3}')
FREE_DISK=$(df -h / | awk 'NR==2{print $4}')
DISK_PERCENT=$(df -h / | awk 'NR==2{print $5}')

# Network info
INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
IP_ADDRESS=$(curl -s ifconfig.me)
RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
RX_GB=$(echo "scale=2; $RX_BYTES/1024/1024/1024" | bc)
TX_GB=$(echo "scale=2; $TX_BYTES/1024/1024/1024" | bc)

echo -e "${YELLOW}System Information:${NC}"
echo -e "Hostname       : $HOSTNAME"
echo -e "Kernel         : $KERNEL"
echo -e "Uptime         : $UPTIME"
echo ""

echo -e "${YELLOW}CPU Information:${NC}"
echo -e "Model          : $CPU_MODEL"
echo -e "Cores          : $CPU_CORES"
echo -e "Usage          : $CPU_USAGE"
echo ""

echo -e "${YELLOW}Memory Information:${NC}"
echo -e "Total RAM      : $TOTAL_RAM"
echo -e "Used RAM       : $USED_RAM ($RAM_PERCENT)"
echo -e "Free RAM       : $FREE_RAM"
echo ""

echo -e "${YELLOW}Disk Information:${NC}"
echo -e "Total Disk     : $TOTAL_DISK"
echo -e "Used Disk      : $USED_DISK ($DISK_PERCENT)"
echo -e "Free Disk      : $FREE_DISK"
echo ""

echo -e "${YELLOW}Network Information:${NC}"
echo -e "Interface      : $INTERFACE"
echo -e "IP Address     : $IP_ADDRESS"
echo -e "Download       : ${RX_GB} GB"
echo -e "Upload         : ${TX_GB} GB"
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/menu/system-menu.sh
