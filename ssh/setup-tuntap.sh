#!/bin/bash

# TUN/TAP Device Configuration for SSH Tunneling

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         SETUP TUN/TAP DEVICE FOR SSH              ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if TUN module is loaded
if ! lsmod | grep -q "^tun"; then
    echo -e "${CYAN}[1/6]${NC} Loading TUN module..."
    modprobe tun
    echo "tun" >> /etc/modules-load.d/tun.conf
    echo -e "${GREEN}✓${NC} TUN module loaded"
else
    echo -e "${GREEN}✓${NC} TUN module already loaded"
fi

# Enable IP forwarding
echo -e "${CYAN}[2/6]${NC} Enabling IP forwarding..."
cat > /etc/sysctl.d/99-ip-forward.conf << EOF
# Enable IP forwarding for tunneling
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1

# Optimize network for tunneling
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF

sysctl -p /etc/sysctl.d/99-ip-forward.conf
echo -e "${GREEN}✓${NC} IP forwarding enabled"

# Get network interface
echo -e "${CYAN}[3/6]${NC} Detecting network interface..."
INET_IFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
if [ -z "$INET_IFACE" ]; then
    INET_IFACE="eth0"
fi
echo -e "${GREEN}✓${NC} Network interface: $INET_IFACE"

# Setup iptables rules
echo -e "${CYAN}[4/6]${NC} Configuring iptables rules..."

# Flush existing rules
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

# Default policies
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# NAT for TUN/TAP devices
iptables -t nat -A POSTROUTING -o $INET_IFACE -j MASQUERADE
iptables -A FORWARD -i tun+ -o $INET_IFACE -j ACCEPT
iptables -A FORWARD -i $INET_IFACE -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow SSH tunneling
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 109 -j ACCEPT
iptables -A INPUT -p tcp --dport 143 -j ACCEPT
iptables -A INPUT -p tcp --dport 442 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 3128 -j ACCEPT

# Allow UDP for custom SSH
iptables -A INPUT -p udp --dport 1-65535 -j ACCEPT

# Save iptables rules
mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
echo -e "${GREEN}✓${NC} iptables rules configured"

# Create iptables restore script
echo -e "${CYAN}[5/6]${NC} Creating iptables restore script..."
cat > /etc/network/if-pre-up.d/iptables << 'EOF'
#!/bin/sh
/sbin/iptables-restore < /etc/iptables/rules.v4
EOF

chmod +x /etc/network/if-pre-up.d/iptables

# Also create systemd service for iptables restore
cat > /etc/systemd/system/iptables-restore.service << EOF
[Unit]
Description=Restore iptables rules
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables/rules.v4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable iptables-restore.service
echo -e "${GREEN}✓${NC} iptables restore configured"

# Install iptables-persistent
echo -e "${CYAN}[6/6]${NC} Installing iptables-persistent..."
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get install -y iptables-persistent
echo -e "${GREEN}✓${NC} iptables-persistent installed"

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}        TUN/TAP DEVICE SETUP COMPLETED!             ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Configuration Summary:${NC}"
echo -e "  • TUN module: Loaded"
echo -e "  • IP forwarding: Enabled"
echo -e "  • Network interface: $INET_IFACE"
echo -e "  • iptables NAT: Configured"
echo -e "  • Auto-restore: Enabled"
echo ""
echo -e "${GREEN}✓ SSH UDP Custom ready to use!${NC}"
echo -e "${GREEN}✓ Tunneling optimized!${NC}"
echo ""
