#!/bin/bash

# Stunnel Configuration for SSL/TLS

# Install stunnel
apt-get install -y stunnel4

# Enable stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

# Get domain and create config
DOMAIN=$(cat /root/domain.txt)

cat > /etc/stunnel/stunnel.conf << EOF
# Stunnel Configuration
cert = /etc/letsencrypt/live/$DOMAIN/fullchain.pem
key = /etc/letsencrypt/live/$DOMAIN/privkey.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 442
connect = 127.0.0.1:109

[dropbear-2]
accept = 443
connect = 127.0.0.1:109

[openssh]
accept = 777
connect = 127.0.0.1:22
EOF

# Create systemd service
cat > /etc/systemd/system/stunnel4.service << EOF
[Unit]
Description=SSL tunnel for network daemons
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/stunnel4 /etc/stunnel/stunnel.conf
ExecStop=/usr/bin/pkill stunnel4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
systemctl daemon-reload
systemctl enable stunnel4
systemctl restart stunnel4

echo "Stunnel configured successfully!"
echo "SSL ports: 442, 443, 777"
