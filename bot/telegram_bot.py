#!/usr/bin/env python3
import os
import sys
import json
import telebot
import requests
from datetime import datetime, timedelta
from telebot import types

# Load config
CONFIG_FILE = '/etc/tunneling/bot/config.json'

def load_config():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    return {}

config = load_config()

if not config.get('token'):
    print("Bot token not configured. Please run bot-setup.sh first.")
    sys.exit(1)

bot = telebot.TeleBot(config['token'])
ADMIN_ID = config.get('admin_id', '')

# Price list
PRICES = {
    'ssh_7': {'name': 'SSH 7 Days', 'price': 10000, 'days': 7, 'type': 'ssh'},
    'ssh_30': {'name': 'SSH 30 Days', 'price': 30000, 'days': 30, 'type': 'ssh'},
    'vmess_7': {'name': 'VMESS 7 Days', 'price': 15000, 'days': 7, 'type': 'vmess'},
    'vmess_30': {'name': 'VMESS 30 Days', 'price': 50000, 'days': 30, 'type': 'vmess'},
    'vless_7': {'name': 'VLESS 7 Days', 'price': 15000, 'days': 7, 'type': 'vless'},
    'vless_30': {'name': 'VLESS 30 Days', 'price': 50000, 'days': 30, 'type': 'vless'},
    'trojan_7': {'name': 'TROJAN 7 Days', 'price': 15000, 'days': 7, 'type': 'trojan'},
    'trojan_30': {'name': 'TROJAN 30 Days', 'price': 50000, 'days': 30, 'type': 'trojan'},
}

# Start command
@bot.message_handler(commands=['start'])
def start(message):
    markup = types.ReplyKeyboardMarkup(resize_keyboard=True, row_width=2)
    btn1 = types.KeyboardButton('📦 Order')
    btn2 = types.KeyboardButton('✅ Trial')
    btn3 = types.KeyboardButton('🔍 Check Account')
    btn4 = types.KeyboardButton('🔄 Renew')
    btn5 = types.KeyboardButton('ℹ️ Info Server')
    btn6 = types.KeyboardButton('💰 Price List')
    markup.add(btn1, btn2, btn3, btn4, btn5, btn6)
    
    welcome_text = f"""
🎉 *Welcome to VPN Bot!* 🎉

Hi {message.from_user.first_name}!

🔐 Fast & Secure VPN Service
⚡️ High Speed Connection
🌍 Multi Protocol Support

*Available Services:*
• SSH (WebSocket & SSL)
• VMESS
• VLESS
• TROJAN

Choose an option from the menu below:
    """
    bot.send_message(message.chat.id, welcome_text, parse_mode='Markdown', reply_markup=markup)

# Order command
@bot.message_handler(func=lambda message: message.text == '📦 Order')
@bot.message_handler(commands=['order'])
def order(message):
    markup = types.InlineKeyboardMarkup(row_width=2)
    
    for key, value in PRICES.items():
        btn = types.InlineKeyboardButton(
            f"{value['name']} - Rp{value['price']:,}",
            callback_data=f"order_{key}"
        )
        markup.add(btn)
    
    bot.send_message(
        message.chat.id,
        "📦 *SELECT PACKAGE*\n\nChoose the package you want to order:",
        parse_mode='Markdown',
        reply_markup=markup
    )

