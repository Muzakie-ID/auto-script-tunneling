#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      RCLONE MANUAL CONFIGURATION (Headless)         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Since this is a headless server (no browser),${NC}"
echo -e "${YELLOW}you need to configure rclone on your LOCAL machine first.${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 1: On Your LOCAL Computer (Windows/Mac/Linux)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Install rclone:"
echo -e "   ${CYAN}Windows:${NC} winget install Rclone.Rclone"
echo -e "   ${CYAN}Mac:${NC} brew install rclone"
echo -e "   ${CYAN}Linux:${NC} curl https://rclone.org/install.sh | sudo bash"
echo ""
echo "2. Run rclone config:"
echo -e "   ${GREEN}rclone config${NC}"
echo ""
echo "3. Follow these steps:"
echo "   - Type: n (for new remote)"
echo "   - name: gdrive"
echo "   - Type: drive (for Google Drive)"
echo "   - client_id: (press Enter for default)"
echo "   - client_secret: (press Enter for default)"
echo "   - scope: 1 (Full access)"
echo "   - root_folder_id: (press Enter)"
echo "   - service_account_file: (press Enter)"
echo "   - Edit advanced config: n"
echo "   - Use auto config: y (browser will open)"
echo "   - Authorize in browser"
echo "   - Configure as shared drive: n"
echo "   - Keep remote: y"
echo ""
echo "4. Get the config:"
echo -e "   ${CYAN}Windows:${NC} type %USERPROFILE%\\.config\\rclone\\rclone.conf"
echo -e "   ${CYAN}Mac/Linux:${NC} cat ~/.config/rclone/rclone.conf"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}STEP 2: Copy Config to This Server${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Method A - Direct paste:"
echo "1. Copy the content of rclone.conf from your local machine"
echo "2. Ready to paste here"
echo ""
echo "Method B - SCP/SFTP:"
echo "   From local machine:"
echo -e "   ${GREEN}scp ~/.config/rclone/rclone.conf root@YOUR_VPS_IP:/root/.config/rclone/${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Do you have the config content ready? (y/n): " ready

if [[ "$ready" != "y" && "$ready" != "Y" ]]; then
    echo ""
    echo -e "${YELLOW}Please configure rclone on your local machine first.${NC}"
    echo -e "${YELLOW}Then run this script again.${NC}"
    echo ""
    read -p "Press [Enter] to exit..."
    exit 0
fi

# Create directory
mkdir -p /root/.config/rclone

echo ""
echo -e "${GREEN}Please paste your rclone.conf content below.${NC}"
echo -e "${YELLOW}(Paste, then press Ctrl+D on a new line to finish)${NC}"
echo ""
echo -e "${CYAN}Waiting for input...${NC}"
echo ""

# Read multi-line input
cat > /root/.config/rclone/rclone.conf

echo ""
echo -e "${GREEN}✓ Config file saved!${NC}"
echo ""

# Verify
if [ -s /root/.config/rclone/rclone.conf ]; then
    echo -e "${GREEN}Validating configuration...${NC}"
    echo ""
    
    # List remotes
    remotes=$(rclone listremotes 2>/dev/null)
    
    if [ -n "$remotes" ]; then
        echo -e "${GREEN}✓ Configuration successful!${NC}"
        echo ""
        echo -e "${CYAN}Available remotes:${NC}"
        echo "$remotes"
        echo ""
        
        # Test connection
        read -p "Test connection now? (y/n): " test_conn
        if [[ "$test_conn" == "y" || "$test_conn" == "Y" ]]; then
            echo ""
            echo -e "${YELLOW}Testing connection...${NC}"
            
            remote_name=$(echo "$remotes" | head -1 | tr -d ':')
            if rclone lsd "$remote_name:/" &>/dev/null; then
                echo -e "${GREEN}✓ Connection successful!${NC}"
                echo ""
                
                # Save as default
                echo "$remote_name" > /etc/tunneling/rclone-remote.txt
                echo -e "${GREEN}Default remote set to: ${CYAN}$remote_name${NC}"
            else
                echo -e "${RED}✗ Connection failed!${NC}"
                echo -e "${YELLOW}Please check your configuration.${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ No remotes found in configuration!${NC}"
        echo -e "${YELLOW}Please check the config content.${NC}"
    fi
else
    echo -e "${RED}✗ Config file is empty!${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Configuration path: /root/.config/rclone/rclone.conf${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to return to menu..."
/usr/local/sbin/tunneling/menu/backup-menu.sh
