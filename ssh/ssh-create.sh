#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DOMAIN=$(cat /root/domain.txt)

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}               CREATE SSH ACCOUNT                    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username: " username
read -p "Password: " password
read -p "Expired (days): " exp
read -p "Limit IP (0=unlimited): " limit_ip
read -p "Limit Quota GB (0=unlimited): " limit_quota

if [[ -z $username || -z $password || -z $exp ]]; then
    echo -e "${RED}All fields are required!${NC}"
    exit 1
fi

# Check if user exists
if id "$username" &>/dev/null; then
    echo -e "${RED}User already exists!${NC}"
    exit 1
fi

# Create user
useradd -e $(date -d "$exp days" +"%Y-%m-%d") -s /bin/false -M $username
echo -e "$password\n$password\n" | passwd $username &> /dev/null

# Save user data
mkdir -p /etc/tunneling/ssh
cat > /etc/tunneling/ssh/$username.json << EOF
{
    "username": "$username",
    "password": "$password",
    "created": "$(date +%Y-%m-%d)",
    "expired": "$(date -d "$exp days" +"%Y-%m-%d")",
    "limit_ip": "$limit_ip",
    "limit_quota": "$limit_quota",
    "status": "active"
}
EOF

# Get expiration date
exp_date=$(date -d "$exp days" +"%d %b %Y")

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}            SSH ACCOUNT CREATED SUCCESSFULLY         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Domain       ${NC}: $DOMAIN"
echo -e "${YELLOW}Username     ${NC}: $username"
echo -e "${YELLOW}Password     ${NC}: $password"
echo -e "${YELLOW}Expired Date ${NC}: $exp_date"
echo -e "${YELLOW}Limit IP     ${NC}: $limit_ip"
echo -e "${YELLOW}Limit Quota  ${NC}: ${limit_quota}GB"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}SSH Ports:${NC}"
echo -e "  - OpenSSH  : 22"
echo -e "  - Dropbear : 109, 143"
echo -e "  - SSL/TLS  : 442, 443"
echo -e "  - Squid    : 3128, 8080"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}WebSocket:${NC}"
echo -e "  - WS HTTP  : ws://$DOMAIN:80/"
echo -e "  - WS HTTPS : wss://$DOMAIN:443/"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}OpenVPN Config:${NC}"
echo -e "  - TCP      : http://$DOMAIN:89/tcp.ovpn"
echo -e "  - UDP      : http://$DOMAIN:89/udp.ovpn"
echo -e "  - SSL      : http://$DOMAIN:89/ssl.ovpn"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Payload/Config:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[OpenSSH - Port 22]${NC}"
echo -e "GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
echo -e ""
echo -e "${GREEN}[Dropbear - Port 109/143]${NC}"
echo -e "GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
echo -e ""
echo -e "${GREEN}[SSL/TLS - Port 443]${NC}"
echo -e "GET wss://$DOMAIN/ HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf]"
echo -e ""
echo -e "${GREEN}[Squid Proxy - Port 3128/8080]${NC}"
echo -e "CONNECT [host_port] HTTP/1.0[crlf][crlf]GET / HTTP/1.1[crlf]Host: $DOMAIN[crlf][crlf]"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back to menu"
/usr/local/sbin/tunneling/ssh-menu.sh
