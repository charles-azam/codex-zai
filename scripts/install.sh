#!/bin/sh
set -e

BASE_URL="https://github.com/charles-azam/codex-zai/releases/latest/download"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

ARCH="$(uname -m)"
case "$ARCH" in
  aarch64|arm64)
    ASSET="codex-zai-arm64"
    ;;
  x86_64|amd64)
    ASSET="codex-zai"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

tmp="$(mktemp -t codex-zai.XXXXXX)"
cleanup() { rm -f "$tmp"; }
trap cleanup EXIT

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$BASE_URL/$ASSET" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$tmp" "$BASE_URL/$ASSET"
else
  echo "Missing downloader: install curl or wget." >&2
  exit 1
fi

chmod +x "$tmp"
mkdir -p "$INSTALL_DIR"
mv "$tmp" "$INSTALL_DIR/codex-zai"

rc="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && rc="$HOME/.bashrc"
if ! grep -q "$INSTALL_DIR" "$rc" 2>/dev/null; then
  printf '\nexport PATH="%s:$PATH"\n' "$INSTALL_DIR" >> "$rc"
  echo "Added $INSTALL_DIR to PATH in $rc"
fi

echo "Installed codex-zai to $INSTALL_DIR/codex-zai"
