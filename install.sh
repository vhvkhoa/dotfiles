#!/bin/bash

set -e

echo "🔧 Setting up dev environment..."

# OS-specific install
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍎 Detected macOS"
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
  brew install --cask ghostty
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "🐧 Detected Linux"
  sudo apt update && sudo apt install -y zsh git curl wget unzip
  curl -s https://ohmyposh.dev/install.sh | bash -s
  # Install Ghostty manually or build from source: https://github.com/mitchellh/ghostty
fi

# Install NvChad
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
fi

# Setup tmux config
echo "📦 Installing tmux configuration..."
ln -sf "$PWD/tmux/.tmux.conf" ~/.tmux.conf

# Link .zshrc
ln -sf "$PWD/zsh/.zshrc" ~/.zshrc

# Link oh-my-posh theme
mkdir -p ~/.poshthemes
cp "$PWD/omp/khoa_theme.omp.json" ~/.poshthemes/
chmod 644 ~/.poshthemes/*.omp.json

# Set oh-my-posh init in .zshrc if not already
oh-my-posh font install meslo
grep -q 'oh-my-posh init zsh' ~/.zshrc || echo 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/khoa_theme.omp.json)"' >> ~/.zshrc

# Set default shell to zsh
chsh -s $(which zsh)

echo "✅ Done! Launch a new terminal or run \`zsh\`."

