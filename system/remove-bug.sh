#!/bin/bash

# Remove Bug Host from List and Nginx Config
# Usage: ./remove-bug.sh <bug-host>
# Example: ./remove-bug.sh support.zoom.us

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get bug host from argument
BUG_HOST=$1

# Get domain from config
DOMAIN=$(cat /root/domain.txt 2>/dev/null)

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[ERROR]${NC} Domain not found in /root/domain.txt"
    exit 1
fi

# Validate input
if [ -z "$BUG_HOST" ]; then
    echo -e "${RED}[ERROR]${NC} Usage: $0 <bug-host>"
    echo ""
    echo "Example:"
    echo "  $0 support.zoom.us"
    echo "  $0 ava.game.naver.com"
    echo ""
    echo "Current bug hosts:"
    if [ -f /etc/tunneling/bug-hosts.txt ]; then
        cat /etc/tunneling/bug-hosts.txt | nl
    else
        echo "  (none)"
    fi
    exit 1
fi

# Build full domain
FULL_DOMAIN="${BUG_HOST}.${DOMAIN}"
BUG_LIST="/etc/tunneling/bug-hosts.txt"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}      Remove Bug Host from Configuration       ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Bug Host:${NC}     ${BUG_HOST}"
echo -e "${YELLOW}Full Domain:${NC}  ${FULL_DOMAIN}"
echo ""

# Check if exists in list
if [ ! -f "$BUG_LIST" ]; then
    echo -e "${RED}[ERROR]${NC} Bug hosts list not found!"
    exit 1
fi

if ! grep -qx "${BUG_HOST}" "$BUG_LIST" 2>/dev/null; then
    echo -e "${RED}[ERROR]${NC} ${BUG_HOST} not found in bug hosts list!"
    echo ""
    echo "Current bug hosts:"
    cat "$BUG_LIST" | nl
    exit 1
fi

# Confirm removal
echo -e "${YELLOW}[WARNING]${NC} This will:"
echo "  1. Remove ${BUG_HOST} from bug hosts list"
echo "  2. Regenerate Nginx configuration"
echo "  3. Reload Nginx/OpenResty"
echo ""
echo -e "${CYAN}Note:${NC} SSL certificate will NOT be modified (domains remain in cert)"
echo ""
read -p "Continue? [y/N]: " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[CANCELLED]${NC} Operation cancelled"
    exit 0
fi

# Remove from list
echo -e "${CYAN}[INFO]${NC} Removing ${BUG_HOST} from bug hosts list..."
sed -i "/^${BUG_HOST}$/d" "$BUG_LIST"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓]${NC} Removed from $BUG_LIST"
    
    # Regenerate Nginx configuration
    echo -e "${CYAN}[INFO]${NC} Regenerating Nginx configuration..."
    bash /usr/local/sbin/tunneling/system/setup-nginx.sh
    
    # Reload Nginx/OpenResty
    if systemctl is-active openresty >/dev/null 2>&1; then
        echo -e "${CYAN}[INFO]${NC} Reloading OpenResty..."
        systemctl reload openresty
    elif systemctl is-active nginx >/dev/null 2>&1; then
        echo -e "${CYAN}[INFO]${NC} Reloading Nginx..."
        systemctl reload nginx
    fi
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}              SUCCESS!                          ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}[✓]${NC} Bug host removed: ${BUG_HOST}"
    echo -e "${CYAN}[✓]${NC} Nginx configuration updated"
    echo ""
    echo "Remaining bug hosts:"
    if [ -s "$BUG_LIST" ]; then
        cat "$BUG_LIST" | nl
    else
        echo "  (none)"
    fi
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    exit 0
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Failed to remove bug host!"
    exit 1
fi
