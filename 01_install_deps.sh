#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing dependencies..."

has_sudo() {
  command -v sudo >/dev/null 2>&1 || return 1
  if groups "$USER" | grep -Eq '\b(sudo|wheel)\b'; then return 0; fi
  return 1
}

install_tpm() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "ℹ️ tmux not installed; skipping tpm install."
    return
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo "⚠️ git not found; cannot install tpm."
    return
  fi

  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ -d "$tpm_dir/.git" ]; then
    echo "ℹ️ tmux plugin manager already installed."
    return
  fi

  echo "📦 Installing tmux plugin manager (tpm)..."
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

install_tmux_plugins() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ ! -x "$tpm_dir/bin/install_plugins" ]; then
    echo "ℹ️ tpm not found; skipping tmux plugin install."
    return
  fi

  echo "📦 Installing tmux plugins via tpm..."
  TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins" "$tpm_dir/bin/install_plugins" || \
    echo "⚠️ tmux plugin install failed; try inside tmux with prefix + I."
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍎 Detected macOS"

  # oh-my-posh
  brew list jandedobbeleer/oh-my-posh/oh-my-posh >/dev/null 2>&1 || \
    brew install jandedobbeleer/oh-my-posh/oh-my-posh

  # tmux (needed for TPM)
  brew list tmux >/dev/null 2>&1 || brew install tmux

  # Ghostty (optional)
  brew list --cask ghostty >/dev/null 2>&1 || brew install --cask ghostty

  # WezTerm (nightly cask name changed to wezterm@nightly; fall back to stable)
  if brew list --cask wezterm@nightly >/dev/null 2>&1; then
    echo "✅ WezTerm nightly already installed."
  elif brew info --cask wezterm@nightly >/dev/null 2>&1; then
    echo "📦 Installing WezTerm nightly (macOS)..."
    brew install --cask wezterm@nightly
  else
    echo "ℹ️ Nightly cask not found; installing stable WezTerm instead."
    brew list --cask wezterm >/dev/null 2>&1 || brew install --cask wezterm
  fi

  # Rust (install only if missing)
  if ! command -v cargo >/dev/null 2>&1; then
    echo "📦 Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi

  install_tpm
  install_tmux_plugins

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "🐧 Detected Linux"

  if has_sudo; then
    sudo apt update && sudo apt install -y zsh git curl wget unzip tmux
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

  install_tpm
  install_tmux_plugins
else
  echo "⚠️ Unsupported OS: $OSTYPE"
fi

echo "✅ Dependencies installed."
