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

# Show existing accounts
echo -e "${YELLOW}Existing SSH Accounts:${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -d /etc/tunneling/ssh ] && [ "$(ls -A /etc/tunneling/ssh/*.json 2>/dev/null)" ]; then
    for user_json in /etc/tunneling/ssh/*.json; do
        username_list=$(jq -r '.username' $user_json 2>/dev/null)
        echo -e "  • $username_list"
    done
else
    echo -e "${RED}  No accounts found${NC}"
fi
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
