#!/bin/bash
# SSH Account Deletion

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}        DELETE SSH ACCOUNT               ${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Username to delete: " username

if ! id "$username" &>/dev/null; then
    echo -e "${RED}User $username tidak ditemukan!${NC}"
    exit 1
fi

read -p "Are you sure? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "Cancelled."
    exit 0
fi

# Kill user sessions
killall -u $username 2>/dev/null

# Delete user
userdel -r $username 2>/dev/null

# Delete JSON
rm -f /etc/tunneling/ssh/${username}.json

echo ""
echo -e "${GREEN}✓ Account deleted successfully!${NC}"
echo ""
read -n 1 -s -r -p "Press any key to continue..."
