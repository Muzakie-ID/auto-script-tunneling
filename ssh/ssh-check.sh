#!/bin/bash
# Check SSH Login Sessions

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        ACTIVE SSH SESSIONS              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

data=($(ps aux | grep -i dropbear | awk '{print $2}'))
echo -e "${GREEN}Dropbear Sessions:${NC}"
for PID in "${data[@]}"; do
    num=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | wc -l)
    user=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $10}')
    ip=$(cat /var/log/auth.log | grep -i dropbear | grep -i "Password auth succeeded" | grep "dropbear\[$PID\]" | awk '{print $12}')
    if [ $num -eq 1 ]; then
        echo -e "${YELLOW}→${NC} User: $user | IP: $ip | PID: $PID"
    fi
done
echo ""

echo -e "${GREEN}OpenSSH Sessions:${NC}"
w -h | awk '{print $1, $3}'
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Total Active:${NC} $(ps aux | grep -i sshd | grep -v grep | wc -l) OpenSSH + $(ps aux | grep -i dropbear | grep -v grep | wc -l) Dropbear"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
