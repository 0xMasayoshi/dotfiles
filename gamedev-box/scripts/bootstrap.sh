#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$SCRIPT_DIR"/*.sh

"$SCRIPT_DIR/install-opencode.sh"
"$SCRIPT_DIR/install-godot.sh"
