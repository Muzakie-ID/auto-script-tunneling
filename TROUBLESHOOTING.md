# 🚨 TROUBLESHOOTING GUIDE

Common issues and how to fix them.

## 🔍 Installation Issues

### Issue: "This OS is not supported"
**Solution:**
- Check OS version: `lsb_release -a`
- Must be Ubuntu 22.04+ or Debian 11+
- Update OS if needed: `apt update && apt upgrade -y`

### Issue: "Domain cannot be empty"
**Solution:**
- Make sure domain is pointed to VPS IP
- Check DNS: `ping yourdomain.com`
- Wait for DNS propagation (can take up to 24 hours)

### Issue: Installation stuck
**Solution:**
```bash
# Kill installation
pkill -f setup.sh

# Check running processes
ps aux | grep setup

# Start fresh
rm -f setup.sh
wget https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/setup.sh
chmod +x setup.sh
./setup.sh
```

## 🌐 Domain & SSL Issues

### Issue: "SSL certificate failed"
**Solution:**
```bash
# Renew SSL manually
menu → 8 → 7  # Settings → Renew SSL

# Or via command
certbot renew --force-renewal
systemctl reload nginx
```

### Issue: "Domain not working"
**Solution:**
```bash
menu → 8 → 5  # Settings → Fix Error Domain

# Manual fix:
systemctl restart nginx
systemctl restart xray
```

### Issue: "502 Bad Gateway"
**Solution:**
```bash
# Check nginx
systemctl status nginx
nginx -t

# Check xray
systemctl status xray

# Restart services
systemctl restart nginx xray
```

## 🔌 Connection Issues

### Issue: "Cannot connect to SSH"
**Solution:**
```bash
# Check SSH service
systemctl status ssh
systemctl status dropbear

# Check ports
netstat -tulpn | grep -E '22|109|143'

# Restart SSH
systemctl restart ssh dropbear stunnel4
```

### Issue: "Cannot connect to VMESS/VLESS/TROJAN"
**Solution:**
```bash
# Check XRAY
systemctl status xray
journalctl -u xray -n 50

# Check XRAY config
cat /etc/xray/config.json

# Restart XRAY
systemctl restart xray
```

### Issue: "Proxy not working"
**Solution:**
```bash
menu → 8 → 6  # Settings → Fix Error Proxy

# Manual fix:
systemctl status squid
systemctl restart squid
```

## 👤 Account Issues

### Issue: "Account created but cannot login"
**Solution:**
```bash
# Check if user exists
id username

# Check expiration
chage -l username

# Reset password
echo 'username:newpassword' | chpasswd
```

### Issue: "Account still works after expired"
**Solution:**
```bash
# Delete manually
userdel -f username
rm -f /etc/tunneling/ssh/username.json

# Run auto delete
/usr/local/sbin/tunneling/delete-expired.sh
```

### Issue: "Cannot create account"
**Solution:**
```bash
# Check disk space
df -h

# Check permissions
ls -la /etc/tunneling/

# Fix permissions
chmod -R 755 /etc/tunneling/
```

## 🤖 Bot Telegram Issues

### Issue: "Bot not responding"
**Solution:**
```bash
# Check bot status
systemctl status telegram-bot

# Check logs
journalctl -u telegram-bot -n 50

# Restart bot
systemctl restart telegram-bot
```

### Issue: "Bot token invalid"
**Solution:**
```bash
# Reconfigure bot
menu → 7 → 1  # Bot Telegram → Setup Bot

# Edit config manually
nano /etc/tunneling/bot/config.json
```

### Issue: "Order not working"
**Solution:**
```bash
# Check bot config
cat /etc/tunneling/bot/config.json

# Check Python dependencies
pip3 list | grep telegram

# Reinstall dependencies
pip3 install --upgrade pytelegrambotapi
systemctl restart telegram-bot
```

## 💾 Backup Issues

### Issue: "Backup failed"
**Solution:**
```bash
# Check disk space
df -h

# Check permissions
ls -la /etc/tunneling/backup/

# Manual backup
tar -czf /root/manual-backup.tar.gz /etc/tunneling/
```

### Issue: "Cannot restore backup"
**Solution:**
```bash
# Check backup file
tar -tzf /etc/tunneling/backup/backup-file.tar.gz

# Extract to temp first
mkdir /tmp/restore-test
tar -xzf /etc/tunneling/backup/backup-file.tar.gz -C /tmp/restore-test

# Then restore
tar -xzf /etc/tunneling/backup/backup-file.tar.gz -C /
```

## 📊 Performance Issues

### Issue: "High CPU usage"
**Solution:**
```bash
# Check processes
top
htop

# Limit XRAY workers
nano /etc/xray/config.json
# Add: "workers": 2

# Restart XRAY
systemctl restart xray
```

### Issue: "High RAM usage"
**Solution:**
```bash
# Check memory
free -m

# Clear cache
sync && echo 3 > /proc/sys/vm/drop_caches

# Restart services
systemctl restart xray nginx
```

### Issue: "Slow connection"
**Solution:**
```bash
# Check bandwidth
vnstat

# Run speedtest
speedtest-cli

# Check for heavy users
menu → 5 → 4  # System → Monitor VPS

# Limit speed
menu → 5 → 7  # System → Limit Speed
```

## 🔥 Critical Issues

### Issue: "VPS not responding"
**Solution:**
1. Login via VPS provider console
2. Check system logs:
   ```bash
   dmesg | tail -50
   journalctl -xe
   ```
3. Restart problematic services
4. Reboot if necessary: `reboot`

### Issue: "All services down"
**Solution:**
```bash
# Restart all services
menu → 5 → 2  # System → Restart All Services

# Or manually:
systemctl restart ssh
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart squid
systemctl restart nginx
systemctl restart xray
systemctl restart telegram-bot
```

### Issue: "Cannot access menu"
**Solution:**
```bash
# Check if files exist
ls -la /usr/local/sbin/tunneling/

# Reinstall menu
cd /tmp
wget https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/menu/main-menu.sh
cp main-menu.sh /usr/local/sbin/tunneling/
chmod +x /usr/local/sbin/tunneling/main-menu.sh
```

## 📝 Log Files

Check these logs for more information:

```bash
# System logs
tail -f /var/log/syslog

# Nginx logs
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# XRAY logs
tail -f /var/log/xray/error.log
tail -f /var/log/xray/access.log

# Tunneling logs
tail -f /var/log/tunneling/error.log
tail -f /var/log/tunneling/delete-expired.log
tail -f /var/log/tunneling/auto-backup.log

# Bot logs
journalctl -u telegram-bot -f
```

## 🆘 Still Need Help?

If issue persists:

1. **Collect information:**
   ```bash
   # System info
   uname -a
   lsb_release -a
   
   # Service status
   systemctl status ssh dropbear stunnel4 squid nginx xray
   
   # Error logs
   tail -100 /var/log/nginx/error.log
   tail -100 /var/log/xray/error.log
   ```

2. **Contact support:**
   - Telegram: @yourtelegram
   - Email: support@yourdomain.com
   - Include: OS version, error messages, logs

## 🔄 Last Resort

If nothing works, reinstall:

```bash
# Backup data first!
menu → 6 → 1  # Backup Now

# Download backup
scp root@your-vps:/etc/tunneling/backup/latest.tar.gz .

# Reinstall
wget https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/setup.sh
chmod +x setup.sh
./setup.sh

# Restore backup
menu → 6 → 2  # Restore Backup
```

---

**Hope this helps! 🙏**
