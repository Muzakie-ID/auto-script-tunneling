#!/bin/bash

# NGINX Configuration for VPN Server

DOMAIN=$(cat /root/domain.txt)

# Backup existing config
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Main nginx config
cat > /etc/nginx/nginx.conf << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

# Create sites directory
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# VPN Site config
cat > /etc/nginx/sites-available/vpn << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN *.$DOMAIN;

    root /var/www/html;
    index index.html index.htm;

    # WebSocket for SSH (non-TLS)
    location /ssh {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    # WebSocket for VMESS (non-TLS)
    location /vmess {
        proxy_pass http://127.0.0.1:10001;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for VLESS (non-TLS)
    location /vless {
        proxy_pass http://127.0.0.1:10002;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for TROJAN (non-TLS)
    location /trojan {
        proxy_pass http://127.0.0.1:10003;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }


    # Serve HTML for browser access (including bug hosts)
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}

server {
    listen 89;
    listen [::]:89;
    server_name $DOMAIN *.$DOMAIN;
    root /var/www/html;
    index index.html index.htm;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN *.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/html;
    index index.html index.htm;

    # WebSocket for SSH
    location /ssh {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    # WebSocket for VMESS
    location /vmess {
        proxy_pass http://127.0.0.1:10001;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for VLESS
    location /vless {
        proxy_pass http://127.0.0.1:10002;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for TROJAN
    location /trojan {
        proxy_pass http://127.0.0.1:10003;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # Backup download
    location /backup {
        alias /etc/tunneling/backup;
        autoindex on;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    # Serve HTML for browser access (including bug hosts)
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Enable site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/vpn /etc/nginx/sites-enabled/

# Create empty htpasswd file to prevent nginx crash
touch /etc/nginx/.htpasswd

# Fetch server location
IP_DATA=$(curl -s http://ip-api.com/json/)
CITY=$(echo "$IP_DATA" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
COUNTRY=$(echo "$IP_DATA" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)

if [[ -n "$CITY" && -n "$COUNTRY" ]]; then
    SERVER_LOC="$CITY / $COUNTRY"
else
    SERVER_LOC="Unknown Location"
fi

# Create landing page
mkdir -p /var/www/html
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>VPN Dashboard - $DOMAIN</title>

    <!-- Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">

    <style>
        :root {
            /* Modern Light Theme Palette */
            --primary: #4f46e5;       /* Indigo */
            --primary-soft: #e0e7ff;
            --secondary: #64748b;     /* Slate */
            --success: #10b981;       /* Emerald */
            --bg-body: #f8fafc;       /* Very Light Gray */
            --card-bg: #ffffff;
            --text-main: #0f172a;     /* Slate 900 */
            --text-muted: #64748b;    /* Slate 500 */
            --border: #e2e8f0;

            /* Effects */
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
            --radius: 1rem;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-main);
            min-height: 100vh;
            /* Modern abstract background */
            background-image:
                radial-gradient(at 0% 0%, hsla(253,16%,7%,1) 0, transparent 50%),
                radial-gradient(at 50% 0%, hsla(225,39%,30%,1) 0, transparent 50%),
                radial-gradient(at 100% 0%, hsla(339,49%,30%,1) 0, transparent 50%);
            background-image:
                radial-gradient(at 40% 20%, hsla(228,100%,74%,0.1) 0px, transparent 50%),
                radial-gradient(at 80% 0%, hsla(189,100%,56%,0.1) 0px, transparent 50%),
                radial-gradient(at 0% 50%, hsla(340,100%,76%,0.05) 0px, transparent 50%);
            background-attachment: fixed;
            padding: 2rem;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            width: 100%;
        }

        /* --- Animations --- */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .animate-enter {
            animation: fadeUp 0.6s ease-out forwards;
            opacity: 0; /* Start hidden */
        }

        .delay-1 { animation-delay: 0.1s; }
        .delay-2 { animation-delay: 0.2s; }
        .delay-3 { animation-delay: 0.3s; }

        /* --- Header --- */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            padding: 1rem 1.5rem;
            border-radius: var(--radius);
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: var(--shadow-sm);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-main);
            letter-spacing: -0.5px;
        }
        .brand-icon {
            color: var(--primary);
            background: var(--primary-soft);
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 12px;
            font-size: 1.25rem;
        }

        .status-badge {
            background: #ecfdf5;
            color: var(--success);
            padding: 8px 16px;
            border-radius: 100px;
            font-size: 0.875rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1px solid #d1fae5;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
        }
        .status-dot { width: 8px; height: 8px; background: var(--success); border-radius: 50%; box-shadow: 0 0 8px var(--success); animation: pulse 2s infinite; }

        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }

        /* --- Stats Grid --- */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--card-bg);
            padding: 1.5rem;
            border-radius: var(--radius);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
            display: flex;
            flex-direction: column;
            gap: 10px;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-soft);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 4px; height: 100%;
            background: var(--primary);
            opacity: 0;
            transition: var(--transition);
        }
        .stat-card:hover::before { opacity: 1; }

        .stat-header { display: flex; align-items: center; justify-content: space-between; color: var(--text-muted); }
        .stat-icon { font-size: 1.25rem; background: var(--bg-body); padding: 8px; border-radius: 10px; }
        .stat-title { font-size: 0.875rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }

        .stat-body { display: flex; align-items: baseline; gap: 4px; }
        .stat-value { font-size: 2rem; font-weight: 700; color: var(--text-main); line-height: 1; }
        .stat-unit { font-size: 0.875rem; font-weight: 500; color: var(--text-muted); }

        /* --- Main Content --- */
        .dashboard-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 2rem;
        }

        .panel {
            background: var(--card-bg);
            border-radius: var(--radius);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
            padding: 2rem;
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .panel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.5rem;
        }
        .panel-title { font-size: 1.25rem; font-weight: 700; display: flex; align-items: center; gap: 10px; }
        .panel-title i { color: var(--primary); }

        /* Chart */
        .chart-wrapper {
            position: relative;
            height: 350px;
            width: 100%;
        }

        /* Info List */
        .info-list { display: flex; flex-direction: column; gap: 1rem; flex: 1; }
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 0;
            border-bottom: 1px dashed var(--border);
        }
        .info-row:last-child { border-bottom: none; }
        .info-label { color: var(--text-muted); display: flex; align-items: center; gap: 8px; font-size: 0.95rem; }
        .info-value { font-weight: 600; color: var(--text-main); font-size: 1rem; }

        /* Button */
        .btn-action {
            margin-top: 1.5rem;
            background: linear-gradient(135deg, var(--primary) 0%, #4338ca 100%);
            color: white;
            text-decoration: none;
            padding: 1rem;
            border-radius: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: var(--transition);
            box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.2);
        }
        .btn-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(79, 70, 229, 0.3);
        }
        .btn-action:active { transform: scale(0.98); }

        /* Footer */
        .footer {
            text-align: center;
            margin-top: 3rem;
            color: var(--text-muted);
            font-size: 0.875rem;
        }

        /* --- Responsive Design --- */
        @media (max-width: 1024px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .dashboard-layout { grid-template-columns: 1fr; }
        }

        @media (max-width: 640px) {
            body { padding: 1rem; padding-bottom: 3rem; }

            /* Enhanced Header for Mobile */
            .header {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
                align-items: stretch;
                padding: 1.25rem;
            }
            .brand { justify-content: center; width: 100%; }
            .status-badge { width: 100%; justify-content: center; }

            .stats-grid { grid-template-columns: 1fr; gap: 0.75rem; }

            /* Mobile Horizontal Stat Card Layout */
            .stat-card {
                flex-direction: row;
                align-items: center;
                justify-content: space-between;
                padding: 1rem 1.25rem;
                min-height: auto;
            }

            /* Keep accent border */
            .stat-card::before { width: 4px; }

            /* Reorganize Header: Icon left, Title right */
            .stat-header {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 0;
                justify-content: flex-start;
            }

            /* Move icon before title using order */
            .stat-icon {
                order: -1;
                font-size: 1.2rem;
                padding: 6px;
                background: rgba(79, 70, 229, 0.1);
                color: var(--primary);
                border-radius: 8px;
            }

            .stat-title {
                font-size: 0.95rem;
                font-weight: 600;
                color: var(--text-main);
                text-transform: none; /* easier to read */
            }

            /* Adjust Values to be right-aligned */
            .stat-body {
                flex-direction: row;
                align-items: baseline;
            }
            .stat-value { font-size: 1.25rem; }
            .stat-unit { font-size: 0.85rem; }

            .panel { padding: 1.25rem; }
            .chart-wrapper { height: 230px; }
            .footer { margin-top: 2rem; }
        }
    </style>
</head>
<body>

    <div class="container">

        <!-- Header -->
        <header class="header animate-enter">
            <div class="brand">
                <div class="brand-icon"><i class="ri-shield-check-line"></i></div>
                <span>VPN Panel</span>
            </div>
            <div class="status-badge">
                <div class="status-dot"></div>
                <span>System Operational</span>
            </div>
        </header>

        <!-- Stats -->
        <div class="stats-grid">
            <!-- CPU -->
            <div class="stat-card animate-enter delay-1">
                <div class="stat-header">
                    <span class="stat-title">CPU Load</span>
                    <i class="ri-cpu-line stat-icon"></i>
                </div>
                <!-- Desktop Layout -->
                <div class="stat-body">
                    <span class="stat-value" id="cpu">--</span>
                    <span class="stat-unit">%</span>
                </div>
                <!-- Mobile only helper (hidden by default, shown via CSS if needed, or simplified) -->
            </div>

            <!-- RAM -->
            <div class="stat-card animate-enter delay-1">
                <div class="stat-header">
                    <span class="stat-title">RAM Usage</span>
                    <i class="ri-database-2-line stat-icon"></i>
                </div>
                <div class="stat-body">
                    <span class="stat-value" id="ram">--</span>
                    <span class="stat-unit">MB</span>
                </div>
            </div>

            <!-- Network -->
            <div class="stat-card animate-enter delay-2">
                <div class="stat-header">
                    <span class="stat-title">Bandwidth</span>
                    <i class="ri-speed-line stat-icon"></i>
                </div>
                <div class="stat-body">
                    <span class="stat-value" id="network">--</span>
                    <span class="stat-unit">Mbps</span>
                </div>
            </div>

            <!-- Disk -->
            <div class="stat-card animate-enter delay-2">
                <div class="stat-header">
                    <span class="stat-title">Disk I/O</span>
                    <i class="ri-hard-drive-2-line stat-icon"></i>
                </div>
                <div class="stat-body">
                    <span class="stat-value" id="disk">--</span>
                    <span class="stat-unit">MB/s</span>
                </div>
            </div>
        </div>

        <!-- Main Dashboard -->
        <div class="dashboard-layout">

            <!-- Chart Area -->
            <div class="panel animate-enter delay-3">
                <div class="panel-header">
                    <div class="panel-title"><i class="ri-bar-chart-grouped-line"></i> Real-time Traffic</div>
                    <button onclick="updateMetrics()" style="background:none; border:none; cursor:pointer; color:var(--text-muted)">
                        <i class="ri-refresh-line"></i>
                    </button>
                </div>
                <div class="chart-wrapper">
                    <canvas id="metricsChart"></canvas>
                </div>
            </div>

            <!-- Server Info -->
            <div class="panel animate-enter delay-3">
                <div class="panel-header">
                    <div class="panel-title"><i class="ri-server-line"></i> Server Details</div>
                </div>

                <div class="info-list">
                    <div class="info-row">
                        <span class="info-label"><i class="ri-global-line"></i> Hostname</span>
                        <span class="info-value">$DOMAIN</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="ri-map-pin-line"></i> Location</span>
                        <span class="info-value">$SERVER_LOC</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="ri-shield-keyhole-line"></i> Protocol</span>
                        <span class="info-value">TLS / XTLS</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label"><i class="ri-time-line"></i> Uptime</span>
                        <span class="info-value">99.98%</span>
                    </div>
                </div>

                <a href="https://t.me/MuzakieID" class="btn-action">
                    <i class="ri-telegram-fill"></i> OPEN BOT MENU
                </a>

                <a href="/clash-converter.php" class="btn-action" style="margin-top: 10px; background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                    <i class="ri-file-code-line"></i> CLASH YAML CONVERTER
                </a>
            </div>

        </div>

        <div class="footer animate-enter delay-3">
            <p>&copy; 2026 Secured by XRAY Core. Modern Dashboard UI.</p>
        </div>

    </div>

    <!-- JS Logic -->
    <script>
        const ctx = document.getElementById('metricsChart').getContext('2d');

        // Gradient for chart
        const gradientCpu = ctx.createLinearGradient(0, 0, 0, 400);
        gradientCpu.addColorStop(0, 'rgba(79, 70, 229, 0.4)'); // Primary
        gradientCpu.addColorStop(1, 'rgba(79, 70, 229, 0.0)');

        const gradientRam = ctx.createLinearGradient(0, 0, 0, 400);
        gradientRam.addColorStop(0, 'rgba(16, 185, 129, 0.4)'); // Success
        gradientRam.addColorStop(1, 'rgba(16, 185, 129, 0.0)');

        Chart.defaults.font.family = "'Outfit', sans-serif";
        Chart.defaults.color = '#94a3b8';

        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [
                    {
                        label: 'CPU Usage (%)',
                        data: [],
                        borderColor: '#4f46e5',
                        backgroundColor: gradientCpu,
                        borderWidth: 3,
                        tension: 0.4,
                        fill: true,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: '#4f46e5',
                        pointBorderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6
                    },
                    {
                        label: 'RAM Usage (%)',
                        data: [],
                        borderColor: '#10b981',
                        backgroundColor: gradientRam,
                        borderWidth: 3,
                        tension: 0.4,
                        fill: true,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: '#10b981',
                        pointBorderWidth: 2,
                        pointRadius: 4,
                        pointHoverRadius: 6
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        align: 'end',
                        labels: { usePointStyle: true, boxWidth: 8, padding: 20, font: { weight: 500 } }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        backgroundColor: 'rgba(255, 255, 255, 0.9)',
                        titleColor: '#0f172a',
                        bodyColor: '#64748b',
                        borderColor: '#e2e8f0',
                        borderWidth: 1,
                        padding: 10,
                        displayColors: true,
                        cornerRadius: 8
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { display: false } // Hide time labels for cleaner look
                    },
                    y: {
                        beginAtZero: true,
                        max: 100,
                        grid: {
                            color: '#f1f5f9',
                            borderDash: [5, 5]
                        },
                        border: { display: false }
                    }
                },
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false
                }
            }
        });

        // Mock data logic remains mostly same, just hooking up IDs
        const maxDataPoints = 20;

        async function updateMetrics() {
            try {
                // Fetch live data from the PHP script
                const response = await fetch('metrics.php');

                if (!response.ok) {
                    throw new Error(`HTTP error! status: \${response.status}`);
                }

                const data = await response.json();

                // Update DOM elements with live data
                document.getElementById('cpu').textContent = data.cpu ? data.cpu.toFixed(1) : '0.0';
                document.getElementById('ram').textContent = data.ram_used ? data.ram_used.toFixed(0) : '0';
                document.getElementById('network').textContent = data.network ? data.network.toFixed(1) : '0.0';
                document.getElementById('disk').textContent = data.disk_io ? data.disk_io.toFixed(2) : '0.00';

                // Update Chart
                const now = new Date().toLocaleTimeString();

                if (chart.data.labels.length > maxDataPoints) {
                    chart.data.labels.shift();
                    chart.data.datasets.forEach(d => d.data.shift());
                }

                chart.data.labels.push(now);
                // Use fallback of 0 if data isn't available
                chart.data.datasets[0].data.push(data.cpu || 0);
                chart.data.datasets[1].data.push(data.ram_percent || 0);

                chart.update('none');
            } catch (err) {
                console.error('Error fetching metrics:', err);
                // Optional: You could uncomment the below to fallback to mock data for testing
                /*
                const mockData = {
                    cpu: Math.random() * 60 + 10,
                    ram_percent: Math.random() * 40 + 30
                };
                // Fallback chart update...
                */
            }
        }

        setInterval(updateMetrics, 2000);
        updateMetrics();
    </script>