# Handle order callback
@bot.callback_query_handler(func=lambda call: call.data.startswith('order_'))
def handle_order(call):
    package = call.data.replace('order_', '')
    info = PRICES[package]
    
    # Save order to pending
    order_id = f"ORD{datetime.now().strftime('%Y%m%d%H%M%S')}"
    order_data = {
        'order_id': order_id,
        'user_id': call.from_user.id,
        'username': call.from_user.username,
        'package': package,
        'type': info['type'],
        'days': info['days'],
        'price': info['price'],
        'status': 'pending',
        'created': datetime.now().isoformat()
    }
    
    # Save order
    os.makedirs('/etc/tunneling/bot/orders', exist_ok=True)
    with open(f'/etc/tunneling/bot/orders/{order_id}.json', 'w') as f:
        json.dump(order_data, f, indent=2)
    
    # Send payment info
    payment_text = f"""
📦 *ORDER CONFIRMATION*

Order ID: `{order_id}`
Package: {info['name']}
Price: Rp{info['price']:,}
Duration: {info['days']} Days

💳 *PAYMENT METHOD*

Scan QRIS below to pay:
    """
    
    # Send QRIS image if exists
    qris_path = '/etc/tunneling/bot/qris.jpg'
    if os.path.exists(qris_path):
        with open(qris_path, 'rb') as photo:
            bot.send_photo(call.message.chat.id, photo, caption=payment_text, parse_mode='Markdown')
    else:
        bot.send_message(call.message.chat.id, payment_text, parse_mode='Markdown')
    
    # Ask for proof
    markup = types.InlineKeyboardMarkup()
    btn = types.InlineKeyboardButton("✅ Upload Proof", callback_data=f"proof_{order_id}")
    markup.add(btn)
    
    bot.send_message(
        call.message.chat.id,
        "After payment, please upload your payment proof:",
        reply_markup=markup
    )
    
    # Notify admin
    if ADMIN_ID:
        bot.send_message(
            ADMIN_ID,
            f"🆕 NEW ORDER\n\nOrder ID: {order_id}\nUser: @{call.from_user.username}\nPackage: {info['name']}\nPrice: Rp{info['price']:,}"
        )

# Trial command
@bot.message_handler(func=lambda message: message.text == '✅ Trial')
@bot.message_handler(commands=['trial'])
def trial(message):
    markup = types.InlineKeyboardMarkup(row_width=2)
    btn1 = types.InlineKeyboardButton("SSH Trial", callback_data="trial_ssh")
    btn2 = types.InlineKeyboardButton("VMESS Trial", callback_data="trial_vmess")
    btn3 = types.InlineKeyboardButton("VLESS Trial", callback_data="trial_vless")
    btn4 = types.InlineKeyboardButton("TROJAN Trial", callback_data="trial_trojan")
    markup.add(btn1, btn2, btn3, btn4)
    
    bot.send_message(
        message.chat.id,
        "✅ *FREE TRIAL*\n\nSelect protocol for 1 hour trial account:",
        parse_mode='Markdown',
        reply_markup=markup
    )

# Handle trial callback
@bot.callback_query_handler(func=lambda call: call.data.startswith('trial_'))
def handle_trial(call):
    protocol = call.data.replace('trial_', '')
    
    # Generate random credentials
    import random
    import string
    username = f"trial{''.join(random.choices(string.ascii_lowercase + string.digits, k=6))}"
    password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
    
    # Create account (call bash script)
    if protocol == 'ssh':
        os.system(f"useradd -e $(date -d '1 hour' +%Y-%m-%d) -s /bin/false -M {username}")
        os.system(f"echo '{username}:{password}' | chpasswd")
    
    # Get domain
    with open('/root/domain.txt', 'r') as f:
        domain = f.read().strip()
    
    account_text = f"""
✅ *TRIAL ACCOUNT CREATED*

Protocol: {protocol.upper()}
Username: `{username}`
Password: `{password}`
Domain: `{domain}`
Expired: 1 Hour

*Connection Info:*
"""
    
    if protocol == 'ssh':
        account_text += """
SSH Ports:
• OpenSSH: 22
• Dropbear: 109, 143
• SSL/TLS: 442, 443
• Squid: 3128, 8080

WebSocket:
• WS HTTP: ws://{}:80/
• WS HTTPS: wss://{}:443/
        """.format(domain, domain)
    
    bot.send_message(call.message.chat.id, account_text, parse_mode='Markdown')
    
    # Notify admin
    if ADMIN_ID:
        bot.send_message(
            ADMIN_ID,
            f"🆓 TRIAL CREATED\n\nUser: @{call.from_user.username}\nProtocol: {protocol.upper()}\nUsername: {username}"
        )

# Check account
@bot.message_handler(func=lambda message: message.text == '🔍 Check Account')
@bot.message_handler(commands=['check'])
def check_account(message):
    msg = bot.send_message(message.chat.id, "Please enter your username:")
    bot.register_next_step_handler(msg, check_account_process)

