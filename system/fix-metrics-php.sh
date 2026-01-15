#!/bin/bash

# Quick Fix for metrics.php not working
# This script diagnoses and fixes common issues

echo "==================================="
echo "  Metrics PHP Diagnostic & Fix    "
echo "==================================="
echo ""

# Check PHP installation
echo "[1] Checking PHP installation..."
if ! command -v php &> /dev/null; then
    echo "❌ PHP not installed! Installing..."
    apt-get update
    apt-get install -y php php-fpm php-cli
else
    echo "✅ PHP installed: $(php -v | head -n1)"
fi

# Check PHP-FPM
echo ""
echo "[2] Checking PHP-FPM service..."
if systemctl is-active --quiet php*-fpm; then
    echo "✅ PHP-FPM is running"
else
    echo "⚠️  PHP-FPM not running. Starting..."
    systemctl start php*-fpm
    systemctl enable php*-fpm
fi

# Check metrics.php exists
echo ""
echo "[3] Checking metrics.php file..."
if [ -f /var/www/html/metrics.php ]; then
    echo "✅ metrics.php exists"
    
    # Check permissions
    chmod 644 /var/www/html/metrics.php
    chown www-data:www-data /var/www/html/metrics.php
    echo "✅ Permissions fixed"
else
    echo "❌ metrics.php not found!"
fi

# Test PHP execution
echo ""
echo "[4] Testing PHP execution..."
php -r "echo 'PHP works!';" && echo " ✅" || echo " ❌ PHP execution failed"

# Check required tools
echo ""
echo "[5] Checking required system tools..."

# iostat for disk IO
if ! command -v iostat &> /dev/null; then
    echo "⚠️  Installing sysstat (for iostat)..."
    apt-get install -y sysstat
fi

# Test metrics.php directly
echo ""
echo "[6] Testing metrics.php output..."
php /var/www/html/metrics.php 2>&1 | head -n 5

# Check Nginx PHP configuration
echo ""
echo "[7] Checking Nginx PHP config..."
if grep -q "fastcgi_pass" /etc/nginx/sites-available/vpn 2>/dev/null; then
    echo "✅ Nginx configured for PHP"
else
    echo "❌ Nginx PHP config missing!"
fi

# Restart services
echo ""
echo "[8] Restarting services..."
systemctl restart php*-fpm
systemctl reload nginx

echo ""
echo "==================================="
echo "  Fix Complete!                    "
echo "==================================="
echo ""
echo "Test URL: http://$(cat /root/domain.txt)/metrics.php"
echo ""
echo "If still not working, check browser console (F12) for errors"
