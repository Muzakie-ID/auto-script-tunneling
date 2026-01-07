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
# Convert admin_id to integer for proper comparison
ADMIN_ID = int(config.get('admin_id', 0))

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
    user_id = message.from_user.id
    
    # Check if user is admin
    if user_id == ADMIN_ID:
        # Admin menu
        markup = types.ReplyKeyboardMarkup(resize_keyboard=True, row_width=2)
        btn1 = types.KeyboardButton('📊 Dashboard')
        btn2 = types.KeyboardButton('✅ Approve Orders')
        btn3 = types.KeyboardButton('👥 Manage Users')
        btn4 = types.KeyboardButton('⚙️ Settings')
        btn5 = types.KeyboardButton('📦 Create Account')
        btn6 = types.KeyboardButton('💰 Price List')
        btn7 = types.KeyboardButton('📈 Statistics')
        btn8 = types.KeyboardButton('🔔 Broadcast')
        markup.add(btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8)
        
        welcome_text = f"""
👑 *ADMIN PANEL* 👑

Hi {message.from_user.first_name}!

You have full access to admin controls.

*Available Commands:*
• Dashboard - View system status
• Approve Orders - Manage pending orders
• Manage Users - View/Edit user accounts
• Settings - Bot configuration
• Create Account - Manual account creation
• Statistics - View sales & usage stats
• Broadcast - Send message to all users
        """
    else:
        # User menu
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

