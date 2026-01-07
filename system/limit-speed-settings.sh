#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Config file
CONFIG_FILE="/etc/tunneling/limit-speed.conf"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              LIMIT SPEED SETTINGS                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show current settings
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Current Settings:${NC}"
    cat "$CONFIG_FILE"
    echo ""
else
    echo -e "${YELLOW}No speed limit configured${NC}"
    echo ""
fi

echo -e "${YELLOW}Speed Limit Options:${NC}"
echo "  [1] Enable Speed Limit"
echo "  [2] Disable Speed Limit"
echo "  [3] View Current Limits"
echo "  [0] Back"
echo ""
read -p "Select [0-3]: " choice

case $choice in
    1)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}              ENABLE SPEED LIMIT                   ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        read -p "Enter download speed limit (Mbps): " download_limit
        read -p "Enter upload speed limit (Mbps): " upload_limit
        
        if [[ $download_limit =~ ^[0-9]+$ ]] && [[ $upload_limit =~ ^[0-9]+$ ]]; then
            mkdir -p /etc/tunneling
            cat > "$CONFIG_FILE" <<EOF
DOWNLOAD_LIMIT=${download_limit}Mbps
UPLOAD_LIMIT=${upload_limit}Mbps
ENABLED=true
EOF
            
            # Apply with tc (traffic control)
            interface=$(ip route | grep default | awk '{print $5}' | head -n1)
            
            # Clear existing rules
            tc qdisc del dev "$interface" root 2>/dev/null
            
            # Add new rules
            tc qdisc add dev "$interface" root handle 1: htb default 12
            tc class add dev "$interface" parent 1: classid 1:1 htb rate "${download_limit}mbit"
            tc class add dev "$interface" parent 1:1 classid 1:12 htb rate "${download_limit}mbit" ceil "${download_limit}mbit"
            
            echo ""
            echo -e "${GREEN}✓ Speed limit enabled!${NC}"
            echo -e "${YELLOW}Download:${NC} ${download_limit}Mbps"
            echo -e "${YELLOW}Upload:${NC} ${upload_limit}Mbps"
        else
            echo -e "${RED}Invalid speed values!${NC}"
        fi
        ;;
        
    2)
        if [ -f "$CONFIG_FILE" ]; then
            interface=$(ip route | grep default | awk '{print $5}' | head -n1)
            tc qdisc del dev "$interface" root 2>/dev/null
            
            sed -i 's/ENABLED=true/ENABLED=false/' "$CONFIG_FILE"
            echo ""
            echo -e "${GREEN}✓ Speed limit disabled!${NC}"
        else
            echo -e "${YELLOW}Speed limit was not configured${NC}"
        fi
        ;;
        
    3)
        echo ""
        echo -e "${YELLOW}Current Traffic Control Rules:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        interface=$(ip route | grep default | awk '{print $5}' | head -n1)
        tc -s qdisc show dev "$interface"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        ;;
        
    0)
        /usr/local/sbin/tunneling/settings-menu.sh
        exit 0
        ;;
        
    *)
        echo -e "${RED}Invalid option!${NC}"
        ;;
esac

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/limit-speed-settings.sh
