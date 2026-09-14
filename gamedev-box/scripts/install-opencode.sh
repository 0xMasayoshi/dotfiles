#!/usr/bin/env bash
set -e

if ! command -v opencode &> /dev/null; then
    echo "=== Installing OpenCode CLI ==="
    curl -fsSL https://opencode.ai/install | bash
fi
