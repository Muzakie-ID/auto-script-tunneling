#!/bin/bash

# Setup UDP Custom / BadVPN

# Download binary badvpn
echo "Downloading BadVPN..."
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main/bin/badvpn-udpgw"
chmod +x /usr/bin/badvpn-udpgw

# Create BadVPN Service
cat > /etc/systemd/system/badvpn.service << EOF
[Unit]
Description=BadVPN UDP Gateway
Documentation=https://github.com/ambrop72/badvpn
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable & Start Service
systemctl daemon-reload
systemctl enable badvpn
systemctl start badvpn

echo "BadVPN UDP Gateway installed and running on port 7300"
