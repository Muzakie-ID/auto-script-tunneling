# AUTOSCRIPT TUNNELING VPN

Script otomatis untuk setup VPN Server dengan berbagai protocol yang siap dijual/disewakan.

## 📋 Minimum Requirements

- **OS:** Ubuntu 22.04+ atau Debian 11+
- **RAM:** 1 GB (Optimized untuk low resource)
- **CPU:** 1 Core
- **Storage:** 10 GB
- **Bandwidth:** Unlimited recommended

## 🚀 Supported Protocols

- **SSH WebSocket & SSL**
- **SSH UDP Custom**
- **VMESS**
- **VLESS**
- **TROJAN**

## ✨ Fitur Lengkap

### 📊 Management & Monitoring
- ✅ Cek Running Service
- ✅ Restart Service
- ✅ Auto Reboot (Configurable)
- ✅ Monitor VPS (CPU, RAM, Bandwidth)
- ✅ Speedtest
- ✅ Monitor Service Status

### 👤 Account Management
- ✅ Create Account
- ✅ Delete Account
- ✅ Renew Account
- ✅ Trial Account
- ✅ Lock Account
- ✅ Unlock Account
- ✅ List All Accounts
- ✅ Detail Account
- ✅ Delete All Expired Accounts

### 🔒 Security & Limits
- ✅ Limit IP per Account
- ✅ Limit Quota per Account
- ✅ Auto Lock (When limit reached)
- ✅ Auto Delete (When expired)
- ✅ Edit Limit IP & Quota
- ✅ Limit Speed VPS

### 🛠️ System Management
- ✅ Change Domain
- ✅ Change Banner/Login
- ✅ Fix Error Domain
- ✅ Fix Error Proxy
- ✅ Backup & Restore
- ✅ Auto Backup (Daily)
- ✅ Auto Record Wildcard Domain

### 🤖 Bot Telegram
- ✅ Notifikasi Telegram
- ✅ Auto Order System
- ✅ Payment QRIS (Auto & Manual)
- ✅ Notifikasi Account Expired
- ✅ Notifikasi Login User

### 🎨 Customization
- ✅ Manual UUID (XRAY)
- ✅ Semua File TIDAK DIKUNCI
- ✅ Bisa Edit Semua Config
- ✅ Custom Banner
- ✅ Custom Port

## 📦 Installation

### ⚙️ Pre-Installation (Optional - Enable SSH Root Login)

Jika VPS Anda belum enable SSH root login dengan password, jalankan script ini terlebih dahulu:

```bash
wget https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/system/enable-ssh-root.sh && chmod +x enable-ssh-root.sh && ./enable-ssh-root.sh
```

Script ini akan:
- ✅ Enable SSH root login
- ✅ Set password untuk root user
- ✅ Display IP, username, password untuk login
- ✅ Auto restart SSH service

**⚠️ Note:** Lewati step ini jika Anda sudah bisa login sebagai root dengan password.

---

### Quick Install (One-Liner)

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && apt update && apt install -y bzip2 gzip coreutils screen curl unzip wget && wget https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/setup.sh && chmod +x setup.sh && sed -i -e 's/\r$//' setup.sh && screen -S setup ./setup.sh
```

### Quick Install (Step by Step)

```bash
apt update && apt upgrade -y
wget -O setup.sh https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

### Manual Installation

```bash
git clone https://github.com/Muzakie-ID/auto-script-tunneling.git
cd auto-script-tunneling
chmod +x setup.sh
./setup.sh
```

## 🔄 Update Script

### Update via Command

```bash
# Cara 1: Menggunakan update.sh
curl -sL https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/update.sh | bash

# Cara 2: Menggunakan git clone (Recommended)
cd /tmp && rm -rf auto-script-tunneling && git clone https://github.com/Muzakie-ID/auto-script-tunneling.git && cd auto-script-tunneling && cp -f menu/*.sh ssh/*.sh system/*.sh xray/*.sh bot/*.sh /usr/local/sbin/tunneling/ && cp -f bot/telegram_bot.py /usr/local/sbin/tunneling/ && chmod +x /usr/local/sbin/tunneling/*.sh /usr/local/sbin/tunneling/telegram_bot.py && systemctl restart telegram-bot 2>/dev/null && cd ~ && rm -rf /tmp/auto-script-tunneling && echo "✓ Update completed!"

# Cara 3: Via Menu
menu → System Menu → Update/Repair Scripts
```

## 🎯 Cara Penggunaan

Setelah instalasi selesai, akses menu dengan command:

```bash
menu
```

### Menu Utama

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     AUTOSCRIPT TUNNELING VPN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. SSH Menu
2. VMESS Menu
3. VLESS Menu
4. TROJAN Menu
5. System Menu
6. Backup & Restore
7. Bot Telegram
8. Settings
9. Information
0. Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 📱 Setup Bot Telegram

