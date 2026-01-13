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
    
    # Send message first to get message_id
    sent_msg = bot.send_message(
        message.chat.id,
        f"📋 *PENDING ORDERS* ({len(pending)})\n\nClick to approve:",
        parse_mode='Markdown'
    )
    
    # Build buttons with message_id in callback data
    for order in pending:
        pkg_info = PRICES.get(order['package'], {})
        btn = types.InlineKeyboardButton(
            f"Order {order['order_id']} - {pkg_info.get('name', 'Unknown')} - Rp{order['price']:,}",
            callback_data=f"approve_{order['order_id']}_msg{sent_msg.message_id}"
        )
        markup.add(btn)
    
    # Edit message to add buttons
    bot.edit_message_reply_markup(
        chat_id=message.chat.id,
        message_id=sent_msg.message_id,
        reply_markup=markup
    )

# Handle approve callback
@bot.callback_query_handler(func=lambda call: call.data.startswith('approve_'))
def handle_approve(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    # Extract order_id and list_message_id from callback data
    callback_parts = call.data.replace('approve_', '').split('_msg')
    order_id = callback_parts[0]
    list_message_id = int(callback_parts[1]) if len(callback_parts) > 1 else None
    
    # Check if this is from payment proof (message has photo or caption with "BUKTI PEMBAYARAN")
    is_payment_proof = False
    if call.message.photo:
        is_payment_proof = True
    elif call.message.caption and "BUKTI PEMBAYARAN" in call.message.caption:
        is_payment_proof = True
    
    if is_payment_proof:
        # Direct approve from payment proof notification - no confirmation needed
        bot.answer_callback_query(call.id, "Processing...")
        confirm_approve_order(call)
        return
    
    # Otherwise, ask for confirmation
    markup = types.InlineKeyboardMarkup(row_width=2)
    btn_yes = types.InlineKeyboardButton("✅ Approve", callback_data=f"confirm_approve_{order_id}_msg{list_message_id if list_message_id else ''}")
    btn_no = types.InlineKeyboardButton("❌ Reject", callback_data=f"reject_{order_id}_msg{list_message_id if list_message_id else ''}")
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
    
    # Extract order_id and list_message_id from callback data
    # Format: confirm_approve_{order_id}_msg{list_message_id} or approve_{order_id}
    callback_data = call.data.replace('confirm_approve_', '').replace('approve_', '')
    callback_parts = callback_data.split('_msg')
    order_id = callback_parts[0]
    
    order_file = f'/etc/tunneling/bot/orders/{order_id}.json'
    
    if not os.path.exists(order_file):
        bot.answer_callback_query(call.id, "❌ Order not found!")
        return
    
    with open(order_file, 'r') as f:
        order = json.load(f)
    
    # Create account
    import random
    import string
    import uuid as uuid_lib
    import base64
    
    username = f"user{''.join(random.choices(string.ascii_lowercase + string.digits, k=6))}"
    password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
    
    protocol = order['type']
    days = order['days']
    
    # Call create script with correct paths
    if protocol == 'ssh':
        os.system(f"bash /usr/local/sbin/tunneling/ssh/ssh-create.sh {username} {password} {days} >/dev/null 2>&1")
    elif protocol == 'vmess':
        os.system(f"echo '{username}\n{days}' | bash /usr/local/sbin/tunneling/xray/vmess-create.sh")
    elif protocol == 'vless':
        os.system(f"echo '{username}\n{days}' | bash /usr/local/sbin/tunneling/xray/vless-create.sh")
    elif protocol == 'trojan':
        os.system(f"echo '{username}\n{days}' | bash /usr/local/sbin/tunneling/xray/trojan-create.sh")
    
    # Read account details from JSON
    account_data = {}
    if protocol in ['vmess', 'vless', 'trojan']:
        account_file = f'/etc/tunneling/{protocol}/{username}.json'
        if os.path.exists(account_file):
            with open(account_file, 'r') as f:
                account_data = json.load(f)
    
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
    elif os.path.exists('/etc/xray/domain'):
        with open('/etc/xray/domain', 'r') as f:
            domain = f.read().strip()
    
    # Build user message based on protocol
    pkg_info = PRICES[order['package']]
    
    if protocol == 'ssh':
        user_text = f"""
✅ *PESANAN DISETUJUI*

Pesanan Anda telah disetujui!

📦 Paket: {pkg_info['name']}
🔐 Protokol: SSH/OpenVPN
👤 Username: `{username}`
🔑 Password: `{password}`
🌐 Domain: `{domain}`
⏰ Expired: {days} Hari

*Port SSH:*
• OpenSSH: 22
• Dropbear: 109, 143
• SSL/TLS: 442, 443
• Squid Proxy: 3128, 8080

*WebSocket:*
• WS HTTP: `ws://{domain}:80/ssh`
• WS HTTPS: `wss://{domain}:443/ssh`

*Payload Config:*
```
GET / HTTP/1.1[crlf]Host: {domain}[crlf]Upgrade: websocket[crlf][crlf]
```

Terima kasih! 🎉
        """
    
    elif protocol == 'vmess':
        uuid = account_data.get('uuid', 'N/A')
        
        # Generate vmess:// links
        # Port 443 with TLS
        vmess_config_tls = {
            "v": "2",
            "ps": f"{username}-TLS",
            "add": domain,
            "port": "443",
            "id": uuid,
            "aid": "0",
            "net": "ws",
            "path": "/vmess",
            "type": "none",
            "host": domain,
            "tls": "tls"
        }
        vmess_link_tls = "vmess://" + base64.b64encode(json.dumps(vmess_config_tls).encode()).decode()
        
        # Port 80 without TLS
        vmess_config_80 = {
            "v": "2",
            "ps": f"{username}-HTTP",
            "add": domain,
            "port": "80",
            "id": uuid,
            "aid": "0",
            "net": "ws",
            "path": "/vmess",
            "type": "none",
            "host": domain,
            "tls": ""
        }
        vmess_link_80 = "vmess://" + base64.b64encode(json.dumps(vmess_config_80).encode()).decode()
        
        user_text = f"""
✅ *PESANAN DISETUJUI*

Pesanan Anda telah disetujui!

📦 Paket: {pkg_info['name']}
🔐 Protokol: VMESS
👤 Username: `{username}`
🆔 UUID: `{uuid}`
🌐 Domain: `{domain}`
⏰ Expired: {days} Hari

*Detail Koneksi:*
• Address: `{domain}`
• Port: 443 (TLS) / 80 (HTTP)
• ID/UUID: `{uuid}`
• AlterID: 0
• Security: auto
• Network: WebSocket
• Path: `/vmess`

*🔐 Port 443 (TLS - Recommended):*
```
{vmess_link_tls}
```

*🌐 Port 80 (HTTP - Bypass):*
```
{vmess_link_80}
```

📝 Copy salah satu link di atas ke aplikasi V2RayNG/V2RayN/Clash!

Terima kasih! 🎉
        """
    
    elif protocol == 'vless':
        uuid = account_data.get('uuid', 'N/A')
        
        # Generate vless:// links
        # Port 443 with TLS
        vless_link_tls = f"vless://{uuid}@{domain}:443?path=%2Fvless&security=tls&encryption=none&type=ws&host={domain}&sni={domain}#{username}-TLS"
        
        # Port 80 without TLS
        vless_link_80 = f"vless://{uuid}@{domain}:80?path=%2Fvless&security=none&encryption=none&type=ws&host={domain}#{username}-HTTP"
        
        user_text = f"""
✅ *PESANAN DISETUJUI*

Pesanan Anda telah disetujui!

📦 Paket: {pkg_info['name']}
🔐 Protokol: VLESS
👤 Username: `{username}`
🆔 UUID: `{uuid}`
🌐 Domain: `{domain}`
⏰ Expired: {days} Hari

*Detail Koneksi:*
• Address: `{domain}`
• Port: 443 (TLS) / 80 (HTTP)
• ID/UUID: `{uuid}`
• Encryption: none
• Network: WebSocket
• Path: `/vless`

*🔐 Port 443 (TLS - Recommended):*
```
{vless_link_tls}
```

*🌐 Port 80 (HTTP - Bypass):*
```
{vless_link_80}
```

📝 Copy salah satu link di atas ke aplikasi V2RayNG/V2RayN/Clash!

Terima kasih! 🎉
        """
    
    elif protocol == 'trojan':
        trojan_password = account_data.get('password', password)
        
        # Generate trojan:// links
        # Port 443 with TLS
        trojan_link_tls = f"trojan://{trojan_password}@{domain}:443?security=tls&type=ws&host={domain}&path=/trojan&sni={domain}#{username}-TLS"
        
        # Port 80 without TLS
        trojan_link_80 = f"trojan://{trojan_password}@{domain}:80?security=none&type=ws&host={domain}&path=/trojan#{username}-HTTP"
        
        user_text = f"""
✅ *PESANAN DISETUJUI*

Pesanan Anda telah disetujui!

📦 Paket: {pkg_info['name']}
🔐 Protokol: TROJAN
👤 Username: `{username}`
🔑 Password: `{trojan_password}`
🌐 Domain: `{domain}`
⏰ Expired: {days} Hari

*Detail Koneksi:*
• Address: `{domain}`
• Port: 443 (TLS) / 80 (HTTP)
• Password: `{trojan_password}`
• Network: WebSocket
• Path: `/trojan`

*🔐 Port 443 (TLS - Recommended):*
```
{trojan_link_tls}
```

*🌐 Port 80 (HTTP - Bypass):*
```
{trojan_link_80}
```

📝 Copy salah satu link di atas ke aplikasi V2RayNG/V2RayN/Clash!

Terima kasih! 🎉
        """
    else:
        user_text = f"""
✅ *PAYMENT APPROVED*

Your order has been approved!

📦 Package: {pkg_info['name']}
🔐 Protocol: {protocol.upper()}
👤 Username: `{username}`
🔑 Password: `{password}`
🌐 Domain: `{domain}`
⏰ Expired: {days} Days

Thank you for your order! 🎉
        """
    
    try:
        bot.send_message(order['user_id'], user_text, parse_mode='Markdown')
        bot.answer_callback_query(call.id, "✅ Order approved!")
        
        # Edit payment proof message to remove buttons and update status
        if 'payment_notification_msg_id' in order:
            try:
                pkg_info = PRICES.get(order['package'], {})
                updated_caption = f"""
💸 *BUKTI PEMBAYARAN DITERIMA*

Order ID: `{order_id}`
User: @{order.get('username_telegram', 'N/A')}
Package: {pkg_info.get('name', 'Unknown')}
Price: Rp{order['price']:,}

✅ *STATUS: APPROVED*
Approved at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
                """
                bot.edit_message_caption(
                    caption=updated_caption,
                    chat_id=ADMIN_ID,
                    message_id=order['payment_notification_msg_id'],
                    parse_mode='Markdown',
                    reply_markup=None
                )
            except Exception as edit_err:
                # If edit fails, try to delete the message
                try:
                    bot.delete_message(ADMIN_ID, order['payment_notification_msg_id'])
                except:
                    pass
        
        # Delete confirmation message
        try:
            bot.delete_message(call.message.chat.id, call.message.message_id)
        except:
            pass
        
        # Update pending orders list message if available
        callback_parts = call.data.replace('confirm_approve_', '').split('_msg')
        if len(callback_parts) > 1 and callback_parts[1]:
            list_message_id = int(callback_parts[1])
            try:
                # Refresh the pending orders list
                orders_dir = '/etc/tunneling/bot/orders'
                pending = []
                if os.path.exists(orders_dir):
                    for f in os.listdir(orders_dir):
                        if f.endswith('.json'):
                            with open(f'{orders_dir}/{f}', 'r') as file:
                                ord_data = json.load(file)
                                if ord_data['status'] == 'pending':
                                    pending.append(ord_data)
                
                if pending:
                    # Rebuild buttons for remaining pending orders
                    markup = types.InlineKeyboardMarkup()
                    for pending_order in pending:
                        pkg_info = PRICES.get(pending_order['package'], {})
                        btn = types.InlineKeyboardButton(
                            f"Order {pending_order['order_id']} - {pkg_info.get('name', 'Unknown')} - Rp{pending_order['price']:,}",
                            callback_data=f"approve_{pending_order['order_id']}_msg{list_message_id}"
                        )
                        markup.add(btn)
                    
                    bot.edit_message_text(
                        f"📋 *PENDING ORDERS* ({len(pending)})\n\nClick to approve:",
                        chat_id=ADMIN_ID,
                        message_id=list_message_id,
                        parse_mode='Markdown',
                        reply_markup=markup
                    )
                else:
                    # No more pending orders
                    bot.edit_message_text(
                        "✅ *ALL ORDERS PROCESSED*\n\nNo pending orders.",
                        chat_id=ADMIN_ID,
                        message_id=list_message_id,
                        parse_mode='Markdown',
                        reply_markup=None
                    )
            except Exception as list_err:
                # If can't update list, just inform admin
                bot.send_message(ADMIN_ID, f"✅ Order {order_id} approved. (List not updated: {str(list_err)})")
                return
        
        # Send success message
        bot.send_message(ADMIN_ID, f"✅ Order {order_id} approved and sent to user!")
    except Exception as e:
        bot.answer_callback_query(call.id, "❌ Failed!")
        bot.send_message(ADMIN_ID, f"❌ Failed to send to user: {str(e)}")

# Reject order
@bot.callback_query_handler(func=lambda call: call.data.startswith('reject_'))
def reject_order(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    # Extract order_id from callback data
    # Format: reject_{order_id}_msg{list_message_id}
    callback_data = call.data.replace('reject_', '')
    callback_parts = callback_data.split('_msg')
    order_id = callback_parts[0]
    
    order_file = f'/etc/tunneling/bot/orders/{order_id}.json'
    
    if not os.path.exists(order_file):
        bot.answer_callback_query(call.id, "❌ Order not found!")
        return
    
    with open(order_file, 'r') as f:
        order = json.load(f)
    
    # Update order status
    order['status'] = 'rejected'
    order['rejected_at'] = datetime.now().isoformat()
    with open(order_file, 'w') as f:
        json.dump(order, f, indent=2)
    
    # Notify user
    try:
        bot.send_message(
            order['user_id'],
            "❌ *ORDER REJECTED*\n\nYour order has been rejected. Please contact admin for more information.",
            parse_mode='Markdown'
        )
    except:
        pass
    
    # Edit payment proof message to remove buttons and update status
    if 'payment_notification_msg_id' in order:
        try:
            pkg_info = PRICES.get(order['package'], {})
            updated_caption = f"""
💸 *BUKTI PEMBAYARAN DITERIMA*

Order ID: `{order_id}`
User: @{order.get('username_telegram', 'N/A')}
Package: {pkg_info.get('name', 'Unknown')}
Price: Rp{order['price']:,}

❌ *STATUS: REJECTED*
Rejected at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
            """
            bot.edit_message_caption(
                caption=updated_caption,
                chat_id=ADMIN_ID,
                message_id=order['payment_notification_msg_id'],
                parse_mode='Markdown',
                reply_markup=None
            )
        except Exception as edit_err:
            # If edit fails, try to delete the message
            try:
                bot.delete_message(ADMIN_ID, order['payment_notification_msg_id'])
            except:
                pass
    
    # Delete confirmation message
    try:
        bot.delete_message(call.message.chat.id, call.message.message_id)
    except:
        pass
    
    # Update pending orders list message if available
    if len(callback_parts) > 1 and callback_parts[1]:
        list_message_id = int(callback_parts[1])
        try:
            # Refresh the pending orders list
            orders_dir = '/etc/tunneling/bot/orders'
            pending = []
            if os.path.exists(orders_dir):
                for f in os.listdir(orders_dir):
                    if f.endswith('.json'):
                        with open(f'{orders_dir}/{f}', 'r') as file:
                            ord_data = json.load(file)
                            if ord_data['status'] == 'pending':
                                pending.append(ord_data)
            
            if pending:
                # Rebuild buttons for remaining pending orders
                markup = types.InlineKeyboardMarkup()
                for pending_order in pending:
                    pkg_info = PRICES.get(pending_order['package'], {})
                    btn = types.InlineKeyboardButton(
                        f"Order {pending_order['order_id']} - {pkg_info.get('name', 'Unknown')} - Rp{pending_order['price']:,}",
                        callback_data=f"approve_{pending_order['order_id']}_msg{list_message_id}"
                    )
                    markup.add(btn)
                
                bot.edit_message_text(
                    f"📋 *PENDING ORDERS* ({len(pending)})\n\nClick to approve:",
                    chat_id=ADMIN_ID,
                    message_id=list_message_id,
                    parse_mode='Markdown',
                    reply_markup=markup
                )
            else:
                # No more pending orders
                bot.edit_message_text(
                    "✅ *ALL ORDERS PROCESSED*\n\nNo pending orders.",
                    chat_id=ADMIN_ID,
                    message_id=list_message_id,
                    parse_mode='Markdown',
                    reply_markup=None
                )
        except Exception as list_err:
            # If can't update list, just inform admin
            bot.send_message(ADMIN_ID, f"❌ Order {order_id} rejected. (List not updated: {str(list_err)})")
            return
    
    bot.answer_callback_query(call.id, "❌ Order rejected!")
    bot.send_message(ADMIN_ID, f"❌ Order {order_id} rejected.")

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

# Handle payment settings callback
@bot.callback_query_handler(func=lambda call: call.data == 'payment_settings')
def payment_settings(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    bot.answer_callback_query(call.id)
    
    qris_path = '/etc/tunneling/bot/qris.jpg'
    qris_exists = os.path.exists(qris_path)
    
    payment_text = f"""
💳 *PAYMENT SETTINGS*

*QRIS Status:* {"✅ Uploaded" if qris_exists else "❌ Not uploaded"}

{"Current QRIS image:" if qris_exists else "No QRIS image yet. Please upload your QRIS payment image."}

Use buttons below to manage payment:
    """
    
    if qris_exists:
        with open(qris_path, 'rb') as photo:
            markup = types.InlineKeyboardMarkup()
            btn1 = types.InlineKeyboardButton("🔄 Replace QRIS", callback_data="upload_qris")
            btn2 = types.InlineKeyboardButton("🗑 Delete QRIS", callback_data="delete_qris")
            btn3 = types.InlineKeyboardButton("« Back", callback_data="back_to_settings")
            markup.add(btn1, btn2)
            markup.add(btn3)
            bot.send_photo(call.message.chat.id, photo, caption=payment_text, parse_mode='Markdown', reply_markup=markup)
    else:
        markup = types.InlineKeyboardMarkup()
        btn1 = types.InlineKeyboardButton("📤 Upload QRIS", callback_data="upload_qris")
        btn2 = types.InlineKeyboardButton("« Back", callback_data="back_to_settings")
        markup.add(btn1)
        markup.add(btn2)
        bot.send_message(call.message.chat.id, payment_text, parse_mode='Markdown', reply_markup=markup)

@bot.callback_query_handler(func=lambda call: call.data == 'upload_qris')
def upload_qris_prompt(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    bot.answer_callback_query(call.id)
    msg = bot.send_message(
        call.message.chat.id,
        "📤 *UPLOAD QRIS IMAGE*\n\nPlease send your QRIS payment image now:",
        parse_mode='Markdown'
    )
    bot.register_next_step_handler(msg, process_qris_upload)

def process_qris_upload(message):
    if message.from_user.id != ADMIN_ID:
        return
    
    if not message.photo:
        bot.send_message(message.chat.id, "❌ Please send an image file!")
        return
    
    # Download photo
    file_info = bot.get_file(message.photo[-1].file_id)
    downloaded_file = bot.download_file(file_info.file_path)
    
    # Save to bot directory
    qris_path = '/etc/tunneling/bot/qris.jpg'
    with open(qris_path, 'wb') as f:
        f.write(downloaded_file)
    
    bot.send_message(message.chat.id, "✅ QRIS image uploaded successfully!")

@bot.callback_query_handler(func=lambda call: call.data == 'delete_qris')
def delete_qris(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    qris_path = '/etc/tunneling/bot/qris.jpg'
    if os.path.exists(qris_path):
        os.remove(qris_path)
        bot.answer_callback_query(call.id, "QRIS deleted!")
        bot.send_message(call.message.chat.id, "✅ QRIS image deleted successfully!")
    else:
        bot.answer_callback_query(call.id, "No QRIS found!")

# Handle edit prices callback
@bot.callback_query_handler(func=lambda call: call.data == 'edit_prices')
def edit_prices_menu(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    bot.answer_callback_query(call.id)
    
    price_text = """
💰 *PRICE LIST*

Select package to edit:
    """
    
    markup = types.InlineKeyboardMarkup(row_width=1)
    for key, value in PRICES.items():
        btn = types.InlineKeyboardButton(
            f"{value['name']} - Rp{value['price']:,}",
            callback_data=f"editprice_{key}"
        )
        markup.add(btn)
    
    btn_back = types.InlineKeyboardButton("« Back", callback_data="back_to_settings")
    markup.add(btn_back)
    
    bot.send_message(call.message.chat.id, price_text, parse_mode='Markdown', reply_markup=markup)

@bot.callback_query_handler(func=lambda call: call.data.startswith('editprice_'))
def edit_price_prompt(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    package = call.data.replace('editprice_', '')
    pkg_info = PRICES[package]
    
    bot.answer_callback_query(call.id)
    msg = bot.send_message(
        call.message.chat.id,
        f"💰 *EDIT PRICE*\n\nPackage: {pkg_info['name']}\nCurrent Price: Rp{pkg_info['price']:,}\n\nSend new price (number only):",
        parse_mode='Markdown'
    )
    bot.register_next_step_handler(msg, lambda m: process_price_edit(m, package))

def process_price_edit(message, package):
    if message.from_user.id != ADMIN_ID:
        return
    
    try:
        new_price = int(message.text.strip())
        PRICES[package]['price'] = new_price
        
        # Save to config file (optional - you can save to a separate prices.json)
        bot.send_message(
            message.chat.id,
            f"✅ Price updated!\n\n{PRICES[package]['name']}: Rp{new_price:,}"
        )
    except ValueError:
        bot.send_message(message.chat.id, "❌ Invalid price! Please send numbers only.")

@bot.callback_query_handler(func=lambda call: call.data == 'back_to_settings')
def back_to_settings(call):
    if call.from_user.id != ADMIN_ID:
        bot.answer_callback_query(call.id, "⛔️ Access denied!")
        return
    
    bot.answer_callback_query(call.id)
    
    # Show settings menu again
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
    
    bot.send_message(call.message.chat.id, settings_text, parse_mode='Markdown', reply_markup=markup)

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
    btn = types.InlineKeyboardButton("💸 Upload Pembayaran", callback_data=f"proof_{order_id}")
    markup.add(btn)
    
    bot.send_message(
        call.message.chat.id,
        "💸 *UPLOAD BUKTI PEMBAYARAN*\n\nSetelah melakukan pembayaran, klik tombol di bawah untuk upload bukti transfer:",
        parse_mode='Markdown',
        reply_markup=markup
    )
    
    # Notify admin
    if ADMIN_ID:
        bot.send_message(
            ADMIN_ID,
            f"🆕 NEW ORDER\n\nOrder ID: {order_id}\nUser: @{call.from_user.username}\nPackage: {info['name']}\nPrice: Rp{info['price']:,}"
        )

# Handle upload proof callback
@bot.callback_query_handler(func=lambda call: call.data.startswith('proof_'))
def upload_proof_prompt(call):
    order_id = call.data.replace('proof_', '')
    
    bot.answer_callback_query(call.id)
    msg = bot.send_message(
        call.message.chat.id,
        "💸 *UPLOAD BUKTI PEMBAYARAN*\n\nSilakan kirim foto/gambar bukti transfer Anda sekarang:",
        parse_mode='Markdown'
    )
    bot.register_next_step_handler(msg, lambda m: process_payment_proof(m, order_id))

def process_payment_proof(message, order_id):
    if not message.photo:
        bot.send_message(message.chat.id, "❌ Mohon kirim gambar bukti pembayaran!")
        return
    
    order_file = f'/etc/tunneling/bot/orders/{order_id}.json'
    
    if not os.path.exists(order_file):
        bot.send_message(message.chat.id, "❌ Order tidak ditemukan!")
        return
    
    # Download photo
    file_info = bot.get_file(message.photo[-1].file_id)
    downloaded_file = bot.download_file(file_info.file_path)
    
    # Save proof
    proof_path = f'/etc/tunneling/bot/orders/{order_id}_proof.jpg'
    with open(proof_path, 'wb') as f:
        f.write(downloaded_file)
    
    # Update order
    with open(order_file, 'r') as f:
        order = json.load(f)
    
    order['proof_uploaded'] = True
    order['proof_path'] = proof_path
    order['proof_uploaded_at'] = datetime.now().isoformat()
    order['username_telegram'] = message.from_user.username if message.from_user.username else f"User{message.from_user.id}"
    
    with open(order_file, 'w') as f:
        json.dump(order, f, indent=2)
    
    bot.send_message(
        message.chat.id,
        "✅ *BUKTI PEMBAYARAN DITERIMA*\n\nTerima kasih! Bukti pembayaran Anda sudah kami terima.\nPesanan akan diproses segera oleh admin.",
        parse_mode='Markdown'
    )
    
    # Notify admin with proof
    if ADMIN_ID:
        pkg_info = PRICES.get(order['package'], {})
        admin_text = f"""
💸 *BUKTI PEMBAYARAN DITERIMA*

Order ID: `{order_id}`
User: @{message.from_user.username}
Package: {pkg_info.get('name', 'Unknown')}
Price: Rp{order['price']:,}

Bukti pembayaran:
        """
        
        try:
            with open(proof_path, 'rb') as photo:
                markup = types.InlineKeyboardMarkup()
                btn_approve = types.InlineKeyboardButton("✅ Approve", callback_data=f"approve_{order_id}")
                btn_reject = types.InlineKeyboardButton("❌ Reject", callback_data=f"reject_{order_id}")
                markup.add(btn_approve, btn_reject)
                
                sent_msg = bot.send_photo(
                    ADMIN_ID,
                    photo,
                    caption=admin_text,
                    parse_mode='Markdown',
                    reply_markup=markup
                )
                
                # Save message_id for later editing
                order['payment_notification_msg_id'] = sent_msg.message_id
                with open(order_file, 'w') as f:
                    json.dump(order, f, indent=2)
        except Exception as e:
            bot.send_message(ADMIN_ID, f"{admin_text}\nGagal mengirim foto: {str(e)}")

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
