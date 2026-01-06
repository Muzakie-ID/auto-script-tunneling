#!/bin/bash

# Squid Proxy Configuration

# Install squid
apt-get install -y squid

# Backup original config
cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Create new config
cat > /etc/squid/squid.conf << 'EOF'
# Squid Proxy Configuration for VPN

# Listen ports
http_port 3128
http_port 8080

# Allow all
acl all src 0.0.0.0/0
http_access allow all

# DNS servers
dns_nameservers 8.8.8.8 8.8.4.4

# Cache settings
cache deny all

# Hide squid version
httpd_suppress_version_string on

# Anonymize
via off
forwarded_for delete
reply_header_access X-Forwarded-For deny all
reply_header_access Via deny all
reply_header_access Link deny all

# Performance
max_filedesc 65536
workers 4

# Logging
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
EOF

# Create log directory
mkdir -p /var/log/squid
chown proxy:proxy /var/log/squid

# Restart squid
systemctl enable squid
systemctl restart squid

echo "Squid proxy configured successfully!"
echo "Proxy ports: 3128, 8080"
