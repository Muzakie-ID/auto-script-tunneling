#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}             LIMIT SPEED VPS                      ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get network interface
IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

echo -e "${YELLOW}Network Interface: ${GREEN}$IFACE${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Set Speed Limit"
echo -e "${GREEN}  [2]${NC} Remove Speed Limit"
echo -e "${GREEN}  [3]${NC} Check Current Limit"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select option [0-3]: " option

case $option in
    1)
        echo ""
        echo -e "${YELLOW}Enter speed limit (in Mbit/s):${NC}"
        read -p "Speed limit: " limit
        
        if [[ ! "$limit" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid input! Please enter a number.${NC}"
            sleep 2
            /usr/local/sbin/tunneling/limit-speed.sh
            exit 0
        fi
        
        echo ""
        echo -e "${YELLOW}Applying speed limit of ${limit}Mbit/s...${NC}"
        
        # Remove existing limits
        tc qdisc del dev $IFACE root 2>/dev/null
        
        # Apply new limit
        tc qdisc add dev $IFACE root tbf rate ${limit}mbit burst 32kbit latency 400ms
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Speed limit applied successfully!${NC}"
        else
            echo -e "${RED}✗ Failed to apply speed limit${NC}"
        fi
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Removing speed limit...${NC}"
        tc qdisc del dev $IFACE root 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Speed limit removed successfully!${NC}"
        else
            echo -e "${YELLOW}✓ No speed limit found${NC}"
        fi
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Current traffic control settings:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Check if TBF (Token Bucket Filter) is applied
        CURRENT_QDISC=$(tc qdisc show dev $IFACE | grep "qdisc tbf")
        
        if [ -n "$CURRENT_QDISC" ]; then
            # Extract rate from tbf settings
            RATE=$(echo "$CURRENT_QDISC" | grep -oP 'rate \K[0-9]+[A-Za-z]+')
            echo -e "${GREEN}✓ Speed Limit Active${NC}"
            echo -e "  Interface : $IFACE"
            echo -e "  Limit     : $RATE"
            echo ""
            echo -e "${YELLOW}Full settings:${NC}"
            echo "$CURRENT_QDISC"
        else
            echo -e "${YELLOW}✓ No Speed Limit Applied${NC}"
            echo -e "  Interface : $IFACE"
            echo -e "  Status    : Using default qdisc (no bandwidth limit)"
            echo ""
            echo -e "${YELLOW}Current qdisc:${NC}"
            tc qdisc show dev $IFACE
        fi
        
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        ;;
    0)
        /usr/local/sbin/tunneling/system-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/limit-speed.sh
        exit 0
        ;;
esac

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/system-menu.sh
