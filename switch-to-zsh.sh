#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   Switch to Zsh Shell                  ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    error "zsh is not installed. Please install it first with: sudo pacman -S zsh zsh-completions"
fi

success "zsh is installed at: $(command -v zsh)"

# Check current shell
current_shell=$(basename "$SHELL")
info "Current shell: $current_shell"

if [[ "$current_shell" == "zsh" ]]; then
    success "You are already using zsh!"
    exit 0
fi

# Get zsh path
zsh_path=$(command -v zsh)

# Check if zsh is in /etc/shells
if ! grep -q "^$zsh_path$" /etc/shells; then
    warn "Adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
fi

echo ""
info "This will change your default shell to zsh."
info "You'll need to log out and log back in for the change to take effect."
echo ""

read -p "Do you want to proceed? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    chsh -s "$zsh_path"
    success "Default shell changed to zsh!"
    echo ""
    info "Next steps:"
    echo "  1. Log out and log back in (or restart your terminal)"
    echo "  2. Your zsh dotfiles are already symlinked via stow"
    echo "  3. Enjoy your new zsh setup!"
    echo ""
else
    info "Shell change cancelled."
    exit 0
fi
