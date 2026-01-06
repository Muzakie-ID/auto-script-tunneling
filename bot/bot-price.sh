#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PRICE_FILE="/etc/tunneling/bot/prices.json"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           PRICE LIST SETTINGS                     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create default price list if not exists
if [ ! -f "$PRICE_FILE" ]; then
    cat > $PRICE_FILE << 'EOF'
{
    "ssh_7": {"name": "SSH 7 Days", "price": 10000, "days": 7, "type": "ssh"},
    "ssh_30": {"name": "SSH 30 Days", "price": 30000, "days": 30, "type": "ssh"},
    "vmess_7": {"name": "VMESS 7 Days", "price": 15000, "days": 7, "type": "vmess"},
    "vmess_30": {"name": "VMESS 30 Days", "price": 50000, "days": 30, "type": "vmess"},
    "vless_7": {"name": "VLESS 7 Days", "price": 15000, "days": 7, "type": "vless"},
    "vless_30": {"name": "VLESS 30 Days", "price": 50000, "days": 30, "type": "vless"},
    "trojan_7": {"name": "TROJAN 7 Days", "price": 15000, "days": 7, "type": "trojan"},
    "trojan_30": {"name": "TROJAN 30 Days", "price": 50000, "days": 30, "type": "trojan"}
}
EOF
fi

# Display current prices
echo -e "${YELLOW}Current Price List:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

jq -r 'to_entries[] | "\(.key): \(.value.name) - Rp\(.value.price)"' $PRICE_FILE | while read line; do
    echo -e "  $line"
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}Select package to edit:${NC}"
echo -e "${GREEN}  [1]${NC} SSH 7 Days"
echo -e "${GREEN}  [2]${NC} SSH 30 Days"
echo -e "${GREEN}  [3]${NC} VMESS 7 Days"
echo -e "${GREEN}  [4]${NC} VMESS 30 Days"
echo -e "${GREEN}  [5]${NC} VLESS 7 Days"
echo -e "${GREEN}  [6]${NC} VLESS 30 Days"
echo -e "${GREEN}  [7]${NC} TROJAN 7 Days"
echo -e "${GREEN}  [8]${NC} TROJAN 30 Days"
echo -e "${RED}  [0]${NC} Back"
echo ""
read -p "Select package [0-8]: " package

case $package in
    1) PACKAGE_KEY="ssh_7" ;;
    2) PACKAGE_KEY="ssh_30" ;;
    3) PACKAGE_KEY="vmess_7" ;;
    4) PACKAGE_KEY="vmess_30" ;;
    5) PACKAGE_KEY="vless_7" ;;
    6) PACKAGE_KEY="vless_30" ;;
    7) PACKAGE_KEY="trojan_7" ;;
    8) PACKAGE_KEY="trojan_30" ;;
    0)
        /usr/local/sbin/tunneling/bot-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/bot-menu.sh
        exit 0
        ;;
esac

# Get current price
CURRENT_PRICE=$(jq -r ".$PACKAGE_KEY.price" $PRICE_FILE)

echo ""
echo -e "${YELLOW}Current price: Rp${CURRENT_PRICE}${NC}"
read -p "Enter new price (Rp): " new_price

if [[ ! "$new_price" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid price! Must be a number${NC}"
    sleep 2
    /usr/local/sbin/tunneling/bot-menu.sh
    exit 1
fi

# Update price
jq ".$PACKAGE_KEY.price = $new_price" $PRICE_FILE > /tmp/prices.tmp && mv /tmp/prices.tmp $PRICE_FILE

echo ""
echo -e "${GREEN}✓ Price updated successfully!${NC}"
echo -e "${YELLOW}Restarting bot...${NC}"
systemctl restart telegram-bot 2>/dev/null
sleep 2

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/bot-menu.sh
