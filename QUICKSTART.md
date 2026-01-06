# 🔥 QUICK START GUIDE

Get your VPN server running in 5 minutes!

## ⚡ Step 1: Prepare VPS

### Requirements:
- Ubuntu 22.04+ or Debian 11+
- 1GB RAM minimum
- 1 CPU Core minimum
- Root access

### Check OS Version:
```bash
lsb_release -a
```

## 🌐 Step 2: Setup Domain

1. Buy a domain or use subdomain
2. Point A record to your VPS IP:
   ```
   vpn.yourdomain.com → 123.456.789.0
   ```
3. Wait for DNS propagation (check with `ping`)

## 🚀 Step 3: Install Script

### Quick Install:
```bash
wget https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

### Input Required:
1. Domain: `vpn.yourdomain.com`
2. Email: `admin@yourdomain.com`

⏱️ Wait 5-10 minutes for installation...

## 🎯 Step 4: Access Menu

After installation:
```bash
menu
```

You'll see:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           AUTOSCRIPT TUNNELING VPN PANEL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 📱 Step 5: Setup Telegram Bot (Optional)

### 5.1 Create Bot:
1. Open [@BotFather](https://t.me/BotFather)
2. Send `/newbot`
3. Follow instructions
4. Copy bot token

### 5.2 Get Your User ID:
1. Open [@userinfobot](https://t.me/userinfobot)
2. Copy your ID

### 5.3 Configure Bot:
```bash
menu → 7 → 1  # Bot Telegram → Setup Bot
```

Input:
- Bot Token: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`
- Your User ID: `123456789`

### 5.4 Upload QRIS:
```bash
menu → 7 → 7  # Bot Telegram → Payment Settings
```

Upload your QRIS payment image.

## 👤 Step 6: Create First Account

### SSH Account:
```bash
menu → 1 → 1  # SSH Menu → Create SSH Account
```

Input:
- Username: `testuser`
- Password: `testpass123`
- Expired: `30` days
- Limit IP: `2`
- Limit Quota: `50` GB

### You'll get:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            SSH ACCOUNT CREATED SUCCESSFULLY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Domain       : vpn.yourdomain.com
Username     : testuser
Password     : testpass123
Expired Date : 01 Feb 2024
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🧪 Step 7: Test Connection

### Using HTTP Injector (Android):
1. Download HTTP Injector
2. Create payload:
   ```
   GET / HTTP/1.1[crlf]
   Host: vpn.yourdomain.com[crlf]
   Upgrade: websocket[crlf]
   Connection: Upgrade[crlf][crlf]
   ```
3. Settings:
   - Remote Proxy: `vpn.yourdomain.com`
   - Remote Port: `443`
   - SSH Server: `vpn.yourdomain.com:109`
   - Username: `testuser`
   - Password: `testpass123`

### Using V2RayNG (Android):
1. Download V2RayNG
2. Create VMESS config from menu
3. Scan QR code or import link

## ✅ Done!

Your VPN server is ready! 🎉

### Next Steps:
- Setup auto order bot
- Configure price list
- Start selling! 💰

## 📞 Need Help?

- Read [INSTALL.md](INSTALL.md) for detailed guide
- Check [README.md](README.md) for features
- Contact support if stuck

---

**Happy Selling!** 💰