# Admin Dashboard
@bot.message_handler(func=lambda message: message.text == '📊 Dashboard')
def admin_dashboard(message):
    if message.from_user.id != ADMIN_ID:
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    # Count active accounts
    ssh_count = len([f for f in os.listdir('/etc/tunneling/ssh') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/ssh') else 0
    vmess_count = len([f for f in os.listdir('/etc/tunneling/vmess') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/vmess') else 0
    vless_count = len([f for f in os.listdir('/etc/tunneling/vless') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/vless') else 0
    trojan_count = len([f for f in os.listdir('/etc/tunneling/trojan') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/trojan') else 0
    
    # Count pending orders
    pending_orders = len([f for f in os.listdir('/etc/tunneling/bot/orders') if f.endswith('.json') and json.load(open(f'/etc/tunneling/bot/orders/{f}'))['status'] == 'pending']) if os.path.exists('/etc/tunneling/bot/orders') else 0
    
    dashboard_text = f"""
📊 *ADMIN DASHBOARD*

*Active Accounts:*
• SSH: {ssh_count}
• VMESS: {vmess_count}
• VLESS: {vless_count}
• TROJAN: {trojan_count}
• Total: {ssh_count + vmess_count + vless_count + trojan_count}

*Pending Orders:* {pending_orders}

*Bot Status:* ✅ Running
    """
    
    bot.send_message(message.chat.id, dashboard_text, parse_mode='Markdown')

# Admin Approve Orders
@bot.message_handler(func=lambda message: message.text == '✅ Approve Orders')
def approve_orders_menu(message):
    if message.from_user.id != ADMIN_ID:
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    orders_dir = '/etc/tunneling/bot/orders'
    if not os.path.exists(orders_dir):
        bot.send_message(message.chat.id, "No pending orders.")
        return
    
    pending = []
    for f in os.listdir(orders_dir):
        if f.endswith('.json'):
            with open(f'{orders_dir}/{f}', 'r') as file:
                order = json.load(file)
                if order['status'] == 'pending':
                    pending.append(order)
    
    if not pending:
        bot.send_message(message.chat.id, "No pending orders.")
        return
    
    markup = types.InlineKeyboardMarkup()
    for order in pending:
        pkg_info = PRICES.get(order['package'], {})
        btn = types.InlineKeyboardButton(
            f"Order {order['order_id']} - {pkg_info.get('name', 'Unknown')} - Rp{order['price']:,}",
            callback_data=f"approve_{order['order_id']}"
        )
        markup.add(btn)
    
    bot.send_message(
        message.chat.id,
        f"📋 *PENDING ORDERS* ({len(pending)})\n\nClick to approve:",
        parse_mode='Markdown',
        reply_markup=markup
    )

# Handle approve callback
@bot.callback_query_handler(func=lambda call: call.data.startswith('approve_'))
def handle_approve(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    order_id = call.data.replace('approve_', '')
    
    markup = types.InlineKeyboardMarkup(row_width=2)
    btn_yes = types.InlineKeyboardButton("✅ Approve", callback_data=f"confirm_approve_{order_id}")
    btn_no = types.InlineKeyboardButton("❌ Reject", callback_data=f"reject_{order_id}")
    markup.add(btn_yes, btn_no)
    
    bot.send_message(
        call.message.chat.id,
        f"Confirm action for order `{order_id}`?",
        parse_mode='Markdown',
        reply_markup=markup
    )

# Confirm approve
@bot.callback_query_handler(func=lambda call: call.data.startswith('confirm_approve_'))
def confirm_approve_order(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    order_id = call.data.replace('confirm_approve_', '')
    order_file = f'/etc/tunneling/bot/orders/{order_id}.json'
    
    if not os.path.exists(order_file):
        bot.answer_callback_query(call.id, "❌ Order not found!")
        return
    
    with open(order_file, 'r') as f:
        order = json.load(f)
    
    # Create account
    import random
    import string
    username = f"user{''.join(random.choices(string.ascii_lowercase + string.digits, k=6))}"
    password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
    
    protocol = order['type']
    days = order['days']
    
    # Call create script
    if protocol == 'ssh':
        os.system(f"/usr/local/sbin/tunneling/ssh-create.sh {username} {password} {days} >/dev/null 2>&1")
    elif protocol == 'vmess':
        os.system(f"/usr/local/sbin/tunneling/vmess-create.sh {username} {days} >/dev/null 2>&1")
    elif protocol == 'vless':
        os.system(f"/usr/local/sbin/tunneling/vless-create.sh {username} {days} >/dev/null 2>&1")
    elif protocol == 'trojan':
        os.system(f"/usr/local/sbin/tunneling/trojan-create.sh {username} {password} {days} >/dev/null 2>&1")
    
    # Update order
    order['status'] = 'approved'
    order['username'] = username
    order['approved_at'] = datetime.now().isoformat()
    with open(order_file, 'w') as f:
        json.dump(order, f, indent=2)
    
    # Get domain
    domain = 'your-domain.com'
    if os.path.exists('/root/domain.txt'):
        with open('/root/domain.txt', 'r') as f:
            domain = f.read().strip()
    
    # Send to user
    pkg_info = PRICES[order['package']]
    user_text = f"""
✅ *PAYMENT APPROVED*

Your order has been approved!

📦 Package: {pkg_info['name']}
🔐 Protocol: {protocol.upper()}
👤 Username: `{username}`
🔑 Password: `{password if protocol in ['ssh', 'trojan'] else 'N/A (UUID-based)'}`
🌐 Domain: `{domain}`
⏰ Expired: {days} Days

Thank you for your order! 🎉
    """
    
    try:
        bot.send_message(order['user_id'], user_text, parse_mode='Markdown')
        bot.answer_callback_query(call.id, "✅ Order approved!")
        bot.send_message(call.message.chat.id, f"✅ Order {order_id} approved and sent to user!")
    except Exception as e:
        bot.send_message(call.message.chat.id, f"✅ Approved but failed to notify user: {str(e)}")

# Admin Manage Users
@bot.message_handler(func=lambda message: message.text == '👥 Manage Users')
def manage_users(message):
    if message.from_user.id != ADMIN_ID:
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    markup = types.InlineKeyboardMarkup(row_width=2)
    btn1 = types.InlineKeyboardButton("SSH Users", callback_data="users_ssh")
    btn2 = types.InlineKeyboardButton("VMESS Users", callback_data="users_vmess")
    btn3 = types.InlineKeyboardButton("VLESS Users", callback_data="users_vless")
    btn4 = types.InlineKeyboardButton("TROJAN Users", callback_data="users_trojan")
    markup.add(btn1, btn2, btn3, btn4)
    
    bot.send_message(
        message.chat.id,
        "👥 *MANAGE USERS*\n\nSelect protocol:",
        parse_mode='Markdown',
        reply_markup=markup
    )

# Admin Settings
@bot.message_handler(func=lambda message: message.text == '⚙️ Settings')
def admin_settings(message):
    if message.from_user.id != ADMIN_ID:
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    # Get current config
    auto_approve = config.get('auto_approve', False)
    trial_enabled = config.get('trial_enabled', True)
    
    settings_text = f"""
⚙️ *BOT SETTINGS*

*Current Configuration:*
• Auto Approve Orders: {"✅ ON" if auto_approve else "❌ OFF"}
• Trial Accounts: {"✅ Enabled" if trial_enabled else "❌ Disabled"}
• Admin ID: `{ADMIN_ID}`

Use buttons below to toggle settings:
    """
    
    markup = types.InlineKeyboardMarkup()
    btn1 = types.InlineKeyboardButton(
        f"Auto Approve: {'✅' if auto_approve else '❌'}",
        callback_data="toggle_auto_approve"
    )
    btn2 = types.InlineKeyboardButton(
        f"Trial Accounts: {'✅' if trial_enabled else '❌'}",
        callback_data="toggle_trial"
    )
    btn3 = types.InlineKeyboardButton("💳 Payment Settings", callback_data="payment_settings")
    btn4 = types.InlineKeyboardButton("💰 Edit Price List", callback_data="edit_prices")
    markup.add(btn1)
    markup.add(btn2)
    markup.add(btn3, btn4)
    
    bot.send_message(message.chat.id, settings_text, parse_mode='Markdown', reply_markup=markup)

# Handle settings callbacks
@bot.callback_query_handler(func=lambda call: call.data == 'toggle_auto_approve')
def toggle_auto_approve(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    config['auto_approve'] = not config.get('auto_approve', False)
    
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)
    
    bot.answer_callback_query(call.id, f"Auto approve: {'ON' if config['auto_approve'] else 'OFF'}")
    
    # Update settings display
    auto_approve = config.get('auto_approve', False)
    trial_enabled = config.get('trial_enabled', True)
    
    settings_text = f"""
⚙️ *BOT SETTINGS*

*Current Configuration:*
• Auto Approve Orders: {"✅ ON" if auto_approve else "❌ OFF"}
• Trial Accounts: {"✅ Enabled" if trial_enabled else "❌ Disabled"}
• Admin ID: `{ADMIN_ID}`

Use buttons below to toggle settings:
    """
    
    markup = types.InlineKeyboardMarkup()
    btn1 = types.InlineKeyboardButton(
        f"Auto Approve: {'✅' if auto_approve else '❌'}",
        callback_data="toggle_auto_approve"
    )
    btn2 = types.InlineKeyboardButton(
        f"Trial Accounts: {'✅' if trial_enabled else '❌'}",
        callback_data="toggle_trial"
    )
    btn3 = types.InlineKeyboardButton("💳 Payment Settings", callback_data="payment_settings")
    btn4 = types.InlineKeyboardButton("💰 Edit Price List", callback_data="edit_prices")
    markup.add(btn1)
    markup.add(btn2)
    markup.add(btn3, btn4)
    
    bot.edit_message_text(
        settings_text,
        call.message.chat.id,
        call.message.message_id,
        parse_mode='Markdown',
        reply_markup=markup
    )

@bot.callback_query_handler(func=lambda call: call.data == 'toggle_trial')
def toggle_trial(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    config['trial_enabled'] = not config.get('trial_enabled', True)
    
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)
    
    bot.answer_callback_query(call.id, f"Trial accounts: {'Enabled' if config['trial_enabled'] else 'Disabled'}")
    
    # Update settings display
    auto_approve = config.get('auto_approve', False)
    trial_enabled = config.get('trial_enabled', True)
    
    settings_text = f"""
⚙️ *BOT SETTINGS*

*Current Configuration:*
• Auto Approve Orders: {"✅ ON" if auto_approve else "❌ OFF"}
• Trial Accounts: {"✅ Enabled" if trial_enabled else "❌ Disabled"}
• Admin ID: `{ADMIN_ID}`

Use buttons below to toggle settings:
    """
    
    markup = types.InlineKeyboardMarkup()
    btn1 = types.InlineKeyboardButton(
        f"Auto Approve: {'✅' if auto_approve else '❌'}",
        callback_data="toggle_auto_approve"
    )
    btn2 = types.InlineKeyboardButton(
        f"Trial Accounts: {'✅' if trial_enabled else '❌'}",
        callback_data="toggle_trial"
    )
    btn3 = types.InlineKeyboardButton("💳 Payment Settings", callback_data="payment_settings")
    btn4 = types.InlineKeyboardButton("💰 Edit Price List", callback_data="edit_prices")
    markup.add(btn1)
    markup.add(btn2)
    markup.add(btn3, btn4)
    
    bot.edit_message_text(
        settings_text,
        call.message.chat.id,
        call.message.message_id,
        parse_mode='Markdown',
        reply_markup=markup
    )

# Admin Create Account
@bot.message_handler(func=lambda message: message.text == '📦 Create Account')
def create_account_menu(message):
    if message.from_user.id != ADMIN_ID:
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    markup = types.InlineKeyboardMarkup(row_width=2)
    btn1 = types.InlineKeyboardButton("SSH Account", callback_data="create_ssh")
    btn2 = types.InlineKeyboardButton("VMESS Account", callback_data="create_vmess")
    btn3 = types.InlineKeyboardButton("VLESS Account", callback_data="create_vless")
    btn4 = types.InlineKeyboardButton("TROJAN Account", callback_data="create_trojan")
    markup.add(btn1, btn2, btn3, btn4)
    
    bot.send_message(
        message.chat.id,
        "📦 *CREATE ACCOUNT*\n\nSelect protocol:",
        parse_mode='Markdown',
        reply_markup=markup
    )

# Admin Statistics
@bot.message_handler(func=lambda message: message.text == '📈 Statistics')
def admin_statistics(message):
    if message.from_user.id != ADMIN_ID:
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    # Count total accounts
    ssh_count = len([f for f in os.listdir('/etc/tunneling/ssh') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/ssh') else 0
    vmess_count = len([f for f in os.listdir('/etc/tunneling/vmess') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/vmess') else 0
    vless_count = len([f for f in os.listdir('/etc/tunneling/vless') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/vless') else 0
    trojan_count = len([f for f in os.listdir('/etc/tunneling/trojan') if f.endswith('.json')]) if os.path.exists('/etc/tunneling/trojan') else 0
    
    # Count orders
    orders_dir = '/etc/tunneling/bot/orders'
    total_orders = 0
    pending_orders = 0
    approved_orders = 0
    total_revenue = 0
    
    if os.path.exists(orders_dir):
        for f in os.listdir(orders_dir):
            if f.endswith('.json'):
                with open(f'{orders_dir}/{f}', 'r') as file:
                    order = json.load(file)
                    total_orders += 1
                    if order['status'] == 'pending':
                        pending_orders += 1
                    elif order['status'] == 'approved':
                        approved_orders += 1
                        total_revenue += order['price']
    
    stats_text = f"""
📈 *STATISTICS*

*Active Accounts:*
• SSH: {ssh_count}
• VMESS: {vmess_count}
• VLESS: {vless_count}
• TROJAN: {trojan_count}
• Total: {ssh_count + vmess_count + vless_count + trojan_count}

*Orders:*
• Total Orders: {total_orders}
• Pending: {pending_orders}
• Approved: {approved_orders}

*Revenue:*
• Total: Rp{total_revenue:,}
    """
    
    bot.send_message(message.chat.id, stats_text, parse_mode='Markdown')

# Admin Broadcast
@bot.message_handler(func=lambda message: message.text == '🔔 Broadcast')
def broadcast_menu(message):
    if message.from_user.id != ADMIN_ID:
        bot.send_message(message.chat.id, "⛔️ Access denied!")
        return
    
    msg = bot.send_message(
        message.chat.id,
        "🔔 *BROADCAST MESSAGE*\n\nSend the message you want to broadcast to all users:",
        parse_mode='Markdown'
    )
    bot.register_next_step_handler(msg, broadcast_process)

def broadcast_process(message):
    if message.from_user.id != ADMIN_ID:
        return
    
    broadcast_text = message.text
    
    # Get all user IDs from orders
    user_ids = set()
    orders_dir = '/etc/tunneling/bot/orders'
    
    if os.path.exists(orders_dir):
        for f in os.listdir(orders_dir):
            if f.endswith('.json'):
                with open(f'{orders_dir}/{f}', 'r') as file:
                    order = json.load(file)
                    user_ids.add(order['user_id'])
    
    success = 0
    failed = 0
    
    bot.send_message(message.chat.id, f"📤 Broadcasting to {len(user_ids)} users...")
    
    for user_id in user_ids:
        try:
            bot.send_message(user_id, f"📢 *ANNOUNCEMENT*\n\n{broadcast_text}", parse_mode='Markdown')
            success += 1
        except:
            failed += 1
    
    bot.send_message(
        message.chat.id,
        f"✅ Broadcast complete!\n\nSuccess: {success}\nFailed: {failed}"
    )

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
    if message.from_user.id != ADMIN_ID:
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
