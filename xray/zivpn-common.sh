#!/bin/bash

ZIVPN_DATA_DIR="/etc/tunneling/zivpn"
ZIVPN_CONFIG_FILE="/etc/zivpn/config.json"
ZIVPN_SERVICE="zivpn"

ensure_zivpn_dirs() {
    mkdir -p "$ZIVPN_DATA_DIR"
    mkdir -p /etc/zivpn
}

zivpn_now() {
    date +%s
}

zivpn_password_array_json() {
    local now
    now=$(zivpn_now)
    local pw_list=()

    for f in "$ZIVPN_DATA_DIR"/*.json; do
        [ -f "$f" ] || continue

        local locked expired password
        locked=$(jq -r '.locked // false' "$f" 2>/dev/null)
        expired=$(jq -r '.expired // 0' "$f" 2>/dev/null)
        password=$(jq -r '.password // empty' "$f" 2>/dev/null)

        if [ "$locked" = "true" ]; then
            continue
        fi

        if [[ "$expired" =~ ^[0-9]+$ ]] && [ "$expired" -gt 0 ] && [ "$expired" -lt "$now" ]; then
            continue
        fi

        if [ -n "$password" ] && [ "$password" != "null" ]; then
            pw_list+=("$password")
        fi
    done

    if [ ${#pw_list[@]} -eq 0 ]; then
        pw_list=("zi")
    fi

    printf '%s\n' "${pw_list[@]}" | jq -R . | jq -s .
}

sync_zivpn_auth_config() {
    ensure_zivpn_dirs

    if [ ! -f "$ZIVPN_CONFIG_FILE" ]; then
        cat > "$ZIVPN_CONFIG_FILE" << 'EOF'
{
  "listen": ":5667",
  "cert": "/etc/zivpn/zivpn.crt",
  "key": "/etc/zivpn/zivpn.key",
  "obfs": "zivpn",
  "auth": {
    "mode": "passwords",
    "config": ["zi"]
  }
}
EOF
    fi

    local pw_json
    pw_json=$(zivpn_password_array_json)

    jq --argjson pw "$pw_json" '.auth.config = $pw' "$ZIVPN_CONFIG_FILE" > /tmp/zivpn-config.tmp && mv /tmp/zivpn-config.tmp "$ZIVPN_CONFIG_FILE"

    if systemctl list-unit-files | grep -q "^${ZIVPN_SERVICE}\.service"; then
        systemctl restart "$ZIVPN_SERVICE" 2>/dev/null || true
    fi
}
