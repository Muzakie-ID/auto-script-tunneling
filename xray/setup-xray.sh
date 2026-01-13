#!/bin/bash

# XRAY Configuration Generator
# This script creates XRAY config with VMESS, VLESS, and TROJAN

DOMAIN=$(cat /root/domain.txt)
UUID=$(cat /proc/sys/kernel/random/uuid)

# Create XRAY config
cat > /usr/local/etc/xray/config.json << EOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10001,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "port": 10002,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "port": 10003,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojan"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      },
      {
        "type": "field",
        "protocol": ["bittorrent"],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF

# Check if SSL certificate exists
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "SSL certificate found."
    HAS_SSL=true
else
    echo "SSL certificate not found."
    HAS_SSL=false
fi

# Nginx config for XRAY is now handled by system/setup-nginx.sh
# We no longer create /etc/nginx/conf.d/xray.conf to avoid conflicts

# Create webroot directory for certbot
mkdir -p /var/www/html

# Create log directory
mkdir -p /var/log/xray

# Create directories for user data
mkdir -p /etc/tunneling/vmess
mkdir -p /etc/tunneling/vless
mkdir -p /etc/tunneling/trojan

# Restart services
systemctl restart xray
systemctl restart nginx

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "XRAY configuration created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Domain: $DOMAIN"
echo ""

if [ "$HAS_SSL" = false ]; then
    echo "⚠️  SSL Certificate not found!"
    echo ""
    echo "To get SSL certificate, run:"
    echo "  certbot certonly --nginx -d $DOMAIN"
    echo ""
    echo "After getting certificate, run setup again to enable HTTPS."
    echo ""
fi

echo "Services:"
if [ "$HAS_SSL" = true ]; then
    echo "  • VMESS   → https://$DOMAIN:443/vmess"
    echo "  • VLESS   → https://$DOMAIN:443/vless"
    echo "  • TROJAN  → https://$DOMAIN:443/trojan"
else
    echo "  • VMESS   → http://$DOMAIN:80/vmess"
    echo "  • VLESS   → http://$DOMAIN:80/vless"
    echo "  • TROJAN  → http://$DOMAIN:80/trojan"
fi
echo ""
echo "Internal Ports:"
echo "  • VMESS   → 127.0.0.1:10001"
echo "  • VLESS   → 127.0.0.1:10002"
echo "  • TROJAN  → 127.0.0.1:10003"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Note: Create user accounts using the menu to start using the services."
