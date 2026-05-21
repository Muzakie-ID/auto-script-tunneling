#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[INFO]${NC} Installing ZIVPN UDP server..."

ARCH=$(uname -m)
BIN_URL=""

case "$ARCH" in
    x86_64|amd64)
        BIN_URL="https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64"
        ;;
    aarch64|arm64)
        BIN_URL="https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-arm64"
        ;;
    *)
        echo -e "${YELLOW}[WARNING]${NC} Unsupported architecture: $ARCH. Skipping ZIVPN install."
        exit 0
        ;;
esac

systemctl stop zivpn.service 2>/dev/null || true
mkdir -p /etc/zivpn
mkdir -p /etc/tunneling/zivpn

wget -q -O /usr/local/bin/zivpn "$BIN_URL" || curl -sL "$BIN_URL" -o /usr/local/bin/zivpn
chmod +x /usr/local/bin/zivpn

if [ ! -f /etc/zivpn/config.json ]; then
    wget -q -O /etc/zivpn/config.json https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json || \
    cat > /etc/zivpn/config.json << 'EOF'
{
  "listen": ":5667",
  "cert": "/etc/zivpn/zivpn.crt",
  "key": "/etc/zivpn/zivpn.key",
  "obfs": "zivpn",
  "auth": {
    "mode": "passwords",
    "config": ["zi"]
  }
}
EOF
fi

if [ ! -f /etc/zivpn/zivpn.key ] || [ ! -f /etc/zivpn/zivpn.crt ]; then
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" \
        -keyout /etc/zivpn/zivpn.key -out /etc/zivpn/zivpn.crt >/dev/null 2>&1
fi

sysctl -w net.core.rmem_max=16777216 >/dev/null 2>&1
sysctl -w net.core.wmem_max=16777216 >/dev/null 2>&1

cat > /etc/systemd/system/zivpn.service << 'EOF'
[Unit]
Description=zivpn VPN Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=/usr/local/bin/zivpn server -c /etc/zivpn/config.json
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable zivpn.service >/dev/null 2>&1
systemctl restart zivpn.service >/dev/null 2>&1

if [ -f /usr/local/sbin/tunneling/xray/zivpn-common.sh ]; then
    source /usr/local/sbin/tunneling/xray/zivpn-common.sh
    sync_zivpn_auth_config
fi

NET_IFACE=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
if [ -n "$NET_IFACE" ]; then
    iptables -t nat -C PREROUTING -i "$NET_IFACE" -p udp --dport 6000:19999 -j DNAT --to-destination :5667 2>/dev/null || \
    iptables -t nat -A PREROUTING -i "$NET_IFACE" -p udp --dport 6000:19999 -j DNAT --to-destination :5667
fi

if command -v ufw >/dev/null 2>&1; then
    ufw allow 6000:19999/udp >/dev/null 2>&1 || true
    ufw allow 5667/udp >/dev/null 2>&1 || true
fi

echo -e "${GREEN}[SUCCESS]${NC} ZIVPN UDP installed (port 5667 + forwarding 6000:19999/udp)."