1. Buat bot baru di [@BotFather](https://t.me/BotFather)
2. Copy Token Bot
3. Masuk menu: `menu` → `7. Bot Telegram` → `Setup Bot`
4. Paste Token Bot
5. Bot siap digunakan

### Fitur Bot Telegram

- `/start` - Mulai bot
- `/order` - Pesan account baru
- `/check` - Cek account
- `/renew` - Perpanjang account
- `/trial` - Minta trial account
- `/info` - Info server

## 💰 Setup Auto Order & Payment

### Setup QRIS Payment

1. Masuk menu: `menu` → `7. Bot Telegram` → `Payment Setup`
2. Upload QRIS Image
3. Set Payment Gateway (Manual/Auto)
4. Set Price List

### Cara Kerja Auto Order

1. User kirim `/order` di Telegram
2. Bot tampilkan paket & harga
3. User pilih paket
4. Bot generate QRIS payment
5. User upload bukti bayar
6. Admin approve (manual) atau Auto approve
7. Account otomatis dibuat & dikirim ke user

## 🔧 Configuration Files

Semua file konfigurasi bisa di-edit:

```
/etc/tunneling/
├── config.json          # Main config
├── ssh/                 # SSH configs
├── xray/                # XRAY configs
├── vmess/              # VMESS configs
├── vless/              # VLESS configs
├── trojan/             # TROJAN configs
├── backup/             # Backup files
└── bot/                # Bot configs
```

## 🛡️ Security Best Practices

1. **Change Default Ports** - Ubah port default setelah instalasi
2. **Enable Firewall** - UFW otomatis diaktifkan
3. **Regular Backup** - Auto backup setiap hari
4. **Update System** - Update system secara berkala
5. **Monitor Logs** - Cek log di `/var/log/tunneling/`

## 📊 Monitoring

### Cek Status Service

```bash
menu → 5. System Menu → 1. Check Services
```

### Monitor Resource

```bash
menu → 5. System Menu → 4. Monitor VPS
```

### Cek Account Login

```bash
menu → 1. SSH Menu → 6. List Online Users
```

## 🔄 Backup & Restore

### Manual Backup

```bash
menu → 6. Backup & Restore → 1. Backup Now
```

### Restore Backup

```bash
menu → 6. Backup & Restore → 2. Restore Backup
```

### Auto Backup

Auto backup otomatis jalan setiap hari pukul 02:00 WIB

## 🆘 Troubleshooting

### Fix Error Domain

```bash
menu → 8. Settings → 5. Fix Error Domain
```

### Fix Error Proxy

```bash
menu → 8. Settings → 6. Fix Error Proxy
```

### Restart All Services

```bash
menu → 5. System Menu → 2. Restart Services
```

### Check Logs

```bash
tail -f /var/log/tunneling/error.log
```

## 📝 Port Information

### Default Ports

- **SSH:**
  - OpenSSH: 22
  - Dropbear: 109, 143
  - SSL: 442, 443
  - Squid: 3128, 8080
  - OpenVPN: 1194
  - UDP Custom: 1-65535

- **XRAY:**
  - VMESS: 443, 80
  - VLESS: 443, 80
  - TROJAN: 443, 80
  - VMESS WS: 80, 8080
  - VLESS WS: 80, 8080
  - TROJAN WS: 80, 8080

- **Other:**
  - Nginx: 80, 443
  - Proxy: 2082, 2086, 2087, 2095, 2096

## 💡 Tips & Tricks

1. **Optimasi RAM** - Script sudah dioptimasi untuk 1GB RAM
2. **Limit User** - Set limit IP & Quota untuk kontrol bandwidth
3. **Auto Delete** - Aktifkan auto delete expired untuk hemat resource
4. **Custom Banner** - Buat banner menarik untuk branding
5. **Bot Telegram** - Otomasi penuh dengan bot telegram

## 🔄 Update Script

```bash
cd /root
wget -O update.sh https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling/main/update.sh
chmod +x update.sh
./update.sh
```

## 📞 Support

- **Telegram:** @yourtelegram
- **WhatsApp:** +62xxx
- **Email:** support@yourdomain.com

## 📄 License

Script ini TIDAK DIKUNCI dan bisa di-edit sesuai kebutuhan.
Silahkan digunakan untuk keperluan komersial (jualan/sewa VPN).

## ⚠️ Disclaimer

- Script ini untuk educational purpose
- Gunakan dengan bijak dan legal
- Admin tidak bertanggung jawab atas penyalahgunaan

## 🎉 Features Coming Soon

- [ ] Multi-user Shadowsocks
- [ ] Wireguard Support
- [ ] V2Ray Support
- [ ] Multi-domain Support
- [ ] Web Panel Admin
- [ ] Mobile App

---

**© 2024 AUTOSCRIPT TUNNELING - All Rights Reserved**

**Happy Selling! 💰**
