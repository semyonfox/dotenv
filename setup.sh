#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
DRY_RUN=false
BACKUP_DIR=""

# Helper functions
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

# Rollback function
rollback() {
    if [[ -n "$BACKUP_DIR" && -d "$BACKUP_DIR" ]]; then
        warn "Rolling back changes..."

        # Unstow if stow was run
        cd "$(dirname "${BASH_SOURCE[0]}")"
        if stow -D home 2>/dev/null; then
            info "Removed symlinks"
        fi

        # Restore from backup
        if [[ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
            cp -r "$BACKUP_DIR"/* "$HOME/" 2>/dev/null || true
            cp -r "$BACKUP_DIR"/.* "$HOME/" 2>/dev/null || true
            success "Restored files from backup"
        fi

        error "Setup failed. Original files have been restored."
    else
        error "Setup failed. No backup to restore."
    fi
}

# Set trap for errors
trap rollback ERR

# Detect OS and package manager
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Install stow based on OS
install_stow() {
    local os=$(detect_os)

    if command -v stow &> /dev/null; then
        success "stow is already installed ($(stow --version | head -1))"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would install stow for $os"
        return 0
    fi

    info "Installing stow for $os..."

    case "$os" in
        arch|endeavouros|manjaro)
            sudo pacman -S --noconfirm stow
            ;;
        ubuntu|debian|pop|linuxmint)
            sudo apt update && sudo apt install -y stow
            ;;
        fedora|rhel|centos)
            sudo dnf install -y stow
            ;;
        opensuse*)
            sudo zypper install -y stow
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                error "Homebrew not found. Please install from https://brew.sh"
            fi
            brew install stow
            ;;
        *)
            error "Unsupported OS: $os. Please install stow manually."
            ;;
    esac

    success "stow installed successfully"
}

# Backup existing dotfiles
backup_existing() {
    BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local files_to_backup=()

    # Check for conflicting files in home directory
    local dotfiles=(.bashrc .bash_aliases .bash_functions .bash_profile .zshrc .zsh_aliases .zsh_functions .zprofile .profile .gitconfig .tmux.conf .wezterm.lua)

    for file in "${dotfiles[@]}"; do
        if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
            files_to_backup+=("$file")
        fi
    done

    # Check for conflicting directories/files in .config
    local config_items=(btop ghostty htop kitty neofetch starship.toml)

    for item in "${config_items[@]}"; do
        if [[ -e "$HOME/.config/$item" && ! -L "$HOME/.config/$item" ]]; then
            files_to_backup+=(".config/$item")
        fi
    done

    if [[ ${#files_to_backup[@]} -eq 0 ]]; then
        info "No existing dotfiles to backup"
        return 0
    fi

    warn "Found existing dotfiles that will conflict:"
    printf '%s\n' "${files_to_backup[@]}"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Would backup these files to $BACKUP_DIR"
        return 0
    fi

    read -p "Backup these files? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p "$BACKUP_DIR"
        for file in "${files_to_backup[@]}"; do
            # Create parent directory structure in backup
            local backup_path="$BACKUP_DIR/$file"
            mkdir -p "$(dirname "$backup_path")"

            mv "$HOME/$file" "$backup_path"
            info "Backed up $file to $BACKUP_DIR/"
        done
        success "Backup created at $BACKUP_DIR"
    else
        error "Cannot proceed with existing files. Please backup manually."
    fi
}

# Deploy dotfiles with stow
deploy_dotfiles() {
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    info "Deploying dotfiles from $dotfiles_dir"

    cd "$dotfiles_dir"

    # Check for conflicts first
    if stow -n home 2>&1 | grep -q "conflict"; then
        warn "Stow detected conflicts. Running backup..."
        backup_existing
    fi

    # Deploy with stow
    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY RUN] Simulating stow deployment..."
        stow -n -v home
        info "[DRY RUN] No changes made to filesystem"
    else
        stow home
        success "Dotfiles deployed successfully"
    fi
}

# Verify installation
verify_installation() {
    info "Verifying installation..."

    local verified=0
    local failed=0

    local dotfiles=(.bashrc .bash_aliases .bash_functions .bash_profile .zshrc .zsh_aliases .zsh_functions .zprofile .profile .gitconfig .tmux.conf .wezterm.lua)

    for file in "${dotfiles[@]}"; do
        if [[ -L "$HOME/$file" ]]; then
            ((verified++))
        else
            ((failed++))
            warn "$file is not a symlink"
        fi
    done

    echo ""
    info "Verification Results:"
    echo "  Verified: $verified"
    [[ $failed -gt 0 ]] && echo "  Failed: $failed" || true
    echo ""

    # Test bashrc
    if bash -c "source ~/.bashrc" &> /dev/null; then
        success ".bashrc loads without errors"
    else
        warn ".bashrc has errors (this might be expected if dependencies are missing)"
    fi

    # Test zshrc if zsh is installed
    if command -v zsh &> /dev/null && [[ -f "$HOME/.zshrc" ]]; then
        if zsh -c "source ~/.zshrc" &> /dev/null; then
            success ".zshrc loads without errors"
        else
            warn ".zshrc has errors (this might be expected if dependencies are missing)"
        fi
    fi
}

# Main installation flow
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run|-n)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --dry-run, -n    Simulate installation without making changes"
                echo "  --help, -h       Show this help message"
                echo ""
                exit 0
                ;;
            *)
                error "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done

    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║   Dotfiles Setup Script                ║"
    echo "║   Device-Aware Installation            ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    info "Detected OS: $(detect_os)"
    echo ""

    # Step 1: Install stow
    install_stow
    echo ""

    # Step 2: Deploy dotfiles
    deploy_dotfiles
    echo ""

    # Step 3: Verify
    if [[ "$DRY_RUN" == false ]]; then
        verify_installation
        echo ""
    fi

    if [[ "$DRY_RUN" == true ]]; then
        success "Dry run complete! No changes were made."
    else
        # Disable rollback trap on success
        trap - ERR
        success "Setup complete!"
        info "Start a new shell or run: source ~/.bashrc"
    fi
    echo ""
}

# Run main function
main "$@"
