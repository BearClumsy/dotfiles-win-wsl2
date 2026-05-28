#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 1. Install stow ---
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  sudo apt-get update && sudo apt-get install -y stow
fi

# --- 2. Symlink dotfiles ---
cd "$DOTFILES_DIR"

mkdir -p "$HOME/.config"

echo "Stowing ~/.config packages..."
stow --target="$HOME/.config" .

echo "Stowing ~/ packages..."
stow --target="$HOME" zsh p10k idea

# --- 3. Install apt packages ---
echo "Installing packages..."
sudo apt-get update
sudo apt-get install -y \
  tmux \
  zsh \
  fzf \
  bat \
  jq \
  git \
  curl \
  unzip \
  ripgrep \
  fd-find \
  ffmpegthumbnailer \
  poppler-utils \
  libimage-exiftool-perl \
  gcc \
  make

# bat is installed as 'batcat' on Ubuntu — alias it
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
  export PATH="$HOME/.local/bin:$PATH"
fi

# fd is installed as 'fdfind' on Ubuntu — alias it
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
  export PATH="$HOME/.local/bin:$PATH"
fi

# --- 4. Install Neovim (appimage — apt version is often too old) ---
if ! command -v nvim &>/dev/null; then
  echo "Installing Neovim..."
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64) NVIM_ARCH="linux-arm64" ;;
    *)       NVIM_ARCH="linux-x86_64" ;;
  esac
  curl -Lo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz"
  sudo tar -C /opt -xzf /tmp/nvim.tar.gz
  sudo ln -sf /opt/nvim-${NVIM_ARCH}/bin/nvim /usr/local/bin/nvim
  rm /tmp/nvim.tar.gz
else
  echo "Neovim already installed, skipping."
fi

# --- 5. Install eza ---
if ! command -v eza &>/dev/null; then
  echo "Installing eza..."
  sudo apt-get install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo apt-get update
  sudo apt-get install -y eza
else
  echo "eza already installed, skipping."
fi

# --- 6. Install lazygit ---
if ! command -v lazygit &>/dev/null; then
  echo "Installing lazygit..."
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64) LG_ARCH="arm64" ;;
    *)       LG_ARCH="x86_64" ;;
  esac
  LG_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VERSION}_Linux_${LG_ARCH}.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
  rm /tmp/lazygit /tmp/lazygit.tar.gz
else
  echo "lazygit already installed, skipping."
fi

# --- 7. Install yazi ---
if ! command -v yazi &>/dev/null; then
  echo "Installing yazi..."
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64) YAZI_ARCH="aarch64-unknown-linux-musl" ;;
    *)       YAZI_ARCH="x86_64-unknown-linux-musl" ;;
  esac
  curl -Lo /tmp/yazi.zip \
    "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${YAZI_ARCH}.zip"
  unzip -q /tmp/yazi.zip -d /tmp/yazi
  sudo install /tmp/yazi/yazi-${YAZI_ARCH}/yazi /usr/local/bin/yazi
  rm -rf /tmp/yazi.zip /tmp/yazi
else
  echo "yazi already installed, skipping."
fi

# --- 8. Install lazydocker ---
if ! command -v lazydocker &>/dev/null; then
  echo "Installing lazydocker..."
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64) LD_ARCH="arm64" ;;
    *)       LD_ARCH="x86_64" ;;
  esac
  LD_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" \
    | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazydocker.tar.gz \
    "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LD_VERSION}_Linux_${LD_ARCH}.tar.gz"
  tar xf /tmp/lazydocker.tar.gz -C /tmp lazydocker
  sudo install /tmp/lazydocker /usr/local/bin
  rm /tmp/lazydocker /tmp/lazydocker.tar.gz
else
  echo "lazydocker already installed, skipping."
fi

# --- 9. Install git-delta ---
if ! command -v delta &>/dev/null; then
  echo "Installing git-delta..."
  ARCH=$(uname -m)
  case "$ARCH" in
    aarch64) DELTA_ARCH="aarch64-unknown-linux-musl" ;;
    *)       DELTA_ARCH="x86_64-unknown-linux-musl" ;;
  esac
  DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" \
    | grep -Po '"tag_name": "\K[^"]*')
  curl -Lo /tmp/delta.tar.gz \
    "https://github.com/dandavison/delta/releases/latest/download/delta-${DELTA_VERSION}-${DELTA_ARCH}.tar.gz"
  tar xf /tmp/delta.tar.gz -C /tmp
  sudo install /tmp/delta-${DELTA_VERSION}-${DELTA_ARCH}/delta /usr/local/bin
  rm -rf /tmp/delta.tar.gz "/tmp/delta-${DELTA_VERSION}-${DELTA_ARCH}"
else
  echo "git-delta already installed, skipping."
fi

# --- 10. Install thefuck ---
if ! command -v thefuck &>/dev/null; then
  echo "Installing thefuck..."
  sudo apt-get install -y pipx python3-setuptools
  pipx install thefuck
  export PATH="$HOME/.local/bin:$PATH"
else
  echo "thefuck already installed, skipping."
fi

# --- 10. Install Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed, skipping."
fi

# --- 11. Install Powerlevel10k ---
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
else
  echo "Powerlevel10k already installed, skipping."
fi

# --- 12. Install zsh-autosuggestions ---
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already installed, skipping."
fi

# --- 13. Install TPM (Tmux Plugin Manager) ---
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
else
  echo "TPM already installed, skipping."
fi

# --- 14. Install zoxide ---
if ! command -v zoxide &>/dev/null; then
  echo "Installing zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
else
  echo "zoxide already installed, skipping."
fi

# --- 15. Install Hack Nerd Font ---
FONT_DIR="$HOME/.local/share/fonts"
if ! fc-list | grep -qi "HackNerdFont"; then
  echo "Installing Hack Nerd Font..."
  mkdir -p "$FONT_DIR"
  HACK_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz"
  curl -Lo /tmp/HackNerdFont.tar.xz "$HACK_URL"
  tar -xf /tmp/HackNerdFont.tar.xz -C "$FONT_DIR"
  rm /tmp/HackNerdFont.tar.xz
  fc-cache -fv "$FONT_DIR"
else
  echo "Hack Nerd Font already installed, skipping."
fi

# --- 17. Set zsh as default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Close and reopen Alacritty"
echo "  2. Inside tmux press Ctrl+A then I to install tmux plugins"
