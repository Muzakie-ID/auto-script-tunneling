#!/bin/bash

# Check Cloudflare DNS Records
# This script verifies wildcard and A records exist in Cloudflare

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if cloudflare credentials exist
if [ ! -f /root/.secrets/cloudflare.ini ]; then
    echo -e "${RED}[ERROR]${NC} Cloudflare credentials not found!"
    echo "File /root/.secrets/cloudflare.ini does not exist"
    exit 1
fi

# Get domain
DOMAIN=$(cat /root/domain.txt 2>/dev/null)
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[ERROR]${NC} Domain not found in /root/domain.txt"
    exit 1
fi

# Extract credentials from cloudflare.ini
CF_EMAIL=$(grep "dns_cloudflare_email" /root/.secrets/cloudflare.ini | cut -d'=' -f2 | tr -d ' ')
CF_API_KEY=$(grep "dns_cloudflare_api_key" /root/.secrets/cloudflare.ini | cut -d'=' -f2 | tr -d ' ')

if [ -z "$CF_EMAIL" ] || [ -z "$CF_API_KEY" ]; then
    echo -e "${YELLOW}[INFO]${NC} Using API Token method (email/api_key not found)"
    echo -e "${YELLOW}[WARNING]${NC} This script only works with Global API Key method"
    echo ""
    echo "For API Token users, please check manually at:"
    echo "https://dash.cloudflare.com/"
    exit 0
fi

# Smart root domain extraction
if [[ $DOMAIN =~ \. ]]; then
    PART_COUNT=$(echo "$DOMAIN" | awk -F. '{print NF}')
    
    if [ "$PART_COUNT" -ge 4 ]; then
        ROOT_DOMAIN=$(echo $DOMAIN | awk -F. '{print $(NF-2)"."$(NF-1)"."$NF}')
    elif [ "$PART_COUNT" -eq 3 ]; then
        LAST_PART=$(echo $DOMAIN | awk -F. '{print $NF}')
        if [ "${#LAST_PART}" -eq 2 ]; then
            ROOT_DOMAIN=$DOMAIN
        else
            ROOT_DOMAIN=$(echo $DOMAIN | awk -F. '{print $(NF-1)"."$NF}')
        fi
    else
        ROOT_DOMAIN=$DOMAIN
    fi
else
    ROOT_DOMAIN=$DOMAIN
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    Cloudflare DNS Records Check            ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Domain:${NC}      $DOMAIN"
echo -e "${YELLOW}Root Domain:${NC} $ROOT_DOMAIN"
echo ""

# Get Zone ID
echo -e "${CYAN}[INFO]${NC} Fetching Zone ID..."
ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ROOT_DOMAIN" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

ZONE_ID=$(echo $ZONE_RESPONSE | grep -Po '"id":"\K[^"]*' | head -1)

if [ -z "$ZONE_ID" ]; then
    echo -e "${RED}[ERROR]${NC} Cannot get Zone ID!"
    echo "Please verify:"
    echo "  - Email and API Key in /root/.secrets/cloudflare.ini"
    echo "  - Domain $ROOT_DOMAIN exists in Cloudflare"
    exit 1
fi

echo -e "${GREEN}✓${NC} Zone ID: $ZONE_ID"
echo ""

# Check A record
echo -e "${CYAN}[INFO]${NC} Checking A record for: $DOMAIN"
A_RESPONSE=$(curl -s -X GET \
    "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

A_IP=$(echo $A_RESPONSE | grep -Po '"content":"\K[^"]*' | head -1)

if [ -n "$A_IP" ]; then
    echo -e "${GREEN}✓${NC} A Record: $DOMAIN → $A_IP"
else
    echo -e "${RED}✗${NC} A Record NOT FOUND for $DOMAIN"
fi

echo ""

# Check CNAME wildcard
echo -e "${CYAN}[INFO]${NC} Checking CNAME wildcard: *.$DOMAIN"
CNAME_RESPONSE=$(curl -s -X GET \
    "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=CNAME&name=*.$DOMAIN" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

CNAME_TARGET=$(echo $CNAME_RESPONSE | grep -Po '"content":"\K[^"]*' | head -1)

if [ -n "$CNAME_TARGET" ]; then
    echo -e "${GREEN}✓${NC} CNAME Wildcard: *.$DOMAIN → $CNAME_TARGET"
else
    echo -e "${RED}✗${NC} CNAME Wildcard NOT FOUND"
    echo ""
    echo -e "${YELLOW}[WARNING]${NC} Wildcard DNS not configured!"
    echo "Bug hosts will NOT work without wildcard DNS."
    echo ""
    echo "To fix this, run:"
    echo "  /usr/local/sbin/tunneling/system/auto-setup-cloudflare-dns.sh $DOMAIN $CF_EMAIL <API_KEY>"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get VPS IP
VPS_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null)

if [ -n "$VPS_IP" ] && [ -n "$A_IP" ]; then
    echo ""
    echo -e "${YELLOW}VPS IP:${NC}      $VPS_IP"
    echo -e "${YELLOW}DNS IP:${NC}      $A_IP"
    
    if [ "$VPS_IP" == "$A_IP" ]; then
        echo -e "${GREEN}✓${NC} IPs match!"
    else
        echo -e "${RED}✗${NC} IP mismatch! Update DNS A record."
    fi
fi

echo ""
