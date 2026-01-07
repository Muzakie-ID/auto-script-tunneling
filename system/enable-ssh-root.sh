#!/bin/bash

# Enable SSH Root Login with Password

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          ENABLE SSH ROOT LOGIN                     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Get server IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null)
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(wget -qO- ifconfig.me 2>/dev/null)
fi
if [ -z "$SERVER_IP" ]; then
    SERVER_IP=$(ip addr | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n1)
fi

echo -e "${YELLOW}Current Server IP:${NC} $SERVER_IP"
echo ""

# Check if root login is already enabled
if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Root login already enabled"
    echo ""
else
    echo -e "${CYAN}[1/3]${NC} Enabling root login..."
    
    # Backup SSH config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d)
    
    # Enable root login
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    
    # Add if not exists
    if ! grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
        echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    fi
    if ! grep -q "^PasswordAuthentication" /etc/ssh/sshd_config; then
        echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
    fi
    
    echo -e "${GREEN}✓${NC} Root login enabled"
fi

# Set root password
echo ""
echo -e "${CYAN}[2/3]${NC} Setting root password..."
echo -e "${YELLOW}Please enter a strong password for root user${NC}"
echo ""

# Prompt for password
while true; do
    read -sp "Enter new root password: " password1
    echo ""
    read -sp "Confirm root password: " password2
    echo ""
    
    if [ "$password1" != "$password2" ]; then
        echo -e "${RED}✗ Passwords do not match! Please try again.${NC}"
        echo ""
    elif [ ${#password1} -lt 6 ]; then
        echo -e "${RED}✗ Password too short! Minimum 6 characters.${NC}"
        echo ""
    else
        break
    fi
done

# Set the password
echo "root:$password1" | chpasswd

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Root password set successfully"
else
    echo -e "${RED}✗${NC} Failed to set password"
    exit 1
fi

# Restart SSH service
echo ""
echo -e "${CYAN}[3/3]${NC} Restarting SSH service..."
systemctl restart sshd || systemctl restart ssh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} SSH service restarted"
else
    echo -e "${YELLOW}!${NC} Please restart SSH manually: systemctl restart sshd"
fi

# Display login information
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}          SSH ROOT LOGIN ENABLED!                   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}SSH LOGIN INFORMATION:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${GREEN}IP Address  :${NC} $SERVER_IP"
echo -e "  ${GREEN}Username    :${NC} root"
echo -e "  ${GREEN}Password    :${NC} $password1"
echo -e "  ${GREEN}Port        :${NC} 22"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}How to connect:${NC}"
echo -e "  ssh root@$SERVER_IP"
echo ""
echo -e "${YELLOW}Additional SSH Ports (if configured):${NC}"
echo -e "  • Dropbear: 109, 143"
echo -e "  • Stunnel: 442, 443"
echo ""
echo -e "${RED}⚠ IMPORTANT SECURITY NOTES:${NC}"
echo -e "  • Save this password in a secure location"
echo -e "  • Consider using SSH keys for better security"
echo -e "  • Change password regularly"
echo -e "  • Enable fail2ban for brute-force protection"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Save to file (optional)
read -p "Save login info to file? (y/n): " save_choice
if [[ $save_choice =~ ^[Yy]$ ]]; then
    INFO_FILE="/root/ssh-login-info.txt"
    cat > $INFO_FILE << EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          SSH ROOT LOGIN INFORMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IP Address  : $SERVER_IP
Username    : root
Password    : $password1
Port        : 22

Connection Command:
ssh root@$SERVER_IP

Additional Ports:
• Dropbear: 109, 143
• Stunnel: 442, 443

Generated: $(date)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠ KEEP THIS FILE SECURE - DELETE AFTER SAVING PASSWORD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    chmod 600 $INFO_FILE
    echo -e "${GREEN}✓${NC} Login info saved to: $INFO_FILE"
    echo -e "${YELLOW}  Remember to delete this file after saving the password!${NC}"
    echo ""
fi

read -p "Press [Enter] to continue..."
