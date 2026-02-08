#!/bin/bash

# Auto Add Bug Host to SSL Certificate
# Usage: ./auto-add-bug.sh <bug-host>
# Example: ./auto-add-bug.sh support.zoom.us

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
    exit 1
fi

# Build full domain
FULL_DOMAIN="${BUG_HOST}.${DOMAIN}"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}          Add Bug Host to Certificate          ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Bug Host:${NC}     ${BUG_HOST}"
echo -e "${YELLOW}Full Domain:${NC}  ${FULL_DOMAIN}"
echo ""

# Create bug hosts directory if not exists
mkdir -p /etc/tunneling

# Check if already in certificate
if openssl x509 -in /etc/letsencrypt/live/${DOMAIN}/fullchain.pem -text 2>/dev/null | grep -q "DNS:${FULL_DOMAIN}"; then
    echo -e "${GREEN}[✓]${NC} ${FULL_DOMAIN} already in certificate!"
    
    # Still add to list if not present
    BUG_LIST="/etc/tunneling/bug-hosts.txt"
    if ! grep -qx "${BUG_HOST}" "$BUG_LIST" 2>/dev/null; then
        echo "${BUG_HOST}" >> "$BUG_LIST"
        echo -e "${GREEN}[✓]${NC} Added to bug hosts list"
        
        # Regenerate nginx config
        echo -e "${CYAN}[INFO]${NC} Regenerating Nginx configuration..."
        bash /usr/local/sbin/tunneling/system/setup-nginx.sh
    fi
    
    exit 0
fi

echo -e "${CYAN}[INFO]${NC} Adding ${FULL_DOMAIN} to certificate..."

# Check if Cloudflare credentials exist
if [ ! -f /root/.secrets/cloudflare.ini ]; then
    echo -e "${RED}[ERROR]${NC} Cloudflare credentials not found!"
    echo "Please setup /root/.secrets/cloudflare.ini first"
    exit 1
fi

# Get existing domains from certificate
CERT_DOMAINS=$(certbot certificates --cert-name ${DOMAIN} 2>/dev/null | grep "Domains:" | sed 's/.*Domains: //' | tr ' ' '\n')

if [ -z "$CERT_DOMAINS" ]; then
    echo -e "${RED}[ERROR]${NC} Certificate ${DOMAIN} not found!"
    exit 1
fi

# Build certbot command
CMD="certbot certonly --dns-cloudflare \
  --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
  --expand \
  --cert-name ${DOMAIN} \
  --non-interactive \
  --agree-tos"

# Add all existing domains
for dom in ${CERT_DOMAINS}; do
    CMD="${CMD} -d ${dom}"
done

# Add new domain
CMD="${CMD} -d ${FULL_DOMAIN}"

# Execute certbot
echo ""
echo -e "${CYAN}[INFO]${NC} Requesting SSL certificate..."
eval ${CMD}

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}[✓]${NC} SSL certificate updated successfully!"
    
    # Save bug host to list
    BUG_LIST="/etc/tunneling/bug-hosts.txt"
    if ! grep -qx "${BUG_HOST}" "$BUG_LIST" 2>/dev/null; then
        echo "${BUG_HOST}" >> "$BUG_LIST"
        echo -e "${GREEN}[✓]${NC} Saved to bug hosts list: $BUG_LIST"
    fi
    
    # Regenerate Nginx configuration with bug hosts server block
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
    echo -e "${YELLOW}Bug Host:${NC}  ${FULL_DOMAIN}"
    echo ""
    echo -e "${CYAN}Config Templates (Choose Protocol):${NC}"
    echo ""
    
    # Template 1: TROJAN
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}1. TROJAN${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    cat << EOF
- name: ${BUG_HOST}-trojan
  server: ${FULL_DOMAIN}
  port: 443
  type: trojan
  password: [user-password]
  skip-cert-verify: false
  sni: ${FULL_DOMAIN}
  network: ws
  ws-opts:
    path: /trojan
    headers:
      Host: ${FULL_DOMAIN}
  udp: true
EOF
    
    echo ""
    
    # Template 2: VMESS
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}2. VMESS${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    cat << EOF
- name: ${BUG_HOST}-vmess
  server: ${FULL_DOMAIN}
  port: 443
  type: vmess
  uuid: [user-uuid]
  alterId: 0
  cipher: auto
  tls: true
  skip-cert-verify: false
  servername: ${FULL_DOMAIN}
  network: ws
  ws-opts:
    path: /vmess
    headers:
      Host: ${FULL_DOMAIN}
  udp: true
EOF
    
    echo ""
    
    # Template 3: VLESS
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}3. VLESS${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════${NC}"
    cat << EOF
- name: ${BUG_HOST}-vless
  server: ${FULL_DOMAIN}
  port: 443
  type: vless
  uuid: [user-uuid]
  tls: true
  skip-cert-verify: false
  servername: ${FULL_DOMAIN}
  network: ws
  ws-path: /vless
  ws-headers:
    Host: ${FULL_DOMAIN}
  udp: true
EOF
    
    echo ""
    echo -e "${CYAN}💡 Tip:${NC} Replace ${YELLOW}[user-password]${NC} atau ${YELLOW}[user-uuid]${NC} dengan data user yang sudah dibuat"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    exit 0
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Failed to update SSL certificate!"
    echo ""
    echo "Please check:"
    echo "  1. Cloudflare credentials are correct"
    echo "  2. DNS record for ${FULL_DOMAIN} exists"
    echo "  3. Certbot has internet access"
    exit 1
fi
