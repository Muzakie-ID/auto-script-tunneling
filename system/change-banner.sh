#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              CHANGE SSH BANNER                    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show current banner
if [ -f "/etc/issue.net" ]; then
    echo -e "${YELLOW}Current Banner:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    cat /etc/issue.net
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo ""
echo -e "${YELLOW}Enter New Banner (multiline, type 'END' on new line to finish):${NC}"
echo ""

# Read multiline input
banner_text=""
while IFS= read -r line; do
    if [[ "$line" == "END" ]]; then
        break
    fi
    banner_text+="$line"$'\n'
done

if [[ -z $banner_text ]]; then
    echo -e "${RED}Banner cannot be empty!${NC}"
    sleep 2
    /usr/local/sbin/tunneling/menu/settings-menu.sh
    exit 1
fi

# Save banner
echo -e "$banner_text" > /etc/issue.net

# Configure SSH to use banner
sed -i '/Banner/d' /etc/ssh/sshd_config
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

# Restart SSH
systemctl restart sshd

echo ""
echo -e "${GREEN}✓ SSH Banner changed successfully!${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/menu/settings-menu.sh
