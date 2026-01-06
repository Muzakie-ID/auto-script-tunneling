#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_FILE="/etc/tunneling/bot/config.json"

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}              TEST BOT TELEGRAM                    ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Bot not configured yet!${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    /usr/local/sbin/tunneling/bot-menu.sh
    exit 1
fi

# Check if bot is running
if ! systemctl is-active --quiet telegram-bot; then
    echo -e "${RED}Bot is not running!${NC}"
    echo -e "${YELLOW}Please start the bot first (option 2)${NC}"
    echo ""
    read -p "Press [Enter] to continue..."
    /usr/local/sbin/tunneling/bot-menu.sh
    exit 1
fi

# Get bot info
TOKEN=$(jq -r '.token' $CONFIG_FILE)
ADMIN_ID=$(jq -r '.admin_id' $CONFIG_FILE)

echo -e "${YELLOW}Testing bot configuration...${NC}"
echo ""

# Test 1: Check bot token
echo -e "${CYAN}[1/3] Testing bot token...${NC}"
BOT_INFO=$(curl -s "https://api.telegram.org/bot${TOKEN}/getMe")
BOT_USERNAME=$(echo $BOT_INFO | jq -r '.result.username // "error"')

if [ "$BOT_USERNAME" != "error" ]; then
    echo -e "${GREEN}✓ Bot token valid${NC}"
    echo -e "  Bot username: @$BOT_USERNAME"
else
    echo -e "${RED}✗ Invalid bot token${NC}"
fi

echo ""

# Test 2: Send test message
echo -e "${CYAN}[2/3] Sending test message to admin...${NC}"
TEST_MESSAGE="🧪 *Test Message*%0A%0ABot is working correctly!%0A%0ATime: $(date '+%Y-%m-%d %H:%M:%S')"
SEND_RESULT=$(curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${ADMIN_ID}&text=${TEST_MESSAGE}&parse_mode=Markdown")
SEND_OK=$(echo $SEND_RESULT | jq -r '.ok')

if [ "$SEND_OK" == "true" ]; then
    echo -e "${GREEN}✓ Test message sent successfully${NC}"
    echo -e "  Check your Telegram for the message"
else
    echo -e "${RED}✗ Failed to send message${NC}"
    ERROR_DESC=$(echo $SEND_RESULT | jq -r '.description')
    echo -e "  Error: $ERROR_DESC"
fi

echo ""

# Test 3: Check bot status
echo -e "${CYAN}[3/3] Checking bot process...${NC}"
if pgrep -f "telegram_bot.py" > /dev/null; then
    echo -e "${GREEN}✓ Bot process is running${NC}"
    PID=$(pgrep -f "telegram_bot.py")
    echo -e "  PID: $PID"
else
    echo -e "${RED}✗ Bot process not found${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Test completed!${NC}"
echo ""
echo -e "${YELLOW}If bot is not responding:${NC}"
echo "1. Check bot logs: journalctl -u telegram-bot -f"
echo "2. Restart bot: Select option 4 (Restart Bot)"
echo "3. Reconfigure: Select option 1 (Setup Bot)"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "Press [Enter] to continue..."
/usr/local/sbin/tunneling/bot-menu.sh
