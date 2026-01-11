#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="/etc/tunneling/bot/config.json"
QRIS_DIR="/etc/tunneling/bot/qris"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          PAYMENT SETTINGS (QRIS)                  ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Bot not configured yet!${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    /usr/local/sbin/tunneling/menu/bot-menu.sh
    exit 1
fi

# Create QRIS directory
mkdir -p $QRIS_DIR

# Get current settings
QRIS_ENABLED=$(jq -r '.payment.qris_enabled // "false"' $CONFIG_FILE)
QRIS_NAME=$(jq -r '.payment.qris_name // "Not set"' $CONFIG_FILE)
QRIS_IMAGE=$(jq -r '.payment.qris_image // "Not set"' $CONFIG_FILE)

echo -e "${YELLOW}Current QRIS Settings:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Status      : $QRIS_ENABLED"
echo -e "Wallet Name : $QRIS_NAME"
echo -e "Image       : $QRIS_IMAGE"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}  [1]${NC} Enable QRIS Payment"
echo -e "${GREEN}  [2]${NC} Disable QRIS Payment"
echo -e "${GREEN}  [3]${NC} Upload QRIS Image"
echo -e "${GREEN}  [4]${NC} Set Wallet Name"
echo -e "${RED}  [0]${NC} Back"
echo ""
read -p "Select option [0-4]: " option

case $option in
    1)
        jq '.payment.qris_enabled = true' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
        echo ""
        echo -e "${GREEN}✓ QRIS payment enabled!${NC}"
        ;;
    2)
        jq '.payment.qris_enabled = false' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
        echo ""
        echo -e "${GREEN}✓ QRIS payment disabled!${NC}"
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Upload QRIS Image:${NC}"
        echo "1. Put your QRIS image (qris.jpg/qris.png) in: $QRIS_DIR/"
        echo "2. Or enter URL to download"
        echo ""
        read -p "Enter image URL (or press Enter to skip): " qris_url
        
        if [ -n "$qris_url" ]; then
            echo -e "${YELLOW}Downloading QRIS image...${NC}"
            wget -q -O $QRIS_DIR/qris.jpg "$qris_url"
            
            if [ -f "$QRIS_DIR/qris.jpg" ]; then
                jq ".payment.qris_image = \"$QRIS_DIR/qris.jpg\"" $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
                echo -e "${GREEN}✓ QRIS image uploaded!${NC}"
            else
                echo -e "${RED}✗ Failed to download image${NC}"
            fi
        else
            # Check if file exists
            if [ -f "$QRIS_DIR/qris.jpg" ] || [ -f "$QRIS_DIR/qris.png" ]; then
                if [ -f "$QRIS_DIR/qris.jpg" ]; then
                    IMAGE_PATH="$QRIS_DIR/qris.jpg"
                else
                    IMAGE_PATH="$QRIS_DIR/qris.png"
                fi
                jq ".payment.qris_image = \"$IMAGE_PATH\"" $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
                echo -e "${GREEN}✓ QRIS image path updated!${NC}"
            else
                echo -e "${RED}No QRIS image found in $QRIS_DIR/${NC}"
            fi
        fi
        ;;
    4)
        echo ""
        read -p "Enter wallet name (e.g., GoPay, OVO, DANA): " wallet_name
        
        if [ -n "$wallet_name" ]; then
            jq ".payment.qris_name = \"$wallet_name\"" $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo ""
            echo -e "${GREEN}✓ Wallet name updated!${NC}"
        else
            echo -e "${RED}Wallet name cannot be empty!${NC}"
        fi
        ;;
    0)
        /usr/local/sbin/tunneling/menu/bot-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        ;;
esac

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/bot-menu.sh
