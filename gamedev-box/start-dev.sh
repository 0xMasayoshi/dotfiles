#!/usr/bin/env bash
set -e

# Configuration
export OPENCODE_SERVER_PORT="${OPENCODE_SERVER_PORT:-4096}"
export OPENCODE_SERVER_HOSTNAME="${OPENCODE_SERVER_HOSTNAME:-0.0.0.0}"
SESSION_NAME="gamedev"

# If password isn't in env, prompt for it
if [ -z "$OPENCODE_SERVER_PASSWORD" ]; then
    read -rsp "Enter OpenCode web password: " OPENCODE_SERVER_PASSWORD
    echo
    export OPENCODE_SERVER_PASSWORD
fi

# 1. Forward into Distrobox if executed from the host
if [ ! -f "/run/.containerenv" ]; then
    echo "=== Launching inside godot-dev container ==="
    exec distrobox enter godot-dev -- env OPENCODE_SERVER_PASSWORD="$OPENCODE_SERVER_PASSWORD" bash "$(realpath "$0")"
fi

# 2. Inside Container: Ensure tmux is present
if ! command -v tmux &>/dev/null; then
    echo "=== tmux missing inside container, installing... ==="
    sudo apt update && sudo apt install -y tmux
fi

# 3. Check Auth Status before backgrounding
AUTH_FILE_1="$HOME/.local/share/opencode/auth.json"
AUTH_FILE_2="$HOME/.config/opencode/auth.json"

if [ ! -f "$AUTH_FILE_1" ] && [ ! -f "$AUTH_FILE_2" ]; then
    echo "=== No OpenCode credentials detected ==="
    echo "Launching one-time interactive login..."
    opencode auth login || true
fi

# 4. Inside Container: Launch or report tmux session
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "OpenCode is already running in background session '$SESSION_NAME'."
else
    echo "Starting OpenCode web in background session '$SESSION_NAME'..."
    tmux new-session -d -s "$SESSION_NAME" \
        "opencode web --port $OPENCODE_SERVER_PORT --hostname $OPENCODE_SERVER_HOSTNAME"
fi

IP="$(hostname -I | awk '{print $1}')"
echo "----------------------------------------------------"
echo " OpenCode Web is live in the background!"
echo " URL: http://${IP}:${OPENCODE_SERVER_PORT}"
echo "----------------------------------------------------"
echo "Useful commands:"
echo "  tmux attach -t gamedev        # View live logs"
echo "  tmux kill-session -t gamedev  # Stop server"
