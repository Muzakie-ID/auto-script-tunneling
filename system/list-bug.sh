#!/bin/bash

# List All Registered Bug Hosts
# Usage: ./list-bug.sh

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get domain from config
DOMAIN=$(cat /root/domain.txt 2>/dev/null)

if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[ERROR]${NC} Domain not found in /root/domain.txt"
    exit 1
fi

BUG_LIST="/etc/tunneling/bug-hosts.txt"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}          Registered Bug Hosts List            ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if list exists
if [ ! -f "$BUG_LIST" ]; then
    echo -e "${YELLOW}[INFO]${NC} No bug hosts registered yet"
    echo ""
    echo "To add a bug host, run:"
    echo "  bash /usr/local/sbin/tunneling/system/auto-add-bug.sh <bug-host>"
    echo ""
    echo "Example:"
    echo "  bash /usr/local/sbin/tunneling/system/auto-add-bug.sh support.zoom.us"
    echo ""
    exit 0
fi

# Count total bug hosts
TOTAL=$(grep -c "^" "$BUG_LIST" 2>/dev/null || echo "0")

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${YELLOW}[INFO]${NC} Bug hosts list is empty"
    echo ""
    exit 0
fi

echo -e "${GREEN}Total Bug Hosts:${NC} ${TOTAL}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Display list with details
INDEX=1
while IFS= read -r bug || [ -n "$bug" ]; do
    # Skip empty lines and comments
    [[ -z "$bug" || "$bug" =~ ^#.* ]] && continue
    
    FULL_DOMAIN="${bug}.${DOMAIN}"
    
    # Check if in SSL certificate
    IN_CERT="❌"
    if openssl x509 -in /etc/letsencrypt/live/${DOMAIN}/fullchain.pem -text 2>/dev/null | grep -q "DNS:${FULL_DOMAIN}"; then
        IN_CERT="${GREEN}✓${NC}"
    fi
    
    # Check if DNS resolves
    DNS_STATUS="❌"
    DNS_IP=$(dig +short ${FULL_DOMAIN} 2>/dev/null | head -n1)
    if [ -n "$DNS_IP" ]; then
        DNS_STATUS="${GREEN}✓${NC} (${DNS_IP})"
    fi
    
    # Check if accessible via HTTPS
    HTTPS_STATUS="❌"
    if curl -s -k -o /dev/null -w "%{http_code}" https://${FULL_DOMAIN} --connect-timeout 3 | grep -q "200\|301\|302"; then
        HTTPS_STATUS="${GREEN}✓${NC}"
    fi
    
    printf "${YELLOW}[%2d]${NC} ${BLUE}%-40s${NC}\n" "$INDEX" "$FULL_DOMAIN"
    printf "     ├─ Bug Host:     ${bug}\n"
    printf "     ├─ SSL Cert:     ${IN_CERT}\n"
    printf "     ├─ DNS Resolve:  ${DNS_STATUS}\n"
    printf "     └─ HTTPS Access: ${HTTPS_STATUS}\n"
    echo ""
    
    INDEX=$((INDEX + 1))
done < "$BUG_LIST"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}Commands:${NC}"
echo "  Add Bug Host:     bash /usr/local/sbin/tunneling/system/auto-add-bug.sh <bug-host>"
echo "  Remove Bug Host:  bash /usr/local/sbin/tunneling/system/remove-bug.sh <bug-host>"
echo "  Refresh List:     bash /usr/local/sbin/tunneling/system/list-bug.sh"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
