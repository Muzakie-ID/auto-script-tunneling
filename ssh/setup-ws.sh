#!/bin/bash

# Install and Setup WebSocket-SSH

# Install dependencies
apt-get install -y python3-pip
pip3 install websockify

# Create service for WS-SSH (Port 700 -> Port 22)
cat > /etc/systemd/system/ws-ssh.service << EOF
[Unit]
Description=WebSocket SSH Bridge
Documentation=https://github.com/novnc/websockify
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 -m websockify 700 127.0.0.1:22
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF

# Reload and start
systemctl daemon-reload
systemctl enable ws-ssh
systemctl restart ws-ssh

echo "WebSocket-SSH (700 -> 22) installed and started."
