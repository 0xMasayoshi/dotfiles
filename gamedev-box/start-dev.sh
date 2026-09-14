cat << 'EOF' > ~/dotfiles/gamedev-box/start-dev.sh
#!/usr/bin/env bash
set -e

# ==========================================
# CONFIGURATION
# ==========================================
export OPENCODE_SERVER_PORT="4096"
export OPENCODE_SERVER_HOSTNAME="0.0.0.0"

# If not already set in your environment, prompt for it
if [ -z "$OPENCODE_SERVER_PASSWORD" ]; then
    read -rsp "Enter OpenCode web password: " OPENCODE_SERVER_PASSWORD
    echo
    export OPENCODE_SERVER_PASSWORD
fi

# ==========================================
# LAUNCHER LOGIC
# ==========================================
SCRIPT_PATH="$(realpath "$0")"

# If on the host, forward into distrobox preserving the password
if [ ! -f "/run/.containerenv" ]; then
    echo "=== Entering godot-dev container... ==="
    exec distrobox enter godot-dev -- "$SCRIPT_PATH"
fi

# Inside the container: start the web editor
echo "=== OpenCode Web running on port $OPENCODE_SERVER_PORT ==="
exec opencode web --port "$OPENCODE_SERVER_PORT" --hostname "$OPENCODE_SERVER_HOSTNAME"
EOF

chmod +x ~/dotfiles/gamedev-box/start-dev.sh