</body>
</html>
EOF

# Create metrics API
cat > /var/www/html/metrics.php << 'EOFPHP'
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

function getDefaultInterface() {
    $cmd = "ip route | grep default | awk '{print \$5}' | head -n1";
    return trim(shell_exec($cmd));
}

function getCpuStats() {
    $data = file_get_contents('/proc/stat');
    $info = explode(" ", preg_replace("!cpu +!", "", explode("\n", $data)[0]));
    return $info;
}

function getNetBytes($int) {
    if(empty($int)) return ['rx'=>0, 'tx'=>0];
    $rx = @file_get_contents("/sys/class/net/$int/statistics/rx_bytes");
    $tx = @file_get_contents("/sys/class/net/$int/statistics/tx_bytes");
    return ['rx'=>(float)$rx, 'tx'=>(float)$tx];
}

$net_int = getDefaultInterface();

// 1. Start Snapshot
$cpu1 = getCpuStats();
$net1 = getNetBytes($net_int);

sleep(1);

// 2. End Snapshot
$cpu2 = getCpuStats();
$net2 = getNetBytes($net_int);

// CPU Calc
$dif = [];
$dif['user'] = $cpu2[0] - $cpu1[0];
$dif['nice'] = $cpu2[1] - $cpu1[1];
$dif['sys']  = $cpu2[2] - $cpu1[2];
$dif['idle'] = $cpu2[3] - $cpu1[3];
$total = array_sum($dif);
$cpu = $total > 0 ? (100 - ($dif['idle'] * 100 / $total)) : 0;

