#!/bin/bash
# Lock SSH Account

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}           LOCK SSH ACCOUNT              ${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to lock: " username

if ! id "$username" &>/dev/null; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

# Lock account
passwd -l $username

# Kill active sessions
killall -u $username 2>/dev/null

echo ""
echo -e "${GREEN}✓ Account $username has been locked${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
