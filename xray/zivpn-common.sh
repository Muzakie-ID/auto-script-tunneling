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

have_jq() {
    command -v jq >/dev/null 2>&1
}

try_install_jq() {
    if have_jq; then
        return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y jq >/dev/null 2>&1 || true
    fi

    have_jq
}

extract_json_field_fallback() {
    local file="$1"
    local key="$2"

    sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$file" | head -n 1
}

extract_json_bool_fallback() {
    local file="$1"
    local key="$2"

    sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p" "$file" | head -n 1
}

extract_json_number_fallback() {
    local file="$1"
    local key="$2"

    sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\([0-9]\+\).*/\1/p" "$file" | head -n 1
}

build_password_json_array() {
    local -n _arr_ref=$1

    if [ ${#_arr_ref[@]} -eq 0 ]; then
        echo '["zi"]'
        return
    fi

    local out="["
    local p
    for p in "${_arr_ref[@]}"; do
        out+="\"${p}\","
    done
    out="${out%,}]"
    echo "$out"
}

zivpn_password_array_json() {
    local now
    now=$(zivpn_now)
    local pw_list=()

    for f in "$ZIVPN_DATA_DIR"/*.json; do
        [ -f "$f" ] || continue

        local locked expired password

        if have_jq; then
            locked=$(jq -r '.locked // false' "$f" 2>/dev/null)
            expired=$(jq -r '.expired // 0' "$f" 2>/dev/null)
            password=$(jq -r '.password // empty' "$f" 2>/dev/null)
        else
            locked=$(extract_json_bool_fallback "$f" "locked")
            expired=$(extract_json_number_fallback "$f" "expired")
            password=$(extract_json_field_fallback "$f" "password")

            [ -z "$locked" ] && locked="false"
            [ -z "$expired" ] && expired="0"
        fi

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

    build_password_json_array pw_list
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

    try_install_jq >/dev/null 2>&1 || true

    local pw_json
    pw_json=$(zivpn_password_array_json)

    if have_jq; then
        jq --argjson pw "$pw_json" '.auth.config = $pw' "$ZIVPN_CONFIG_FILE" > /tmp/zivpn-config.tmp && mv /tmp/zivpn-config.tmp "$ZIVPN_CONFIG_FILE"
    else
        sed -i -E "s/\"config\"[[:space:]]*:[[:space:]]*\[[^]]*\]/\"config\": ${pw_json}/" "$ZIVPN_CONFIG_FILE" 2>/dev/null || true
    fi

    if systemctl list-unit-files | grep -q "^${ZIVPN_SERVICE}\.service"; then
        systemctl restart "$ZIVPN_SERVICE" 2>/dev/null || true
    fi
}
