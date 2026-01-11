#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="/etc/tunneling/bot/config.json"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          NOTIFICATION SETTINGS                    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Bot not configured yet!${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    /usr/local/sbin/tunneling/menu/bot-menu.sh
    exit 1
fi

# Get current notification settings
NEW_USER=$(jq -r '.notification.new_user // "true"' $CONFIG_FILE)
ORDER=$(jq -r '.notification.order // "true"' $CONFIG_FILE)
PAYMENT=$(jq -r '.notification.payment // "true"' $CONFIG_FILE)
EXPIRED=$(jq -r '.notification.expired // "true"' $CONFIG_FILE)

echo -e "${YELLOW}Current Notification Settings:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "New User       : $NEW_USER"
echo -e "New Order      : $ORDER"
echo -e "Payment Confirm: $PAYMENT"
echo -e "Account Expired: $EXPIRED"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}Select notification to toggle:${NC}"
echo -e "${GREEN}  [1]${NC} New User Notification"
echo -e "${GREEN}  [2]${NC} New Order Notification"
echo -e "${GREEN}  [3]${NC} Payment Confirmation Notification"
echo -e "${GREEN}  [4]${NC} Account Expired Notification"
echo -e "${GREEN}  [5]${NC} Enable All"
echo -e "${GREEN}  [6]${NC} Disable All"
echo -e "${RED}  [0]${NC} Back"
echo ""
read -p "Select option [0-6]: " option

case $option in
    1)
        if [ "$NEW_USER" == "true" ]; then
            jq '.notification.new_user = false' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${YELLOW}New User notification disabled${NC}"
        else
            jq '.notification.new_user = true' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${GREEN}New User notification enabled${NC}"
        fi
        ;;
    2)
        if [ "$ORDER" == "true" ]; then
            jq '.notification.order = false' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${YELLOW}Order notification disabled${NC}"
        else
            jq '.notification.order = true' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${GREEN}Order notification enabled${NC}"
        fi
        ;;
    3)
        if [ "$PAYMENT" == "true" ]; then
            jq '.notification.payment = false' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${YELLOW}Payment notification disabled${NC}"
        else
            jq '.notification.payment = true' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${GREEN}Payment notification enabled${NC}"
        fi
        ;;
    4)
        if [ "$EXPIRED" == "true" ]; then
            jq '.notification.expired = false' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${YELLOW}Expired notification disabled${NC}"
        else
            jq '.notification.expired = true' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
            echo -e "${GREEN}Expired notification enabled${NC}"
        fi
        ;;
    5)
        jq '.notification = {
            "new_user": true,
            "order": true,
            "payment": true,
            "expired": true
        }' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
        echo -e "${GREEN}All notifications enabled${NC}"
        ;;
    6)
        jq '.notification = {
            "new_user": false,
            "order": false,
            "payment": false,
            "expired": false
        }' $CONFIG_FILE > /tmp/config.tmp && mv /tmp/config.tmp $CONFIG_FILE
        echo -e "${YELLOW}All notifications disabled${NC}"
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
