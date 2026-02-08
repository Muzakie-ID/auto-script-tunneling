#!/bin/bash

# Create Clash YAML Converter Web Page (Link Paste Version)
# This script creates a web-based converter for pasting VMess/VLess/Trojan links

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

DOMAIN=$(cat /root/domain.txt 2>/dev/null || echo "localhost")

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Creating Clash YAML Converter (Paste Link)   ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create converter PHP file
cat > /var/www/html/clash-converter.php << 'EOFPHP'
<?php
// Clash YAML Converter - Link Paste Version
$domain = trim(file_get_contents('/root/domain.txt'));

$yaml_output = '';
$error = '';
$config_info = [];

function decodeVmessLink($link) {
    // Remove vmess:// prefix
    $encoded = str_replace('vmess://', '', trim($link));
    
    // Decode base64
    $decoded = base64_decode($encoded);
    if (!$decoded) {
        return ['error' => 'Invalid VMess link - base64 decode failed'];
    }
    
    // Parse JSON
    $config = json_decode($decoded, true);
    if (!$config) {
        return ['error' => 'Invalid VMess link - JSON parse failed'];
    }
    
    return [
        'type' => 'vmess',
        'name' => $config['ps'] ?? 'VMess-Config',
        'server' => $config['add'] ?? '',
        'port' => $config['port'] ?? 443,
        'uuid' => $config['id'] ?? '',
        'alterId' => $config['aid'] ?? 0,
        'cipher' => $config['scy'] ?? 'auto',
        'network' => $config['net'] ?? 'ws',
        'path' => $config['path'] ?? '/',
        'host' => $config['host'] ?? $config['add'] ?? '',
        'tls' => ($config['tls'] ?? '') === 'tls',
        'sni' => $config['sni'] ?? $config['host'] ?? $config['add'] ?? ''
    ];
}

function decodeVlessLink($link) {
    // Parse vless://uuid@server:port?params#name
    if (!preg_match('/vless:\/\/([^@]+)@([^:]+):(\d+)\?(.+)#(.*)/', $link, $matches)) {
        return ['error' => 'Invalid VLess link format'];
    }
    
    $uuid = $matches[1];
    $server = $matches[2];
    $port = $matches[3];
    $params_str = $matches[4];
    $name = urldecode($matches[5]) ?: 'VLess-Config';
    
    // Parse params
    parse_str($params_str, $params);
    
    return [
        'type' => 'vless',
        'name' => $name,
        'server' => $server,
        'port' => (int)$port,
        'uuid' => $uuid,
        'network' => $params['type'] ?? 'ws',
        'path' => $params['path'] ?? '/',
        'host' => $params['host'] ?? $server,
        'tls' => ($params['security'] ?? '') === 'tls',
        'sni' => $params['sni'] ?? $params['host'] ?? $server
    ];
}

function decodeTrojanLink($link) {
    // Parse trojan://password@server:port?params#name
    if (!preg_match('/trojan:\/\/([^@]+)@([^:]+):(\d+)\??(.*)#?(.*)/', $link, $matches)) {
        return ['error' => 'Invalid Trojan link format'];
    }
    
    $password = $matches[1];
    $server = $matches[2];
    $port = $matches[3];
    $params_str = $matches[4] ?? '';
    $name = urldecode($matches[5]) ?: 'Trojan-Config';
    
    // Parse params
    $params = [];
    if (!empty($params_str)) {
        parse_str($params_str, $params);
    }
    
    return [
        'type' => 'trojan',
        'name' => $name,
        'server' => $server,
        'port' => (int)$port,
        'password' => $password,
        'network' => $params['type'] ?? 'ws',
        'path' => $params['path'] ?? '/',
        'host' => $params['host'] ?? $params['sni'] ?? $server,
        'sni' => $params['sni'] ?? $params['host'] ?? $server,
        'skip_verify' => ($params['allowInsecure'] ?? '0') === '1'
    ];
}

