#!/bin/bash

# Setup UDP Custom / BadVPN (Compile from Source or Use Pre-compiled Binary)

# Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}      BadVPN UDPGW Installation Menu     ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Choose installation method:${NC}"
echo ""
echo -e "${BLUE}1.${NC} Compile from source (Latest, requires build tools)"
echo -e "${BLUE}2.${NC} Use pre-compiled binary from bin folder (Faster)"
echo ""
echo -e "${YELLOW}Auto-selecting option 2 in 10 seconds if no input...${NC}"

# Read with timeout - if timeout or empty, default to 2
choice=""
read -t 10 -p "Enter your choice [1-2] (default: 2): " choice 2>/dev/null || choice="2"

# If still empty, default to 2  
if [ -z "$choice" ]; then
    choice=2
    echo ""
    echo -e "${CYAN}[INFO]${NC} No input received, using default option 2 (pre-compiled binary)"
fi

case $choice in
    1)
        echo -e "${CYAN}[INFO]${NC} Starting compilation from source..."
        echo ""
        
        # Install build dependencies if missing
        echo -e "${CYAN}[INFO]${NC} Installing build dependencies..."
        apt-get install -y cmake build-essential git

        # Create temporary build directory
        mkdir -p /tmp/badvpn-build
        cd /tmp/badvpn-build

        # Download source code
        echo -e "${CYAN}[INFO]${NC} Downloading source code..."
        rm -rf badvpn
        git clone https://github.com/ambrop72/badvpn.git

        # Build
        echo -e "${CYAN}[INFO]${NC} Compiling BadVPN (This may take a minute)..."
        cd badvpn
        mkdir build
        cd build
        cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
        make

        # Install binary
        if [ -f "udpgw/badvpn-udpgw" ]; then
            echo -e "${GREEN}[SUCCESS]${NC} Compilation successful!"
            cp udpgw/badvpn-udpgw /usr/bin/badvpn-udpgw
            chmod +x /usr/bin/badvpn-udpgw
        else
            echo -e "${RED}[ERROR]${NC} Compilation failed! Please try option 2 (pre-compiled)."
            exit 1
        fi

        # Clean up
        cd /root
        rm -rf /tmp/badvpn-build
        ;;
    2)
        echo -e "${CYAN}[INFO]${NC} Using pre-compiled binary from bin folder..."
        
        # Get the directory where this script is located (relative to INSTALL_DIR)
        # For online installer, we'll download from GitHub bin folder
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        
        # Try local bin first (if running from cloned repo)
        if [ -f "$SCRIPT_DIR/../bin/badvpn-udpgw" ]; then
            echo -e "${CYAN}[INFO]${NC} Found local binary, copying..."
            cp "$SCRIPT_DIR/../bin/badvpn-udpgw" /usr/bin/badvpn-udpgw
            chmod +x /usr/bin/badvpn-udpgw
            echo -e "${GREEN}[SUCCESS]${NC} Binary copied successfully!"
        else
            echo -e "${CYAN}[INFO]${NC} Downloading pre-compiled binary from GitHub..."
            wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/Muzakie-ID/auto-script-tunneling-v2/main/bin/badvpn-udpgw"
            chmod +x /usr/bin/badvpn-udpgw
            echo -e "${GREEN}[SUCCESS]${NC} Binary downloaded successfully!"
        fi
        ;;
    *)
        echo -e "${RED}[ERROR]${NC} Invalid choice! Please enter 1 or 2."
        exit 1
        ;;
esac

echo ""

echo ""

# Create BadVPN Service
cat > /etc/systemd/system/badvpn.service << EOF
[Unit]
Description=BadVPN UDP Gateway
Documentation=https://github.com/ambrop72/badvpn
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable & Start Service
systemctl daemon-reload
systemctl enable badvpn
systemctl start badvpn

echo -e "${GREEN}[SUCCESS]${NC} BadVPN UDP Gateway installed and running on port 7300"
echo ""