// Net Calc (Mbps)
$rx_diff = $net2['rx'] - $net1['rx'];
$tx_diff = $net2['tx'] - $net1['tx'];
$network_mbps = ($rx_diff + $tx_diff) * 8 / 1000000;

// RAM
$free = shell_exec('free -m');
$free_rows = explode("\n", trim($free));
$mem_row = preg_split('/\s+/', $free_rows[1]);
$ram_total = (float)$mem_row[1];
$ram_used = (float)$mem_row[2];
$ram_percent = $ram_total > 0 ? round(($ram_used / $ram_total) * 100, 2) : 0;

// Disk I/O (MB/s) - iostat adds ~1s execution time
$disk_output = shell_exec("iostat -d -m 1 2 | tail -n 2 | head -n 1 | awk '{print \$3+\$4}'");
$disk_io = round((float)trim($disk_output), 2);

echo json_encode([
    'cpu' => round($cpu, 1),
    'ram_total' => $ram_total,
    'ram_used' => $ram_used,
    'ram_percent' => $ram_percent,
    'disk_io' => $disk_io,
    'network' => round($network_mbps, 2),
    'timestamp' => time()
]);
?>
EOFPHP

# Install PHP if not exists
if ! command -v php &> /dev/null; then
    echo "Installing PHP..."
    apt-get install -y php-fpm php-cli sysstat
