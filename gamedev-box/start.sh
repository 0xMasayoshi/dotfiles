#!/usr/bin/env bash
set -e

# Configuration
export OPENCODE_SERVER_PORT="${OPENCODE_SERVER_PORT:-4096}"
export OPENCODE_SERVER_HOSTNAME="${OPENCODE_SERVER_HOSTNAME:-0.0.0.0}"
SESSION_NAME="gamedev"

# ========================================================
# 1. HOST SIDE: Prevent SSH disconnect reaping & forward
# ========================================================
if [ ! -f "/run/.containerenv" ]; then
    # Ensure systemd never reaps background processes on idle disconnect
    if command -v loginctl &>/dev/null; then
        loginctl enable-linger "$USER" &>/dev/null || true
    fi

    # Prompt for password if not set
    if [ -z "$OPENCODE_SERVER_PASSWORD" ]; then
        read -rsp "Enter OpenCode web password: " OPENCODE_SERVER_PASSWORD
        echo
        export OPENCODE_SERVER_PASSWORD
    fi

    echo "=== Launching inside godot-dev container ==="
    exec distrobox enter godot-dev -- env OPENCODE_SERVER_PASSWORD="$OPENCODE_SERVER_PASSWORD" bash "$(realpath "$0")"
fi

# ========================================================
# 2. CONTAINER SIDE: Runtime execution
# ========================================================

# Sanity Check
if ! command -v gh &>/dev/null || ! command -v tmux &>/dev/null; then
    echo "Error: Required tools (gh/tmux) not found inside container. Run 'make setup' first." >&2
    exit 1
fi

# GitHub Auth
if ! gh auth status &>/dev/null; then
    echo "=== GitHub CLI not logged in ==="
    echo "Launching web-based SSH authorization..."
    gh auth login -w -p ssh
fi

# OpenCode Auth Check
AUTH_FILE_1="$HOME/.local/share/opencode/auth.json"
AUTH_FILE_2="$HOME/.config/opencode/auth.json"
if [ ! -f "$AUTH_FILE_1" ] && [ ! -f "$AUTH_FILE_2" ]; then
    echo "=== No OpenCode credentials detected ==="
    echo "Launching one-time interactive login..."
    opencode auth login || true
fi

# Launch or report background tmux session
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "OpenCode is already running in background session '$SESSION_NAME'."
else
    echo "Starting OpenCode web in background session '$SESSION_NAME'..."
    TERM=xterm-256color tmux new-session -d -s "$SESSION_NAME" \
        "opencode web --port $OPENCODE_SERVER_PORT --hostname $OPENCODE_SERVER_HOSTNAME"
fi

IP="$(hostname -I | awk '{print $1}')"
echo "----------------------------------------------------"
echo " OpenCode Web is live in the background!"
echo " URL: http://${IP}:${OPENCODE_SERVER_PORT}"
echo "----------------------------------------------------"
echo "Useful commands:"
echo "  TERM=xterm-256color tmux attach -t gamedev"
echo "  tmux kill-session -t gamedev"
