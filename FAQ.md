# ❓ FAQ (Frequently Asked Questions)

## 📌 General Questions

### Q: Apakah script ini gratis?
**A:** Ya, script ini gratis dan open source. Semua file tidak dikunci dan bisa diedit.

### Q: Boleh dijual/disewakan?
**A:** Ya, Anda bebas menggunakan script ini untuk bisnis VPN (jualan/sewa).

### Q: Support OS apa saja?
**A:** Ubuntu 22.04+ dan Debian 11+. Tidak support CentOS atau OS lain.

### Q: Berapa minimal spesifikasi VPS?
**A:** Minimal 1GB RAM, 1 CPU Core, 10GB storage. Recommended 2GB RAM untuk performa lebih baik.

### Q: Bisa pakai VPS shared/murah?
**A:** Bisa, tapi pastikan tidak overselling. Recommended pakai VPS dedicated atau KVM.

## 🚀 Installation Questions

### Q: Berapa lama proses instalasi?
**A:** 5-10 menit tergantung kecepatan VPS dan internet.

### Q: Perlu domain berbayar?
**A:** Tidak wajib. Bisa pakai subdomain gratis dari Freenom, DuckDNS, dll.

### Q: Bisa pakai IP VPS langsung tanpa domain?
**A:** Tidak recommended. Domain diperlukan untuk SSL certificate.

### Q: Error saat instalasi, apa yang harus dilakukan?
**A:** Cek [TROUBLESHOOTING.md](TROUBLESHOOTING.md) atau install ulang VPS dari scratch.

### Q: Bisa install di VPS yang sudah ada aplikasi lain?
**A:** Tidak recommended. Gunakan VPS fresh install untuk menghindari konflik.

## 🔐 Account Management Questions

### Q: Berapa maksimal user per VPS?
**A:** Tergantung spesifikasi VPS:
- 1GB RAM: ~50 users
- 2GB RAM: ~100 users
- 4GB RAM: ~200+ users

### Q: Bagaimana cara limit quota user?
**A:** Saat create account, set limit quota. Auto lock/delete jika quota habis.

### Q: Bagaimana cara cek user yang online?
**A:** `menu → 1 → 5` untuk SSH. Untuk XRAY, cek via monitoring tools.

### Q: Bisa transfer account antar VPS?
**A:** Ya, backup dari VPS lama, restore ke VPS baru.

### Q: User masih bisa login padahal sudah expired?
**A:** Run manual delete: `menu → 1 → 7` atau tunggu auto delete jam 00:00.

## 🤖 Bot Telegram Questions

### Q: Wajib pakai bot Telegram?
**A:** Tidak wajib, tapi sangat recommended untuk otomasi.

### Q: Bisa pakai payment gateway lain selain QRIS?
**A:** Saat ini hanya support QRIS. Payment gateway lain akan ditambahkan di update mendatang.

### Q: Bot tidak response, kenapa?
**A:** Cek `systemctl status telegram-bot`. Restart jika perlu.

### Q: Bisa custom pesan bot?
**A:** Ya, edit file `/etc/tunneling/bot/telegram_bot.py`.

### Q: Bagaimana cara auto approve payment?
**A:** Edit `/etc/tunneling/bot/config.json`, set `"auto_approve": true`. (Not recommended, rawan fraud)

## 💰 Pricing & Business Questions

### Q: Berapa harga jual yang pas?
**A:** Tergantung market. Cek [PRICE-LIST.md](PRICE-LIST.md) untuk referensi.

### Q: Bagaimana cara dapat banyak customer?
**A:** Marketing di social media, forum, grup WA/Telegram, iklan Google/Facebook.

### Q: Profit per bulan bisa berapa?
**A:** Sangat variatif. Dengan 50 customer @Rp30k = Rp1.5jt profit/bulan.

### Q: Bisa reseller script ini?
**A:** Ya, Anda bisa jual script ini atau jual akses VPS dengan script ini.

### Q: Berapa modal awal yang dibutuhkan?
**A:** 
- VPS: Rp50k-200k/bulan
- Domain: Rp15k-100k/tahun
- Total: ~Rp100k untuk mulai

