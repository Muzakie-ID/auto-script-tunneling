#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CRON_FILE="/etc/cron.d/auto-reboot"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}           AUTO REBOOT SETTINGS                   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check current setting
if [ -f "$CRON_FILE" ]; then
    CURRENT_TIME=$(grep "reboot" $CRON_FILE | awk '{print $2":"$1}')
    echo -e "${YELLOW}Current auto reboot: ${GREEN}Enabled${NC} at ${GREEN}$CURRENT_TIME${NC}"
else
    echo -e "${YELLOW}Current auto reboot: ${RED}Disabled${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  [1]${NC} Enable Auto Reboot"
echo -e "${GREEN}  [2]${NC} Disable Auto Reboot"
echo -e "${GREEN}  [3]${NC} Change Reboot Time"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  [0]${NC} Back"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select option [0-3]: " option

case $option in
    1)
        echo ""
        echo -e "${YELLOW}Enable Auto Reboot${NC}"
        echo ""
        read -p "Enter reboot time (HH:MM, 24-hour format): " time
        
        # Validate time format
        if [[ ! $time =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
            echo -e "${RED}Invalid time format! Use HH:MM (e.g., 03:00)${NC}"
            sleep 2
            /usr/local/sbin/tunneling/auto-reboot-settings.sh
            exit 0
        fi
        
        HOUR=$(echo $time | cut -d: -f1)
        MINUTE=$(echo $time | cut -d: -f2)
        
        # Create cron job
        echo "# Auto Reboot Daily" > $CRON_FILE
        echo "$MINUTE $HOUR * * * root /sbin/reboot" >> $CRON_FILE
        
        # Restart cron
        systemctl restart cron
        
        echo -e "${GREEN}✓ Auto reboot enabled at $time${NC}"
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Disabling auto reboot...${NC}"
        
        if [ -f "$CRON_FILE" ]; then
            rm -f $CRON_FILE
            systemctl restart cron
            echo -e "${GREEN}✓ Auto reboot disabled${NC}"
        else
            echo -e "${YELLOW}✓ Auto reboot is already disabled${NC}"
        fi
        ;;
    3)
        if [ ! -f "$CRON_FILE" ]; then
            echo ""
            echo -e "${RED}Auto reboot is not enabled!${NC}"
            echo -e "${YELLOW}Please enable it first (option 1)${NC}"
        else
            echo ""
            echo -e "${YELLOW}Change Reboot Time${NC}"
            echo ""
            read -p "Enter new reboot time (HH:MM, 24-hour format): " time
            
            # Validate time format
            if [[ ! $time =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
                echo -e "${RED}Invalid time format! Use HH:MM (e.g., 03:00)${NC}"
                sleep 2
                /usr/local/sbin/tunneling/auto-reboot-settings.sh
                exit 0
            fi
            
            HOUR=$(echo $time | cut -d: -f1)
            MINUTE=$(echo $time | cut -d: -f2)
            
            # Update cron job
            echo "# Auto Reboot Daily" > $CRON_FILE
            echo "$MINUTE $HOUR * * * root /sbin/reboot" >> $CRON_FILE
            
            # Restart cron
            systemctl restart cron
            
            echo -e "${GREEN}✓ Reboot time changed to $time${NC}"
        fi
        ;;
    0)
        /usr/local/sbin/tunneling/system-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        /usr/local/sbin/tunneling/auto-reboot-settings.sh
        exit 0
        ;;
esac

echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/system-menu.sh
