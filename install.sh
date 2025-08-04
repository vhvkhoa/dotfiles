#!/bin/bash
set -e

echo "🔧 Setting up dev environment..."

has_sudo() {
  command -v sudo >/dev/null 2>&1 || return 1
  # treat being in sudo or wheel as having sudo privileges
  if groups "$USER" | grep -Eq '\b(sudo|wheel)\b'; then
    return 0
  fi
  return 1
}

# OS-specific install
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍎 Detected macOS"
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
  brew install --cask ghostty

  # --- WezTerm (macOS) ---
  if ! brew list --cask wezterm >/dev/null 2>&1; then
    echo "📦 Installing WezTerm (macOS)..."
    brew install --cask wezterm-nightly
  else
    echo "✅ WezTerm already installed (macOS)."
  fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "🐧 Detected Linux"
  sudo apt update && sudo apt install -y zsh git curl wget unzip
  curl -s https://ohmyposh.dev/install.sh | bash -s
  # Install Ghostty manually or build from source: https://github.com/mitchellh/ghostty

  # --- WezTerm (Linux, only if user has sudo) ---
  if has_sudo; then
    echo "📦 Installing WezTerm (Linux, with sudo)..."
    if command -v apt >/dev/null 2>&1; then
      # Try apt package first
      if ! sudo apt install -y wezterm; then
        echo "ℹ️ 'wezterm' not in apt or failed; trying GitHub .deb fallback…"
        # Grab latest Ubuntu/Debian .deb from GitHub releases
        DEB_URL="$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest \
          | grep -oE 'https://[^"]+Ubuntu[^"]+\.deb' \
          | head -n1)"
        if [[ -z "$DEB_URL" ]]; then
          # Fallback match (older naming / Debian)
          DEB_URL="$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest \
            | grep -oE 'https://[^"]+Debian[^"]+\.deb' \
            | head -n1)"
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
fi

# Neovim (Linux tarball for portability)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# Install NvChad
if [ -d "$PWD/nvim" ]; then
  echo "📦 Installing Neovim config from repo..."
  mkdir -p ~/.config

  # backup any existing config
  if [ -e ~/.config/nvim ] || [ -L ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
  fi

  # use a symlink (easy to iterate on); switch to cp -R if you prefer a copy
  ln -sfn "$PWD/nvim" ~/.config/nvim
else
  echo "ℹ️ No ./nvim folder in this repo; falling back to NvChad starter"
  if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1
    rm -rf ~/.config/nvim/.git
  fi
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Setup tmux config
echo "📦 Installing tmux configuration..."
ln -sf "$PWD/tmux/.tmux.conf" ~/.tmux.conf

# Zsh Plugins
ZSH_PLUGIN_DIR="$HOME/.zsh_plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

echo "📦 Installing zsh plugins..."
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
fi
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
fi

# Link .zshrc
ln -sf "$PWD/zsh/.zshrc" ~/.zshrc

# Link oh-my-posh theme
mkdir -p ~/.poshthemes
cp "$PWD/omp/khoa_theme.omp.json" ~/.poshthemes/
chmod 644 ~/.poshthemes/*.omp.json

# Set oh-my-posh init in .zshrc if not already
oh-my-posh font install meslo
grep -q 'oh-my-posh init zsh' ~/.zshrc || echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/khoa_theme.omp.json)"' >> ~/.zshrc

# --- WezTerm config copy/link ---
echo "🧩 Setting up WezTerm configuration..."
mkdir -p ~/.config
if [ -d "$PWD/wezterm" ]; then
  # backup existing config if present
  if [ -d "$HOME/.config/wezterm" ] || [ -L "$HOME/.config/wezterm" ]; then
    mv "$HOME/.config/wezterm" "$HOME/.config/wezterm.bak.$(date +%s)"
  fi
  # copy (use cp -R to make an independent copy; switch to ln -sfn if you prefer symlink)
  cp -R "$PWD/wezterm" "$HOME/.config/wezterm"
  echo "✅ WezTerm config installed to ~/.config/wezterm"
else
  echo "ℹ️ No 'wezterm' folder found in this repo; skipping config copy."
fi

# Set default shell to zsh
if command -v chsh >/dev/null 2>&1; then
  chsh -s "$(which zsh)" || true
fi

echo "✅ Done! Launch a new terminal or run 'zsh'."
