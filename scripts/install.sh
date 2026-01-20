#!/bin/sh
set -e

DIR="${INSTALL_DIR:-$HOME}"
ARCH="$(uname -m)"
[ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] && BIN="codex-zai-arm64" || BIN="codex-zai"
URL="https://github.com/charles-azam/codex-zai/releases/latest/download/$BIN"

mkdir -p "$DIR"
curl -fsSL "$URL" -o "$DIR/codex-zai"
chmod +x "$DIR/codex-zai"

RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && RC="$HOME/.bashrc"
grep -q "$DIR" "$RC" 2>/dev/null || printf '\nexport PATH="%s:$PATH"\n' "$DIR" >> "$RC"

echo "Installed codex-zai to $DIR/codex-zai"