## 🔧 Technical Questions

### Q: Bagaimana cara ganti port?
**A:** `menu → 8 → 3` atau edit config file service yang ingin diganti.

### Q: Bisa pakai CloudFlare CDN?
**A:** Ya, sangat recommended untuk VMESS/VLESS/TROJAN. Tutorial ada di dokumentasi CloudFlare.

### Q: Bagaimana cara backup otomatis ke Google Drive?
**A:** Gunakan rclone. Tutorial lengkap ada di internet.

### Q: Bisa install di VPS Windows?
**A:** Tidak. Script ini hanya untuk Linux (Ubuntu/Debian).

### Q: Bagaimana cara upgrade script?
**A:** `wget -O update.sh URL && chmod +x update.sh && ./update.sh`

## 🛡️ Security Questions

### Q: Bagaimana keamanan script ini?
**A:** 
- Auto SSL (HTTPS)
- Fail2ban protection
- Firewall (UFW)
- Regular updates

### Q: Apakah aman untuk jualan VPN?
**A:** Ya, selama:
- Gunakan untuk tujuan legal
- Update system secara berkala
- Backup data rutin
- Monitor activity

### Q: Bagaimana cara mencegah abuse?
**A:** 
- Set limit IP per account
- Set limit quota
- Monitor user activity
- Ban user yang abuse

### Q: VPS kena banned provider, kenapa?
**A:** Kemungkinan user melakukan illegal activity. Tambahkan Terms & Conditions yang jelas.

## 📊 Performance Questions

### Q: Kenapa VPS lemot?
**A:** 
- Terlalu banyak user
- User download/upload besar
- VPS overselling
- Need upgrade RAM/CPU

### Q: Bagaimana cara optimasi performa?
**A:** 
- Aktifkan BBR (sudah auto)
- Limit speed per user
- Gunakan CloudFlare CDN
- Upgrade VPS specs

### Q: Berapa bandwidth yang dibutuhkan?
**A:** Tergantung jumlah user. Rata-rata 1GB/user/hari. Pakai VPS dengan bandwidth unlimited.

### Q: Connection sering putus, kenapa?
**A:** 
- Koneksi internet user tidak stabil
- VPS overload
- Provider VPS bermasalah
- Perlu ganti port/protocol

## 🔄 Update & Maintenance Questions

### Q: Perlu update script?
**A:** Ya, update berkala untuk fitur baru dan security patch.

### Q: Auto update atau manual?
**A:** Manual. Auto update belum tersedia untuk mencegah breaking changes.

### Q: Berapa lama lifecycle script ini?
**A:** Support dan update minimal 1 tahun. Setelah itu tergantung community.

### Q: Bagaimana cara contribute ke project?
**A:** Fork repo, buat changes, submit pull request. Detail di [CONTRIBUTING.md](CONTRIBUTING.md).

## 💬 Support Questions

### Q: Ada komunitas pengguna?
**A:** Join Telegram group: @YourTelegramGroup

### Q: Ada support berbayar?
**A:** Ya, untuk setup, customize, atau manage VPS. Contact untuk harga.

### Q: Berapa lama response time support?
**A:** 
- Free support: 24-48 jam
- Paid support: 1-4 jam

### Q: Tersedia dalam bahasa lain?
**A:** Saat ini hanya Bahasa Indonesia dan English. Language lain coming soon.

## 🎯 Other Questions

### Q: Bisa request fitur baru?
**A:** Ya, submit via GitHub Issues atau contact support.

### Q: Roadmap development ke depan?
**A:** Cek [CHANGELOG.md](CHANGELOG.md) untuk planned updates.

### Q: Ada video tutorial?
**A:** Check YouTube channel: @YourYouTubeChannel

### Q: Bisa hire untuk custom development?
**A:** Ya, contact untuk diskusi requirements dan budget.

---

## ❓ Pertanyaan Tidak Terjawab?

Jika pertanyaan Anda tidak ada di sini:

1. Cek dokumentasi lengkap
2. Search di Issues
3. Tanya di Telegram group
4. Contact support

**Telegram:** @yourtelegram  
**Email:** support@yourdomain.com

---

**Happy Selling! 💰**