function generateClashYAML($config) {
    if (isset($config['error'])) {
        return null;
    }
    
    $yaml = "- name: " . $config['name'] . "\n";
    $yaml .= "  server: " . $config['server'] . "\n";
    $yaml .= "  port: " . $config['port'] . "\n";
    $yaml .= "  type: " . $config['type'] . "\n";
    
    if ($config['type'] === 'vmess') {
        $yaml .= "  uuid: " . $config['uuid'] . "\n";
        $yaml .= "  alterId: " . $config['alterId'] . "\n";
        $yaml .= "  cipher: " . $config['cipher'] . "\n";
        $yaml .= "  tls: " . ($config['tls'] ? 'true' : 'false') . "\n";
        $yaml .= "  skip-cert-verify: false\n";
        if ($config['tls']) {
            $yaml .= "  servername: " . $config['sni'] . "\n";
        }
        $yaml .= "  network: " . $config['network'] . "\n";
        if ($config['network'] === 'ws') {
            $yaml .= "  ws-opts:\n";
            $yaml .= "    path: " . $config['path'] . "\n";
            $yaml .= "    headers:\n";
            $yaml .= "      Host: " . $config['host'] . "\n";
        }
        $yaml .= "  udp: true";
        
    } elseif ($config['type'] === 'vless') {
        $yaml .= "  uuid: " . $config['uuid'] . "\n";
        $yaml .= "  tls: " . ($config['tls'] ? 'true' : 'false') . "\n";
        $yaml .= "  skip-cert-verify: false\n";
        if ($config['tls']) {
            $yaml .= "  servername: " . $config['sni'] . "\n";
        }
        $yaml .= "  network: " . $config['network'] . "\n";
        if ($config['network'] === 'ws') {
            $yaml .= "  ws-path: " . $config['path'] . "\n";
            $yaml .= "  ws-headers:\n";
            $yaml .= "    Host: " . $config['host'] . "\n";
        }
        $yaml .= "  udp: true";
        
    } elseif ($config['type'] === 'trojan') {
        $yaml .= "  password: " . $config['password'] . "\n";
        $yaml .= "  sni: " . $config['sni'] . "\n";
        $yaml .= "  skip-cert-verify: " . ($config['skip_verify'] ? 'true' : 'false') . "\n";
        $yaml .= "  network: " . $config['network'] . "\n";
        if ($config['network'] === 'ws') {
            $yaml .= "  ws-opts:\n";
            $yaml .= "    path: " . $config['path'] . "\n";
            $yaml .= "    headers:\n";
            $yaml .= "      Host: " . $config['host'] . "\n";
        }
        $yaml .= "  udp: true";
    }
    
    return $yaml;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $link = trim($_POST['link'] ?? '');
    
    if (empty($link)) {
        $error = 'Please paste a valid VMess/VLess/Trojan link';
    } else {
        // Detect protocol
        if (stripos($link, 'vmess://') === 0) {
            $config_info = decodeVmessLink($link);
        } elseif (stripos($link, 'vless://') === 0) {
            $config_info = decodeVlessLink($link);
        } elseif (stripos($link, 'trojan://') === 0) {
            $config_info = decodeTrojanLink($link);
        } else {
            $error = 'Unsupported link format. Only VMess, VLess, and Trojan links are supported.';
        }
        
        if (isset($config_info['error'])) {
            $error = $config_info['error'];
        } else {
            $yaml_output = generateClashYAML($config_info);
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clash YAML Converter - <?= $domain ?></title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 32px;
            margin-bottom: 10px;
            font-weight: 700;
        }
        
        .header p {
            opacity: 0.9;
            font-size: 16px;
        }
        
        .content { padding: 40px 30px; }
        
        .form-group { margin-bottom: 25px; }
        
        label {
            display: block;
            margin-bottom: 10px;
            font-weight: 600;
            color: #333;
            font-size: 15px;
        }
        
        textarea {
            width: 100%;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 14px;
            resize: vertical;
            min-height: 140px;
            transition: all 0.3s;
            background: #fafafa;
        }
        
        textarea:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }
        
        .hint {
            font-size: 13px;
            color: #666;
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 15px 35px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            width: 100%;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.5);
        }
        
        .btn:active { transform: translateY(0); }
        
        .error {
            background: #fee;
            border-left: 4px solid #f44;
            padding: 18px;
            margin-bottom: 25px;
            border-radius: 10px;
            color: #c33;
            font-weight: 500;
        }
        
        .result { margin-top: 35px; }
        
        .info-box {
            background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px dashed #cbd5e0;
        }
        
        .info-row:last-child { border-bottom: none; }
        
        .info-label {
            font-weight: 600;
            color: #4a5568;
        }
        
        .info-value {
            color: #1a202c;
            font-family: 'Consolas', monospace;
            background: white;
            padding: 4px 10px;
            border-radius: 5px;
        }
        
        .yaml-wrapper { position: relative; }
        
        .yaml-output {
            background: #1e293b;
            color: #e2e8f0;
            padding: 25px;
            border-radius: 12px;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 14px;
            line-height: 1.6;
            white-space: pre-wrap;
            overflow-x: auto;
            box-shadow: inset 0 2px 10px rgba(0,0,0,0.3);
        }
        
        .copy-btn {
            position: absolute;
            top: 15px;
            right: 15px;
            background: #10b981;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.2s;
            box-shadow: 0 2px 10px rgba(16, 185, 129, 0.3);
        }
        
        .copy-btn:hover {
            background: #059669;
            transform: translateY(-1px);
        }
        
        .copy-btn.copied {
            background: #3b82f6;
        }
        
        .examples {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            border-left: 4px solid #f59e0b;
            padding: 20px;
            margin-bottom: 25px;
            border-radius: 10px;
        }
        
        .examples h3 {
            margin-bottom: 15px;
            color: #92400e;
            font-size: 16px;
        }
        
        .examples code {
            display: block;
            background: white;
            padding: 10px;
            border-radius: 6px;
            margin: 8px 0;
            font-size: 11px;
            overflow-x: auto;
            white-space: nowrap;
            border: 1px solid #fbbf24;
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 25px;
            border-top: 2px solid #e5e7eb;
            text-align: center;
        }
        
        .footer a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s;
        }
        
        .footer a:hover {
            color: #764ba2;
        }
        
        h3 {
            margin-bottom: 15px;
            color: #1e293b;
            font-size: 18px;
            font-weight: 700;
        }
        
        @media (max-width: 768px) {
            .container { border-radius: 0; }
            .content { padding: 25px 20px; }
            .header { padding: 30px 20px; }
            .header h1 { font-size: 26px; }
            .info-row {
                flex-direction: column;
                gap: 8px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔄 Clash YAML Converter</h1>
            <p>Paste VMess / VLess / Trojan Link → Get Clash Config</p>
        </div>
        
        <div class="content">
            <?php if ($error): ?>
                <div class="error">
                    <strong>❌ Error:</strong> <?= htmlspecialchars($error) ?>
                </div>
            <?php endif; ?>
            
            <div class="examples">
                <h3>📝 Supported Link Formats:</h3>
                <code>vmess://eyJhZGQiOiIxMjMuNDUuNjcuODkiLCJhaWQiOjAsInBzIjoiVk1FU1MiLCJwb3J0Ijo0NDMsInYiOjIsInRscyI6InRscyIsIm5ldCI6IndzIiwiaG9zdCI6ImV4YW1wbGUuY29tIiwicGF0aCI6Ii92bWVzcyIsImlkIjoiMTIzNDU2Nzg5MCJ9</code>
                <code>vless://uuid@example.com:443?type=ws&security=tls&path=/vless&host=example.com#VLess</code>
                <code>trojan://password@example.com:443?type=ws&path=/trojan&host=example.com#Trojan</code>
            </div>
            
            <form method="POST">
                <div class="form-group">
                    <label for="link">📎 Paste Your Config Link:</label>
                    <textarea 
                        name="link" 
                        id="link" 
                        placeholder="vmess://... or vless://... or trojan://..." 
                        required><?= htmlspecialchars($_POST['link'] ?? '') ?></textarea>
                    <div class="hint">💡 Automatically detects VMess, VLess, and Trojan protocols</div>
                </div>
                
                <button type="submit" class="btn">🔄 Convert to Clash YAML</button>
            </form>
            
            <?php if ($yaml_output && !empty($config_info)): ?>
                <div class="result">
                    <h3>📊 Decoded Configuration</h3>
                    <div class="info-box">
                        <div class="info-row">
                            <span class="info-label">Name:</span>
                            <span class="info-value"><?= htmlspecialchars($config_info['name']) ?></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Protocol:</span>
                            <span class="info-value"><?= strtoupper($config_info['type']) ?></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Server:</span>
                            <span class="info-value"><?= htmlspecialchars($config_info['server']) ?></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Port:</span>
                            <span class="info-value"><?= $config_info['port'] ?></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Network:</span>
                            <span class="info-value"><?= strtoupper($config_info['network']) ?></span>
                        </div>
                        <?php if (isset($config_info['path'])): ?>
                        <div class="info-row">
                            <span class="info-label">Path:</span>
                            <span class="info-value"><?= htmlspecialchars($config_info['path']) ?></span>
                        </div>
                        <?php endif; ?>
                        <?php if (isset($config_info['tls'])): ?>
                        <div class="info-row">
                            <span class="info-label">TLS:</span>
                            <span class="info-value"><?= $config_info['tls'] ? '✅ Enabled' : '❌ Disabled' ?></span>
                        </div>
                        <?php endif; ?>
                    </div>
                    
                    <h3>📋 Clash YAML Output</h3>
                    <div class="yaml-wrapper">
                        <div class="yaml-output"><button class="copy-btn" onclick="copyYAML()">📋 Copy</button><div id="yaml-content"><?= htmlspecialchars($yaml_output) ?></div></div>
                    </div>
                </div>
            <?php endif; ?>
            
            <div class="footer">
                <p><a href="/">← Back to Dashboard</a></p>
            </div>
        </div>
    </div>
    
    <script>
        function copyYAML() {
            const yamlText = document.getElementById('yaml-content').innerText;
            const btn = document.querySelector('.copy-btn');
            
            navigator.clipboard.writeText(yamlText).then(() => {
                btn.textContent = '✅ Copied!';
                btn.classList.add('copied');
                
                setTimeout(() => {
                    btn.textContent = '📋 Copy';
                    btn.classList.remove('copied');
                }, 2000);
            }).catch(err => {
                alert('Copy failed! Please select and copy manually.');
            });
        }
    </script>
</body>
</html>
EOFPHP

# Set permissions
chown www-data:www-data /var/www/html/clash-converter.php 2>/dev/null || true
chmod 644 /var/www/html/clash-converter.php

echo ""
echo -e "${GREEN}[✓]${NC} Clash YAML Converter (Paste Link Version) created!"
echo -e "${CYAN}[INFO]${NC} Location: /var/www/html/clash-converter.php"
echo -e "${CYAN}[INFO]${NC} Access URL: https://${DOMAIN}/clash-converter.php"
echo ""
echo -e "${YELLOW}Features:${NC}"
echo "  ✅ Paste VMess/VLess/Trojan link"
echo "  ✅ Auto-decode and parse config"
echo "  ✅ Generate Clash YAML format"
echo "  ✅ One-click copy output"
echo "  ✅ Shows decoded config details"
echo ""
echo -e "${GREEN}Installation complete!${NC}"