def check_account_process(message):
    username = message.text.strip()
    
    # Check if account exists
    for protocol in ['ssh', 'vmess', 'vless', 'trojan']:
        account_file = f'/etc/tunneling/{protocol}/{username}.json'
        if os.path.exists(account_file):
            with open(account_file, 'r') as f:
                data = json.load(f)
            
            status_emoji = "✅" if data['status'] == 'active' else "❌"
            
            info_text = f"""
{status_emoji} *ACCOUNT INFORMATION*

Protocol: {protocol.upper()}
Username: `{username}`
Status: {data['status'].upper()}
Created: {data['created']}
Expired: {data['expired']}
Limit IP: {data['limit_ip']}
Limit Quota: {data['limit_quota']}GB
            """
            
            bot.send_message(message.chat.id, info_text, parse_mode='Markdown')
            return
    
    bot.send_message(message.chat.id, "❌ Account not found!")

# Info server
@bot.message_handler(func=lambda message: message.text == 'ℹ️ Info Server')
@bot.message_handler(commands=['info'])
def info_server(message):
    # Get server info
    with open('/root/domain.txt', 'r') as f:
        domain = f.read().strip()
    
    ip = os.popen('curl -s ifconfig.me').read().strip()
    uptime = os.popen('uptime -p').read().strip()
    
    info_text = f"""
ℹ️ *SERVER INFORMATION*

🌐 Domain: `{domain}`
🌍 IP Address: `{ip}`
⏰ Uptime: {uptime}

*Available Ports:*

SSH:
• OpenSSH: 22
• Dropbear: 109, 143
• SSL/TLS: 442, 443
• Squid: 3128, 8080

XRAY:
• VMESS: 443, 80
• VLESS: 443, 80
• TROJAN: 443, 80

Status: 🟢 Online
    """
    
    bot.send_message(message.chat.id, info_text, parse_mode='Markdown')

# Price list
@bot.message_handler(func=lambda message: message.text == '💰 Price List')
@bot.message_handler(commands=['price'])
def price_list(message):
    price_text = "💰 *PRICE LIST*\n\n"
    
    for key, value in PRICES.items():
        price_text += f"• {value['name']}: Rp{value['price']:,}\n"
    
    price_text += "\n📦 Order now: /order"
    
    bot.send_message(message.chat.id, price_text, parse_mode='Markdown')

# Admin commands
@bot.message_handler(commands=['approve'])
def approve_order(message):
    if str(message.from_user.id) != str(ADMIN_ID):
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    try:
        order_id = message.text.split()[1]
        order_file = f'/etc/tunneling/bot/orders/{order_id}.json'
        
        if not os.path.exists(order_file):
            bot.send_message(message.chat.id, "❌ Order not found!")
            return
        
        with open(order_file, 'r') as f:
            order = json.load(f)
        
        # Create account based on type
        import random
        import string
        username = f"user{''.join(random.choices(string.ascii_lowercase + string.digits, k=6))}"
        password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
        
        protocol = order['type']
        days = order['days']
        
        # Create account
        if protocol == 'ssh':
            os.system(f"useradd -e $(date -d '{days} days' +%Y-%m-%d) -s /bin/false -M {username}")
            os.system(f"echo '{username}:{password}' | chpasswd")
        
        # Update order status
        order['status'] = 'approved'
        order['username'] = username
        order['password'] = password
        with open(order_file, 'w') as f:
            json.dump(order, f, indent=2)
        
        # Send to user
        with open('/root/domain.txt', 'r') as f:
            domain = f.read().strip()
        
        user_text = f"""
✅ *PAYMENT APPROVED*

Your order has been approved!

Protocol: {protocol.upper()}
Username: `{username}`
Password: `{password}`
Domain: `{domain}`
Expired: {days} Days

Thank you for your order! 🎉
        """
        
        bot.send_message(order['user_id'], user_text, parse_mode='Markdown')
        bot.send_message(message.chat.id, f"✅ Order {order_id} approved!")
        
    except Exception as e:
        bot.send_message(message.chat.id, f"❌ Error: {str(e)}")

# Run bot
if __name__ == '__main__':
    print("Bot started...")
    bot.infinity_polling()
