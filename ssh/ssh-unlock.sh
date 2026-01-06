#!/bin/bash
# Unlock SSH Account

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         UNLOCK SSH ACCOUNT             ${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to unlock: " username

if ! id "$username" &>/dev/null; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

# Unlock account
passwd -u $username

echo ""
echo -e "${GREEN}✓ Account $username has been unlocked${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
