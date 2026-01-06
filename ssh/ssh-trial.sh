#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DOMAIN=$(cat /root/domain.txt)

# Generate random username and password
username="trial$(< /dev/urandom tr -dc a-z0-9 | head -c6)"
password=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c10)
exp=0.04 # 1 hour in days
limit_ip=1
limit_quota=1

# Create user
useradd -e $(date -d "1 hour" +"%Y-%m-%d %H:%M:%S") -s /bin/false -M $username
echo -e "$password\n$password\n" | passwd $username &> /dev/null

# Save user data
mkdir -p /etc/tunneling/ssh
cat > /etc/tunneling/ssh/$username.json << EOF
{
    "username": "$username",
    "password": "$password",
    "created": "$(date +%Y-%m-%d\ %H:%M:%S)",
    "expired": "$(date -d "1 hour" +"%Y-%m-%d %H:%M:%S")",
    "limit_ip": "$limit_ip",
    "limit_quota": "$limit_quota",
    "status": "trial"
}
EOF

exp_date=$(date -d "1 hour" +"%d %b %Y %H:%M")

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}            TRIAL SSH ACCOUNT CREATED                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Domain       ${NC}: $DOMAIN"
echo -e "${YELLOW}Username     ${NC}: $username"
echo -e "${YELLOW}Password     ${NC}: $password"
echo -e "${YELLOW}Expired      ${NC}: $exp_date ${RED}(1 Hour)${NC}"
echo -e "${YELLOW}Limit IP     ${NC}: $limit_ip"
echo -e "${YELLOW}Limit Quota  ${NC}: ${limit_quota}GB"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}SSH Ports:${NC}"
echo -e "  - OpenSSH  : 22"
echo -e "  - Dropbear : 109, 143"
echo -e "  - SSL/TLS  : 442, 443"
echo -e "  - Squid    : 3128, 8080"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/ssh-menu.sh
