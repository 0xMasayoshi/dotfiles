#!/usr/bin/env bash
set -e

GODOT_VERSION="4.3-stable"
TEMPLATES_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}"

# 1. Engine Binary
if ! command -v godot &> /dev/null; then
    echo "=== Installing Godot Binary ($GODOT_VERSION) ==="
    curl -fsSL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip" -o /tmp/godot.zip
    unzip -q /tmp/godot.zip -d /tmp/
    mkdir -p ~/.local/bin
    mv "/tmp/Godot_v${GODOT_VERSION}_linux.x86_64" ~/.local/bin/godot
    chmod +x ~/.local/bin/godot
    rm -f /tmp/godot.zip
fi

# 2. HTML5 / Web Export Templates
if [ ! -d "$TEMPLATES_DIR" ]; then
    echo "=== Installing Export Templates ==="
    mkdir -p "$TEMPLATES_DIR"
    curl -fsSL "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_export_templates.tpz" -o /tmp/templates.zip
    unzip -q /tmp/templates.zip -d /tmp/templates_extract
    mv /tmp/templates_extract/templates/* "$TEMPLATES_DIR/"
    rm -rf /tmp/templates.zip /tmp/templates_extract
fi
