#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              CHANGE SERVICE PORTS                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Select Service:${NC}"
echo "  [1] OpenSSH (Current: 22)"
echo "  [2] Dropbear (Current: 109, 143)"
echo "  [3] Stunnel/SSL (Current: 442, 443)"
echo "  [4] Squid Proxy (Current: 3128, 8080)"
echo "  [5] XRAY (Current: 443)"
echo ""
echo "  [0] Back"
echo ""
read -p "Select [0-5]: " choice

case $choice in
    1)
        read -p "Enter new OpenSSH port [22-65535]: " new_port
        if [[ $new_port =~ ^[0-9]+$ ]] && [ $new_port -ge 22 ] && [ $new_port -le 65535 ]; then
            sed -i "s/^Port .*/Port $new_port/" /etc/ssh/sshd_config
            systemctl restart sshd
            echo -e "${GREEN}✓ OpenSSH port changed to $new_port${NC}"
        else
            echo -e "${RED}Invalid port number!${NC}"
        fi
        ;;
    2)
        read -p "Enter new Dropbear port 1 [1-65535]: " port1
        read -p "Enter new Dropbear port 2 [1-65535]: " port2
        if [[ $port1 =~ ^[0-9]+$ ]] && [[ $port2 =~ ^[0-9]+$ ]]; then
            sed -i "s/DROPBEAR_PORT=.*/DROPBEAR_PORT=\"$port1\"/" /etc/default/dropbear
            sed -i "s/DROPBEAR_EXTRA_ARGS=.*/DROPBEAR_EXTRA_ARGS=\"-p $port2\"/" /etc/default/dropbear
            systemctl restart dropbear
            echo -e "${GREEN}✓ Dropbear ports changed to $port1 and $port2${NC}"
        else
            echo -e "${RED}Invalid port number!${NC}"
        fi
        ;;
    3)
        echo -e "${YELLOW}Stunnel ports are fixed at 442 and 443 for SSL${NC}"
        ;;
    4)
        read -p "Enter new Squid port 1 [1-65535]: " port1
        read -p "Enter new Squid port 2 [1-65535]: " port2
        if [[ $port1 =~ ^[0-9]+$ ]] && [[ $port2 =~ ^[0-9]+$ ]]; then
            sed -i "s/http_port .*/http_port $port1/" /etc/squid/squid.conf
            sed -i "/http_port $port1/a http_port $port2" /etc/squid/squid.conf
            systemctl restart squid
            echo -e "${GREEN}✓ Squid ports changed to $port1 and $port2${NC}"
        else
            echo -e "${RED}Invalid port number!${NC}"
        fi
        ;;
    5)
        echo -e "${YELLOW}XRAY port is fixed at 443 for TLS${NC}"
        ;;
    0)
        /usr/local/sbin/tunneling/menu/settings-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        ;;
esac

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/change-port.sh
