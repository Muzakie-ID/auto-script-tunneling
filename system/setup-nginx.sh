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
    return 301 https://\$server_name\$request_uri;
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
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/vpn /etc/nginx/sites-enabled/

# Create landing page
mkdir -p /var/www/html
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>VPN Dashboard - $DOMAIN</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <style>
        :root {
            /* Palette */
            --bg-body: #F6F0D7;     /* Cream BG */
            --primary: #89986D;     /* Dark Sage - Primary Action/Text */
            --secondary: #9CAB84;   /* Sage - Secondary Elements */
            --accent: #C5D89D;      /* Light Sage - Accents/Soft BG */
            --card-bg: #ffffff;
            --text-main: #2c3e2e;   /* Darker text */
            --text-muted: #89986D;
            --border: #e1e6d8;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        
        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-main);
            min-height: 100vh;
            padding: 1rem;
            /* Subtle texture */
            background-image: radial-gradient(#9CAB84 1px, transparent 1px);
            background-size: 20px 20px;
        }

        .app-container {
            max-width: 1100px;
            margin: 0 auto;
            width: 100%;
        }

        /* Header */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            background: var(--card-bg);
            padding: 1rem 1.5rem;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(137, 152, 109, 0.05);
            border: 1px solid var(--border);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary);
        }
        .brand i { font-size: 1.5rem; }

        .status-pill {
            background: #e6f4ea;
            color: #1e7e34;
            padding: 6px 12px;
            border-radius: 100px;
            font-size: 0.8rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .status-dot { width: 8px; height: 8px; background: #28a745; border-radius: 50%; }

        /* Dashboard Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .stat-card {
            background: var(--card-bg);
            padding: 1.25rem;
            border-radius: 16px;
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            gap: 8px;
            box-shadow: 0 2px 10px rgba(137, 152, 109, 0.03);
        }

        .stat-icon {
            color: var(--secondary);
            font-size: 1.5rem;
            margin-bottom: 4px;
        }
        .stat-label { font-size: 0.75rem; color: var(--text-muted); font-weight: 600; letter-spacing: 0.5px; text-transform: uppercase; }
        .stat-value { font-size: 1.5rem; font-weight: 700; color: var(--text-main); line-height: 1; }
        .stat-unit { font-size: 0.8rem; color: var(--text-muted); font-weight: 500; }

        /* Main Content Layout */
        .content-wrapper {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 1.5rem;
        }

        .card-box {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 1.5rem;
            border: 1px solid var(--border);
            box-shadow: 0 2px 15px rgba(137, 152, 109, 0.03);
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }

        .card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .card-title { font-size: 1.1rem; font-weight: 600; color: var(--text-main); display: flex; align-items: center; gap: 8px; }

        /* List Styling */
        .info-list { display: flex; flex-direction: column; gap: 0; }
        .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--border);
            font-size: 0.95rem;
        }
        .info-item:last-child { border-bottom: none; padding-bottom: 0; }
        .info-item:first-child { padding-top: 0; }
        
        .info-label { color: var(--text-muted); display: flex; align-items: center; gap: 8px; }
        .info-value { font-weight: 600; color: var(--text-main); }

        /* Action Button */
        .btn-order {
            background: var(--primary);
            color: white;
            text-decoration: none;
            padding: 1rem;
            border-radius: 14px;
            text-align: center;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: transform 0.2s, background 0.2s;
            margin-top: auto; /* Push to bottom */
        }
        .btn-order:active { transform: scale(0.98); background: var(--secondary); }

        /* Chart */
        .chart-container {
            position: relative;
            height: 300px;
            width: 100%;
        }

        /* Footer */
        .footer {
            text-align: center;
            margin-top: 2rem;
            color: var(--text-muted);
            font-size: 0.8rem;
            padding-bottom: 1rem;
        }

        /* Mobile Adjustments */
        @media (max-width: 900px) {
            .content-wrapper { grid-template-columns: 1fr; }
        }

        @media (max-width: 600px) {
            body { padding: 0.75rem; }
            .header { padding: 0.75rem 1rem; margin-bottom: 1rem; }
            .brand { font-size: 1.1rem; }
            .stats-grid { grid-template-columns: repeat(2, 1fr); gap: 0.75rem; }
            .stat-card { padding: 1rem; }
            .stat-value { font-size: 1.25rem; }
            .card-box { padding: 1.25rem; }
            .chart-container { height: 250px; }
            
            /* Remove highlighting on mobile tap */
            a, button, div { -webkit-tap-highlight-color: rgba(0,0,0,0); }
        }
    </style>
