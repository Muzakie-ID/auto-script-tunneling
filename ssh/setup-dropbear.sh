#!/bin/bash

# Dropbear SSH Configuration

# Install dropbear
apt-get install -y dropbear

# Backup original config
cp /etc/default/dropbear /etc/default/dropbear.bak

# Configure dropbear
cat > /etc/default/dropbear << 'EOF'
# Dropbear configuration
NO_START=0
DROPBEAR_PORT=109
DROPBEAR_EXTRA_ARGS="-p 143"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RECEIVE_WINDOW=65536
EOF

# Create banner
cat > /etc/issue.net << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          WELCOME TO VPN SERVER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔐 Secure Connection
⚡️ High Speed
🌍 Multiple Protocol

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
       Unauthorized access is prohibited
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# Set permissions
chmod 644 /etc/issue.net

# Restart dropbear
systemctl enable dropbear
systemctl restart dropbear

echo "Dropbear configured successfully!"
echo "Listening on ports: 109, 143"
