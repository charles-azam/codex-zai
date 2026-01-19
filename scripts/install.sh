#!/bin/sh
set -e

DIR="${INSTALL_DIR:-$HOME}"
ARCH="$(uname -m)"
[ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ] && BIN="codex-zai-arm64" || BIN="codex-zai"
URL="https://github.com/charles-azam/codex-zai/releases/latest/download/$BIN"

mkdir -p "$DIR"
curl -fsSL "$URL" -o "$DIR/codex-zai"
chmod +x "$DIR/codex-zai"

ZSHRC="$HOME/.zshrc"
BASHRC="$HOME/.bashrc"

touch "$ZSHRC" "$BASHRC"

ALIAS_LINE="alias codex-zai=\"$DIR/codex-zai\""
if ! grep -q "alias codex-zai=" "$ZSHRC" 2>/dev/null; then
  printf '\n%s\n' "$ALIAS_LINE" >> "$ZSHRC"
fi
if ! grep -q "alias codex-zai=" "$BASHRC" 2>/dev/null; then
  printf '\n%s\n' "$ALIAS_LINE" >> "$BASHRC"
fi

echo "Installed codex-zai to $DIR/codex-zai"
