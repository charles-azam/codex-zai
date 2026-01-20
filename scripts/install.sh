#!/bin/sh
set -e

DIR="${INSTALL_DIR:-$HOME}"
ARCH="$(uname -m)"
[ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] && BIN="codex-zai-arm64" || BIN="codex-zai"
URL="https://github.com/charles-azam/codex-zai/releases/latest/download/$BIN"

mkdir -p "$DIR"
curl -fsSL "$URL" -o "$DIR/codex-zai"
chmod +x "$DIR/codex-zai"

if [ -f "$HOME/.zshrc" ]; then
  grep -q "$DIR" "$HOME/.zshrc" 2>/dev/null || printf '\nexport PATH="%s:$PATH"\n' "$DIR" >> "$HOME/.zshrc"
fi
if [ -f "$HOME/.bashrc" ]; then
  grep -q "$DIR" "$HOME/.bashrc" 2>/dev/null || printf '\nexport PATH="%s:$PATH"\n' "$DIR" >> "$HOME/.bashrc"
fi

echo "Installed codex-zai to $DIR/codex-zai"
