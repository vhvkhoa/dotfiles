#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing dependencies..."

has_sudo() {
  command -v sudo >/dev/null 2>&1 || return 1
  if groups "$USER" | grep -Eq '\b(sudo|wheel)\b'; then return 0; fi
  return 1
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍎 Detected macOS"

  # oh-my-posh
  brew list jandedobbeleer/oh-my-posh/oh-my-posh >/dev/null 2>&1 || \
    brew install jandedobbeleer/oh-my-posh/oh-my-posh

  # Ghostty (optional)
  brew list --cask ghostty >/dev/null 2>&1 || brew install --cask ghostty

  # WezTerm (nightly to match your previous script)
  if ! brew list --cask wezterm-nightly >/dev/null 2>&1; then
    echo "📦 Installing WezTerm nightly (macOS)..."
    brew install --cask wezterm-nightly
  else
    echo "✅ WezTerm nightly already installed."
  fi

  # Rust (install only if missing)
  if ! command -v cargo >/dev/null 2>&1; then
    echo "📦 Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "🐧 Detected Linux"

  if has_sudo; then
    sudo apt update && sudo apt install -y zsh git curl wget unzip
  else
    echo "ℹ️ No sudo; skipping apt base packages."
  fi

  # oh-my-posh
  if ! command -v oh-my-posh >/dev/null 2>&1; then
    curl -s https://ohmyposh.dev/install.sh | bash -s
  fi

  # WezTerm (try distro pkg; fallback to .deb)
  if has_sudo; then
    echo "📦 Installing WezTerm (Linux, with sudo)..."
    if command -v apt >/dev/null 2>&1; then
      if ! sudo apt install -y wezterm; then
        echo "ℹ️ 'wezterm' not in apt or failed; trying GitHub .deb fallback…"
        DEB_URL="$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest \
          | grep -oE 'https://[^"]+Ubuntu[^"]+\.deb' | head -n1)"
        if [[ -z "$DEB_URL" ]]; then
          DEB_URL="$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest \
            | grep -oE 'https://[^"]+Debian[^"]+\.deb' | head -n1)"
        fi
        if [[ -n "$DEB_URL" ]]; then
          TMP_DEB="$(basename "$DEB_URL")"
          curl -LO "$DEB_URL"
          sudo dpkg -i "$TMP_DEB" || sudo apt -f install -y
          rm -f "$TMP_DEB"
        else
          echo "⚠️ Couldn’t locate a .deb asset automatically. Install WezTerm manually: https://wezterm.org"
        fi
      fi
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y wezterm@nightly || echo "⚠️ Install WezTerm manually for your distro."
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm wezterm || echo "⚠️ Install WezTerm manually for your distro."
    else
      echo "⚠️ Unknown package manager. Install WezTerm manually: https://wezterm.org"
    fi
  else
    echo "⏭️  Skipping WezTerm install (no sudo privileges detected)."
  fi

  # Neovim (Linux tarball for portability; same behavior as before)
  echo "📦 Installing Neovim (Linux tarball)..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  if has_sudo; then
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  else
    echo "ℹ️ No sudo; extracting to \$HOME/.local instead."
    rm -rf "$HOME/.local/nvim"
    mkdir -p "$HOME/.local"
    tar -C "$HOME/.local" -xzf nvim-linux-x86_64.tar.gz
  fi

  # Rust (install only if missing)
  if ! command -v cargo >/dev/null 2>&1; then
    echo "📦 Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
else
  echo "⚠️ Unsupported OS: $OSTYPE"
fi

echo "✅ Dependencies installed."
