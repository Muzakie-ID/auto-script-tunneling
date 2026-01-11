#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}            RCLONE CLOUD BACKUP SETUP                ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
    echo -e "${YELLOW}Installing rclone...${NC}"
    curl https://rclone.org/install.sh | bash
    
    if ! command -v rclone &> /dev/null; then
        echo -e "${RED}Failed to install rclone!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Rclone installed successfully!${NC}"
    echo ""
fi

echo -e "${GREEN}Rclone is installed!${NC}"
echo -e "${CYAN}Version: $(rclone version | head -1)${NC}"
echo ""

# Check if rclone is already configured
if [ -f ~/.config/rclone/rclone.conf ] && [ -s ~/.config/rclone/rclone.conf ]; then
    echo -e "${YELLOW}Rclone configuration already exists!${NC}"
    echo ""
    echo -e "${GREEN}Available remotes:${NC}"
    rclone listremotes
    echo ""
    
    read -p "Do you want to add a new remote? (y/n): " add_new
    if [[ "$add_new" != "y" && "$add_new" != "Y" ]]; then
        echo ""
        echo -e "${GREEN}Setup completed!${NC}"
        read -p "Press [Enter] to continue..."
        /usr/local/sbin/tunneling/menu/backup-menu.sh
        exit 0
    fi
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      Select Cloud Storage Provider:                 ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}[1]${NC} Google Drive (Unlimited Storage)"
echo -e "${GREEN}[2]${NC} Dropbox"
echo -e "${GREEN}[3]${NC} OneDrive"
echo -e "${GREEN}[4]${NC} Amazon S3"
echo -e "${GREEN}[5]${NC} MEGA (50GB Free)"
echo -e "${GREEN}[6]${NC} pCloud"
echo -e "${GREEN}[7]${NC} FTP/SFTP Server"
echo -e "${GREEN}[8]${NC} Custom (Manual Configuration)"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}[0]${NC} Cancel"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Select provider [0-8]: " provider

case $provider in
    1)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}         Google Drive Configuration                  ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}Instructions:${NC}"
        echo "1. You will be prompted to authorize rclone with Google"
        echo "2. Follow the URL and enter the verification code"
        echo "3. Name your remote: ${GREEN}gdrive${NC} (recommended)"
        echo ""
        read -p "Press [Enter] to continue..."
        
        rclone config create gdrive drive scope drive
        ;;
    2)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}            Dropbox Configuration                   ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        rclone config create dropbox dropbox
        ;;
    3)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}            OneDrive Configuration                  ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        rclone config create onedrive onedrive
        ;;
    4)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}          Amazon S3 Configuration                   ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}You need:${NC}"
        echo "- AWS Access Key ID"
        echo "- AWS Secret Access Key"
        echo "- Bucket name"
        echo ""
        read -p "Press [Enter] to continue..."
        
        rclone config
        ;;
    5)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}             MEGA Configuration                     ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}You need:${NC}"
        echo "- MEGA email"
        echo "- MEGA password"
        echo ""
        read -p "Enter MEGA email: " mega_email
        read -sp "Enter MEGA password: " mega_pass
        echo ""
        
        rclone config create mega mega user "$mega_email" pass "$mega_pass"
        ;;
    6)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}            pCloud Configuration                    ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        rclone config
        ;;
    7)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}          FTP/SFTP Configuration                    ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${GREEN}[1]${NC} FTP"
        echo -e "${GREEN}[2]${NC} SFTP"
        echo ""
        read -p "Select type: " ftp_type
        
        if [[ "$ftp_type" == "1" ]]; then
            rclone config
        else
            rclone config
        fi
        ;;
    8)
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}         Manual Configuration                       ${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        rclone config
        ;;
    0)
        /usr/local/sbin/tunneling/menu/backup-menu.sh
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option!${NC}"
        sleep 1
        bash $0
        exit 0
        ;;
esac

# Verify configuration
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         Configuration Completed!                      ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Available remotes:${NC}"
rclone listremotes
echo ""

# Save default remote name
REMOTE_NAME=$(rclone listremotes | head -1 | tr -d ':')
echo "$REMOTE_NAME" > /etc/tunneling/rclone-remote.txt

echo -e "${GREEN}Default remote set to: ${CYAN}$REMOTE_NAME${NC}"
echo ""
echo -e "${YELLOW}Test connection...${NC}"
if rclone lsd "$REMOTE_NAME:/" &>/dev/null; then
    echo -e "${GREEN}✓ Connection successful!${NC}"
else
    echo -e "${RED}✗ Connection failed! Please check your configuration.${NC}"
fi
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Run 'Backup Online' to upload backups"
echo "2. Run 'Restore Online' to download backups"
echo "3. Configure Auto Backup to automate backups"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to return to menu..."
/usr/local/sbin/tunneling/menu/backup-menu.sh