</head>
<body>

    <div class="app-container">
        
        <!-- Header -->
        <header class="header">
            <div class="brand">
                <i class="ri-shield-flash-fill"></i>
                <span>VPN Panel</span>
            </div>
            <div class="status-pill">
                <div class="status-dot"></div>
                <span>Online</span>
            </div>
        </header>

        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <i class="ri-cpu-line stat-icon"></i>
                <div>
                    <div class="stat-label">CPU Load</div>
                    <div><span class="stat-value" id="cpu">--</span><span class="stat-unit">%</span></div>
                </div>
            </div>
            <div class="stat-card">
                <i class="ri-ram-2-line stat-icon"></i>
                <div>
                    <div class="stat-label">RAM</div>
                    <div><span class="stat-value" id="ram">--</span><span class="stat-unit">MB</span></div>
                </div>
            </div>
            <div class="stat-card">
                <i class="ri-speed-line stat-icon"></i>
                <div>
                    <div class="stat-label">Network</div>
                    <div><span class="stat-value" id="network">--</span><span class="stat-unit">Mbps</span></div>
                </div>
            </div>
            <div class="stat-card">
                <i class="ri-database-2-line stat-icon"></i>
                <div>
                    <div class="stat-label">Disk</div>
                    <div><span class="stat-value" id="disk">--</span><span class="stat-unit">MB/s</span></div>
                </div>
            </div>
        </div>

        <!-- Content -->
        <div class="content-wrapper">
            
            <!-- Chart Section -->
            <div class="card-box">
                <div class="card-header">
                    <div class="card-title"><i class="ri-bar-chart-box-line"></i> Traffic Monitor</div>
                </div>
                <div class="chart-container">
                    <canvas id="metricsChart"></canvas>
                </div>
            </div>

            <!-- Server Details -->
            <div class="card-box">
                <div class="card-header">
                    <div class="card-title"><i class="ri-server-line"></i> Server Info</div>
                </div>
                <div class="info-list">
                    <div class="info-item">
                        <span class="info-label"><i class="ri-global-line"></i> Host</span>
                        <span class="info-value">$DOMAIN</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label"><i class="ri-map-pin-line"></i> Location</span>
                        <span class="info-value">SG / IDN</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label"><i class="ri-base-station-line"></i> Protocol</span>
                        <span class="info-value">Multi-Port</span>
                    </div>
                    <div class="info-item">
                        <span class="info-label"><i class="ri-time-line"></i> Uptime</span>
                        <span class="info-value">99.9%</span>
                    </div>
                </div>
                
                <a href="https://t.me/yourvpnbot" class="btn-order">
                    <i class="ri-telegram-fill"></i> OPEN BOT MENU
                </a>
            </div>

        </div>

        <div class="footer">
            &copy; 2026 Secured by XRAY Core. Optimized for Mobile.
        </div>

    </div>

    <script>
        // Palette for JS
        const theme = {
            primary: '#89986D',
            secondary: '#9CAB84',
            bg: '#F6F0D7',
            white: '#ffffff',
            grid: '#e1e6d8'
        };

        const ctx = document.getElementById('metricsChart');
        const maxDataPoints = 20;

        Chart.defaults.font.family = 'Outfit';
        Chart.defaults.color = theme.secondary;

        const chart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [
                    {
                        label: 'CPU (%)',
                        data: [],
                        borderColor: theme.primary,
                        backgroundColor: 'rgba(137, 152, 109, 0.1)',
                        borderWidth: 2,
                        tension: 0.4,
                        fill: true,
                        pointRadius: 0,
                        pointHitRadius: 10
                    },
                    {
                        label: 'RAM (%)',
                        data: [],
                        borderColor: theme.secondary,
                        backgroundColor: 'rgba(156, 171, 132, 0.1)',
                        borderWidth: 2,
                        tension: 0.4,
                        fill: true,
                        pointRadius: 0,
                        pointHitRadius: 10
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            usePointStyle: true,
                            boxWidth: 8,
                            padding: 20
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { display: false }
                    },
                    y: {
                        beginAtZero: true,
                        max: 100,
                        grid: { color: theme.grid },
                        border: { display: false },
                        ticks: { maxTicksLimit: 5 }
                    }
                },
                interaction: {
                    mode: 'index',
                    intersect: false,
                }
            }
        });

        async function updateMetrics() {
            try {
                const response = await fetch('/metrics.php');
                const data = await response.json();
                
                document.getElementById('cpu').textContent = data.cpu.toFixed(1);
                document.getElementById('ram').textContent = data.ram_used.toFixed(0);
                document.getElementById('disk').textContent = data.disk_io.toFixed(2);
                document.getElementById('network').textContent = data.network.toFixed(1);
                
                const now = new Date().toLocaleTimeString();
                if (chart.data.labels.length > maxDataPoints) {
                    chart.data.labels.shift();
                    chart.data.datasets.forEach(d => d.data.shift());
                }
                chart.data.labels.push(now);
                chart.data.datasets[0].data.push(data.cpu);
                chart.data.datasets[1].data.push(data.ram_percent);
                
                chart.update('none');
            } catch (err) {
                console.error(err);
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

// Get CPU usage
function getCpuUsage() {
    $stat1 = file('/proc/stat');
    sleep(1);
    $stat2 = file('/proc/stat');
    
    $info1 = explode(" ", preg_replace("!cpu +!", "", $stat1[0]));
    $info2 = explode(" ", preg_replace("!cpu +!", "", $stat2[0]));
    
    $dif = array();
    $dif['user'] = $info2[0] - $info1[0];
    $dif['nice'] = $info2[1] - $info1[1];
    $dif['sys'] = $info2[2] - $info1[2];
    $dif['idle'] = $info2[3] - $info1[3];
    $total = array_sum($dif);
    $cpu = 100 - ($dif['idle'] * 100 / $total);
    
    return round($cpu, 2);
}

// Get RAM usage
function getRamUsage() {
    $free = shell_exec('free -m');
    $free = (string)trim($free);
    $free_arr = explode("\n", $free);
    $mem = explode(" ", $free_arr[1]);
    $mem = array_filter($mem);
    $mem = array_merge($mem);
    
    return array(
        'total' => (float)$mem[1],
        'used' => (float)$mem[2],
        'free' => (float)$mem[3],
        'percent' => round(($mem[2] / $mem[1]) * 100, 2)
    );
}

// Get Disk I/O
function getDiskIO() {
    $output = shell_exec("iostat -d -m 1 2 | tail -n 2 | head -n 1 | awk '{print \$3+\$4}'");
    return round((float)trim($output), 2);
}

// Get Network bandwidth
function getNetworkBandwidth() {
    $interface = trim(shell_exec("ip route | grep default | awk '{print \$5}' | head -n1"));
    if (empty($interface)) {
        return 0;
    }
    
    $rx1 = (float)file_get_contents("/sys/class/net/$interface/statistics/rx_bytes");
    $tx1 = (float)file_get_contents("/sys/class/net/$interface/statistics/tx_bytes");
    sleep(1);
    $rx2 = (float)file_get_contents("/sys/class/net/$interface/statistics/rx_bytes");
    $tx2 = (float)file_get_contents("/sys/class/net/$interface/statistics/tx_bytes");
    
    $rx = ($rx2 - $rx1) * 8 / 1000000; // Convert to Mbit/s
    $tx = ($tx2 - $tx1) * 8 / 1000000;
    
    return round($rx + $tx, 2);
}

$ram = getRamUsage();

$metrics = array(
    'cpu' => getCpuUsage(),
    'ram_total' => $ram['total'],
    'ram_used' => $ram['used'],
    'ram_free' => $ram['free'],
    'ram_percent' => $ram['percent'],
    'disk_io' => getDiskIO(),
    'network' => getNetworkBandwidth(),
    'timestamp' => time()
);

echo json_encode($metrics);
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
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN *.$DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

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

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN *.$DOMAIN;

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
}
EOF

# Test nginx config
nginx -t

if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "Nginx configured successfully!"
else
    echo "Nginx configuration error!"
    exit 1
fi