fi

# Make sure sysstat is installed for iostat
if ! command -v iostat &> /dev/null; then
    apt-get install -y sysstat
fi

# Configure nginx to handle PHP
cat > /etc/nginx/sites-available/vpn << EOF
# ===== PORT 80 - NON-TLS (All domains) =====
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN *.$DOMAIN;

    root /var/www/html;
    index index.html index.htm index.php;

    # PHP handler
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }

    # WebSocket for SSH (non-TLS)
    location /ssh {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    # WebSocket for VMESS (non-TLS)
    location /vmess {
        proxy_pass http://127.0.0.1:10001;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for VLESS (non-TLS)
    location /vless {
        proxy_pass http://127.0.0.1:10002;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for TROJAN (non-TLS)
    location /trojan {
        proxy_pass http://127.0.0.1:10003;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # Serve HTML/PHP for browser access (including bug hosts)
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}

# ===== PORT 89 - Internal (All domains) =====
server {
    listen 89;
    listen [::]:89;
    server_name $DOMAIN *.$DOMAIN;
    root /var/www/html;
    index index.html index.htm index.php;

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }
}

# ===== MAIN DOMAIN - HTTPS (Full features) =====
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/html;
    index index.html index.htm index.php;

    # PHP handler
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }

    # WebSocket for SSH
    location /ssh {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    # WebSocket for VMESS
    location /vmess {
        proxy_pass http://127.0.0.1:10001;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for VLESS
    location /vless {
        proxy_pass http://127.0.0.1:10002;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for TROJAN
    location /trojan {
        proxy_pass http://127.0.0.1:10003;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }


    # Backup download
    location /backup {
        alias /etc/tunneling/backup;
        autoindex on;
        auth_basic "Restricted Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }

    # Serve HTML/PHP for browser access
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
}
EOF

# Generate Bug Hosts Server Block (if exists)
BUG_LIST_FILE="/etc/tunneling/bug-hosts.txt"
if [ -f "\$BUG_LIST_FILE" ] && [ -s "\$BUG_LIST_FILE" ]; then
    echo "Generating bug hosts server block..."

    # Read and format bug domains
    BUG_DOMAINS=""
    while IFS= read -r bug || [ -n "\$bug" ]; do
        # Skip empty lines and comments
        [[ -z "\$bug" || "\$bug" =~ ^#.* ]] && continue
        BUG_DOMAINS="\${BUG_DOMAINS} \${bug}.$DOMAIN"
    done < "\$BUG_LIST_FILE"

    if [ -n "\$BUG_DOMAINS" ]; then
        cat >> /etc/nginx/sites-available/vpn << BUGEOF

# Rate limiting zone for bug domains (must be outside server block)
limit_req_zone \$binary_remote_addr zone=buglimit:10m rate=20r/s;

# ===== BUG HOSTS - HTTPS (WebSocket only, enhanced security) =====
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $BUG_DOMAINS;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Specific logs for bug hosts
    access_log /var/log/nginx/bug-hosts-access.log;
    error_log /var/log/nginx/bug-hosts-error.log warn;

    # Minimal root for landing page
    root /var/www/bug-hosts;
    index index.html;

    # Security: Limit request methods
    if (\$request_method !~ ^(GET|POST|HEAD|OPTIONS)\$) {
        return 405;
    }

    # Security: Small body size limit
    client_max_body_size 2m;

    # Apply rate limit
    limit_req zone=buglimit burst=40 nodelay;

    # WebSocket for SSH
    location /ssh {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    # WebSocket for VMESS
    location /vmess {
        proxy_pass http://127.0.0.1:10001;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for VLESS
    location /vless {
        proxy_pass http://127.0.0.1:10002;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # WebSocket for TROJAN
    location /trojan {
        proxy_pass http://127.0.0.1:10003;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }


    # Simple landing page (no PHP, no backup access)
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
BUGEOF
    fi
fi

# Wildcard server block for other subdomains
cat >> /etc/nginx/sites-available/vpn << EOF

# ===== WILDCARD SUBDOMAINS - HTTPS (Default for other subdomains) =====
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name *.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/html;
    index index.html index.htm index.php;

    # PHP handler
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }

    # WebSocket paths
    location /ssh {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }

    location /vmess {
        proxy_pass http://127.0.0.1:10001;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /vless {
        proxy_pass http://127.0.0.1:10002;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /trojan {
        proxy_pass http://127.0.0.1:10003;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }


    # Serve HTML/PHP
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Create bug hosts landing page
mkdir -p /var/www/bug-hosts
cat > /var/www/bug-hosts/index.html << 'BUGHTML'
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VPN Endpoint</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        .icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(102, 126, 234, 0.7); }
            50% { transform: scale(1.05); box-shadow: 0 0 0 10px rgba(102, 126, 234, 0); }
        }
        .icon svg {
            width: 40px;
            height: 40px;
            fill: white;
        }
        h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
            font-weight: 700;
        }
        p {
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .status {
            display: inline-block;
            background: #10b981;
            color: white;
            padding: 10px 30px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 20px;
        }
        .info {
            background: #f3f4f6;
            border-radius: 12px;
            padding: 20px;
            margin-top: 20px;
            text-align: left;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        .info-row:last-child {
            border-bottom: none;
        }
        .info-label {
            color: #6b7280;
            font-weight: 500;
        }
        .info-value {
            color: #1f2937;
            font-weight: 600;
        }
        @media (max-width: 480px) {
            .container { padding: 30px 20px; }
            h1 { font-size: 24px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">
            <svg viewBox="0 0 24 24">
                <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z"/>
            </svg>
        </div>

        <h1>VPN Endpoint Active</h1>
        <div class="status">🟢 ONLINE</div>
        <p>This endpoint is configured for secure VPN connections. WebSocket tunneling is enabled for authorized clients.</p>

        <div class="info">
            <div class="info-row">
                <span class="info-label">Protocol</span>
                <span class="info-value">TLS / XTLS</span>
            </div>
            <div class="info-row">
                <span class="info-label">Supported</span>
                <span class="info-value">VMESS, VLESS, TROJAN, SSH</span>
            </div>
            <div class="info-row">
                <span class="info-label">Transport</span>
                <span class="info-value">WebSocket</span>
            </div>
            <div class="info-row">
                <span class="info-label">Security</span>
                <span class="info-value">Enhanced</span>
            </div>
        </div>
    </div>
</body>
</html>
BUGHTML

# Patch nginx directives for compatibility
if [ ! -s /proc/net/if_inet6 ]; then
    echo "IPv6 not supported by kernel. Removing IPv6 listen directives from nginx config..."
    sed -i '/listen \[::\]:/d' /etc/nginx/sites-available/vpn 2>/dev/null
fi

# Old nginx builds may not support standalone `http2 on;`
sed -i 's/^[[:space:]]*http2 on;[[:space:]]*$/    # http2 moved to listen directive/g' /etc/nginx/sites-available/vpn 2>/dev/null

# Test nginx config
nginx -t

if [ $? -eq 0 ]; then
    # Resolve conflicts
    echo "Resolving port conflicts..."
    systemctl stop apache2 2>/dev/null
    pkill -9 nginx 2>/dev/null
    fuser -k 80/tcp 2>/dev/null
    fuser -k 443/tcp 2>/dev/null

    systemctl start nginx
    echo "Nginx configured successfully!"
else
    echo "Nginx configuration error!"
    exit 1
fi
