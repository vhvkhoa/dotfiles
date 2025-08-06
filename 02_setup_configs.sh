#!/usr/bin/env bash
set -euo pipefail

echo "🧩 Applying configs..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Neovim config from repo or fallback to NvChad starter ---
if [ -d "$REPO_ROOT/nvim" ]; then
  echo "📦 Installing Neovim config from repo..."
  mkdir -p ~/.config
  if [ -e ~/.config/nvim ] || [ -L ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
  fi
  cp -r "$REPO_ROOT/nvim" ~/.config/nvim
else
  echo "ℹ️ No ./nvim folder; using NvChad starter if absent"
  if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1
    rm -rf ~/.config/nvim/.git
  fi
fi

# Headless plugin sync so UI/dashboard works on first launch
if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+Lazy! sync" "+qall" || true
fi

# --- tmux ---
echo "📦 Installing tmux configuration..."
if ! cmp -s "$REPO_ROOT/tmux/.tmux.conf" ~/.tmux.conf 2>/dev/null; then
  cp "$REPO_ROOT/tmux/.tmux.conf" ~/.tmux.conf
else
  echo "ℹ️ ~/.tmux.conf already up-to-date."
fi

## --- .zshrc ---
if ! cmp -s "$REPO_ROOT/zsh/.zshrc" ~/.zshrc 2>/dev/null; then
  cp "$REPO_ROOT/zsh/.zshrc" ~/.zshrc
else
  echo "ℹ️ ~/.zshrc already up-to-date."
fi

# --- Zsh plugins ---
ZSH_PLUGIN_DIR="$HOME/.zsh_plugins"
mkdir -p "$ZSH_PLUGIN_DIR"
echo "📦 Installing zsh plugins..."
[ -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
[ -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"

# --- Conda: initialize for zsh if present ---
if command -v conda >/dev/null 2>&1; then
  echo "🐍 Initializing conda for zsh..."
  conda init zsh || true
elif [ -x "$HOME/miniconda3/bin/conda" ]; then
  echo "🐍 Initializing conda (miniconda3) for zsh..."
  "$HOME/miniconda3/bin/conda" init zsh || true
elif [ -x "$HOME/anaconda3/bin/conda" ]; then
  echo "🐍 Initializing conda (anaconda3) for zsh..."
  "$HOME/anaconda3/bin/conda" init zsh || true
else
  echo "ℹ️ conda not found; skipping conda init."
fi

# --- oh-my-posh theme + init ---
mkdir -p ~/.poshthemes
cp "$REPO_ROOT/omp/khoa_theme.omp.json" ~/.poshthemes/
chmod 644 ~/.poshthemes/*.omp.json
if command -v oh-my-posh >/dev/null 2>&1; then
  oh-my-posh font install meslo || true
  grep -q 'oh-my-posh init zsh' ~/.zshrc || \
    echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/khoa_theme.omp.json)"' >> ~/.zshrc
fi

# --- WezTerm config copy/link ---
echo "🧩 Setting up WezTerm configuration..."
mkdir -p ~/.config
if [ -d "$REPO_ROOT/wezterm" ]; then
  if [ -d "$HOME/.config/wezterm" ] || [ -L "$HOME/.config/wezterm" ]; then
    mv "$HOME/.config/wezterm" "$HOME/.config/wezterm.bak.$(date +%s)"
  fi
  cp -r "$REPO_ROOT/wezterm" "$HOME/.config/wezterm"
  echo "✅ WezTerm config installed to ~/.config/wezterm"
else
  echo "ℹ️ No 'wezterm' folder found in this repo; skipping config copy."
fi

# --- Default shell to zsh (optional) ---
if command -v chsh >/dev/null 2>&1; then
  chsh -s "$(which zsh)" || true
fi

echo "✅ Configs applied. Open a new terminal or run 'exec zsh'."
