#!/bin/bash

# Fix Cloudflare DNS - Auto create missing A and wildcard CNAME records
# Usage: bash fix-cloudflare-dns.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    Fix Cloudflare DNS Records               ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check cloudflare credentials
if [ ! -f /root/.secrets/cloudflare.ini ]; then
    echo -e "${RED}[ERROR]${NC} Cloudflare credentials not found!"
    echo "File: /root/.secrets/cloudflare.ini"
    echo ""
    echo "Please run setup-cloudflare-interactive.sh first"
    exit 1
fi

# Get domain
DOMAIN=$(cat /root/domain.txt 2>/dev/null)
if [ -z "$DOMAIN" ]; then
    read -p "Enter your domain: " DOMAIN
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}[ERROR]${NC} Domain cannot be empty"
        exit 1
    fi
    echo "$DOMAIN" > /root/domain.txt
fi

echo -e "${YELLOW}Domain:${NC} $DOMAIN"
echo ""

# Extract credentials
CF_EMAIL=$(grep "dns_cloudflare_email" /root/.secrets/cloudflare.ini 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
CF_API_KEY=$(grep "dns_cloudflare_api_key" /root/.secrets/cloudflare.ini 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
CF_TOKEN=$(grep "dns_cloudflare_api_token" /root/.secrets/cloudflare.ini 2>/dev/null | cut -d'=' -f2 | tr -d ' ')

# Determine auth method
if [ -n "$CF_TOKEN" ]; then
    echo -e "${YELLOW}[WARNING]${NC} You are using API Token method"
    echo ""
    echo "This script requires Global API Key to create DNS records via API."
    echo ""
    echo "Please create DNS records manually in Cloudflare dashboard:"
    echo ""
    echo "  1. Login to https://dash.cloudflare.com/"
    echo "  2. Select your domain: $DOMAIN"
    echo "  3. Go to DNS > Records"
    echo "  4. Click 'Add record' and create these records:"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Get VPS IP
    VPS_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null)
    
    echo -e "${GREEN}Record 1:${NC}"
    echo "  Type:    A"
    echo "  Name:    @ (or $DOMAIN)"
    echo "  Content: $VPS_IP"
    echo "  Proxy:   DNS only (grey cloud)"
    echo ""
    echo -e "${GREEN}Record 2:${NC}"
    echo "  Type:    CNAME"
    echo "  Name:    * (asterisk)"
    echo "  Content: $DOMAIN"
    echo "  Proxy:   DNS only (grey cloud)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}After creating these records, bug hosts will work!${NC}"
    echo ""
    exit 0
fi

if [ -z "$CF_EMAIL" ] || [ -z "$CF_API_KEY" ]; then
    echo -e "${RED}[ERROR]${NC} Cannot find Cloudflare credentials"
    exit 1
fi

echo -e "${GREEN}✓${NC} Using Global API Key method"
echo ""

# Get VPS IP
echo -e "${CYAN}[INFO]${NC} Detecting VPS IP..."
VPS_IP=$(curl -s ifconfig.me 2>/dev/null)
if [ -z "$VPS_IP" ]; then
    VPS_IP=$(curl -s icanhazip.com 2>/dev/null)
fi

if [ -z "$VPS_IP" ]; then
    echo -e "${RED}[ERROR]${NC} Cannot detect VPS IP"
    exit 1
fi

echo -e "${GREEN}✓${NC} VPS IP: $VPS_IP"
echo ""

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

echo -e "${CYAN}[INFO]${NC} Root domain: $ROOT_DOMAIN"

# Get Zone ID
echo -e "${CYAN}[INFO]${NC} Getting Cloudflare Zone ID..."
ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ROOT_DOMAIN" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    -H "Content-Type: application/json")

ZONE_ID=$(echo $ZONE_RESPONSE | grep -Po '"id":"\K[^"]*' | head -1)

if [ -z "$ZONE_ID" ]; then
    echo -e "${RED}[ERROR]${NC} Cannot get Zone ID!"
    echo "Please verify:"
    echo "  - Email: $CF_EMAIL"
    echo "  - API Key is correct"
    echo "  - Domain $ROOT_DOMAIN in Cloudflare"
    exit 1
fi

echo -e "${GREEN}✓${NC} Zone ID: $ZONE_ID"
echo ""

# Function to create/update A record
create_a_record() {
    local record_name=$1
    local ip=$2
    
    echo -e "${CYAN}[INFO]${NC} Setting up A record: $record_name → $ip"
    
    # Check if exists
    CHECK_RESPONSE=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$record_name" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json")
    
    RECORD_ID=$(echo $CHECK_RESPONSE | grep -Po '"id":"\K[^"]*' | head -1)
    
    if [ -n "$RECORD_ID" ]; then
        # Update existing
        RESPONSE=$(curl -s -X PUT \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
        
        if echo "$RESPONSE" | grep -q '"success":true'; then
            echo -e "${GREEN}✓${NC} A record updated"
        else
            echo -e "${RED}✗${NC} Failed to update A record"
            echo -e "${YELLOW}Response:${NC}"
            echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
            return 1
        fi
    else
        # Create new
        RESPONSE=$(curl -s -X POST \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$record_name\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
        
        if echo "$RESPONSE" | grep -q '"success":true'; then
            echo -e "${GREEN}✓${NC} A record created"
        else
            echo -e "${RED}✗${NC} Failed to create A record"
            echo -e "${YELLOW}Response:${NC}"
            echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
            return 1
        fi
    fi
}

# Function to create CNAME wildcard
create_cname_wildcard() {
    local record_name=$1
    local target=$2
    
    echo -e "${CYAN}[INFO]${NC} Setting up CNAME wildcard: $record_name → $target"
    
    # Check if exists
    CHECK_RESPONSE=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=CNAME&name=$record_name" \
        -H "X-Auth-Email: $CF_EMAIL" \
        -H "X-Auth-Key: $CF_API_KEY" \
        -H "Content-Type: application/json")
    
    RECORD_ID=$(echo $CHECK_RESPONSE | grep -Po '"id":"\K[^"]*' | head -1)
    
    if [ -n "$RECORD_ID" ]; then
        # Update existing
        RESPONSE=$(curl -s -X PUT \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"CNAME\",\"name\":\"$record_name\",\"content\":\"$target\",\"ttl\":1,\"proxied\":false}")
        
        if echo "$RESPONSE" | grep -q '"success":true'; then
            echo -e "${GREEN}✓${NC} CNAME wildcard updated"
        else
            echo -e "${RED}✗${NC} Failed to update CNAME"
            echo -e "${YELLOW}Response:${NC}"
            echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
            return 1
        fi
    else
        # Create new
        RESPONSE=$(curl -s -X POST \
            "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
            -H "X-Auth-Email: $CF_EMAIL" \
            -H "X-Auth-Key: $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"CNAME\",\"name\":\"$record_name\",\"content\":\"$target\",\"ttl\":1,\"proxied\":false}")
        
        if echo "$RESPONSE" | grep -q '"success":true'; then
            echo -e "${GREEN}✓${NC} CNAME wildcard created"
        else
            echo -e "${RED}✗${NC} Failed to create CNAME"
            echo -e "${YELLOW}Response:${NC}"
            echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
            return 1
        fi
    fi
}

# Create records
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Creating DNS Records...${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

create_a_record "$DOMAIN" "$VPS_IP"
echo ""
create_cname_wildcard "*.$DOMAIN" "$DOMAIN"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    DNS Setup Complete!                     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}DNS Records:${NC}"
echo "  A:     $DOMAIN → $VPS_IP"
echo "  CNAME: *.$DOMAIN → $DOMAIN"
echo ""
echo -e "${YELLOW}Wait 1-5 minutes for DNS propagation${NC}"
echo ""
echo "Test your bug host:"
echo "  ping support.zoom.us.$DOMAIN"
echo "  nslookup support.zoom.us.$DOMAIN"
echo ""
