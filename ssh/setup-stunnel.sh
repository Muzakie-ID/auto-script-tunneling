#!/bin/bash

# Stunnel Configuration for SSL/TLS

# Install stunnel
apt-get install -y stunnel4

# Enable stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

# Get domain and create config
DOMAIN=$(cat /root/domain.txt)

# Check if SSL certificate exists
if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "Warning: SSL certificate not found. Using self-signed certificate..."
    # Create self-signed certificate
    mkdir -p /etc/stunnel
    openssl req -new -x509 -days 365 -nodes \
        -out /etc/stunnel/stunnel.pem \
        -keyout /etc/stunnel/stunnel.pem \
        -subj "/C=ID/ST=Jakarta/L=Jakarta/O=Tunneling/CN=$DOMAIN" &>/dev/null
    CERT_FILE="/etc/stunnel/stunnel.pem"
else
    CERT_FILE="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    KEY_FILE="/etc/letsencrypt/live/$DOMAIN/privkey.pem"
fi

# Create stunnel config
if [ -n "$KEY_FILE" ]; then
cat > /etc/stunnel/stunnel.conf << EOF
# Stunnel Configuration
cert = $CERT_FILE
key = $KEY_FILE
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 442
connect = 127.0.0.1:109

[openssh]
accept = 777
connect = 127.0.0.1:22
EOF
else
cat > /etc/stunnel/stunnel.conf << EOF
# Stunnel Configuration
cert = $CERT_FILE
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 442
connect = 127.0.0.1:109

[openssh]
accept = 777
connect = 127.0.0.1:22
EOF
fi

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

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Stunnel configured successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SSL/TLS Ports:"
echo "  • Dropbear SSL : 442"
echo "  • OpenSSH SSL  : 777"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Note: Port 443 reserved for Nginx (XRAY reverse proxy)"
