#!/usr/bin/env bash

#==============================================================================
# Neovim Configuration Installation Script
# 
# This script installs a complete Neovim development environment with:
# - Nord theme
# - LSP support for Go, Terraform, Docker, Shell
# - AI integration (Copilot/Codeium)
# - Modern plugin management
#==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NVIM_CONFIG_REPO="git@github.com/banesbitt24/nvim-config.git"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Error handler
handle_error() {
    log_error "Installation failed at line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Welcome message
clear
echo -e "${BLUE}"
cat << "EOF"
  _   _         __     ___           
 | \ | | ___  __\ \   / (_)_ __ ___  
 |  \| |/ _ \/ _ \ \ / /| | '_ ` _ \ 
 | |\  |  __/ (_) \ V / | | | | | | |
 |_| \_|\___|\___/ \_/  |_|_| |_| |_|
                                     
  Configuration Installer
EOF
echo -e "${NC}"
echo ""

# Check OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
log_info "Detected OS: $OS"

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install dependencies based on OS
install_dependencies() {
    log_info "Installing system dependencies..."
    
    case $OS in
        macos)
            if ! command_exists brew; then
                log_error "Homebrew not found. Please install it first: https://brew.sh"
                exit 1
            fi
            
            log_info "Updating Homebrew..."
            brew update
            
            # Install required packages
            local packages=("neovim" "git" "node" "ripgrep" "fd" "fzf" "luarocks" "gnu-sed")
            for pkg in "${packages[@]}"; do
                if brew list "$pkg" &>/dev/null; then
                    log_info "$pkg is already installed"
                else
                    log_info "Installing $pkg..."
                    brew install "$pkg"
                fi
            done
            ;;
            
        debian)
            log_info "Updating package list..."
            sudo apt update
            
            # Add Neovim PPA for latest version
            if ! command_exists add-apt-repository; then
                sudo apt install -y software-properties-common
            fi
            
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
            sudo apt update
            
            # Install packages
            sudo apt install -y \
                neovim \
                git \
                nodejs \
                npm \
                ripgrep \
                fd-find \
                fzf \
                luarocks \
                build-essential \
                python3-pip
                
            # Create fd symlink
            if ! command_exists fd; then
                sudo ln -s $(which fdfind) /usr/local/bin/fd
            fi
            ;;
            
        arch)
            log_info "Installing packages with pacman..."
            sudo pacman -S --needed --noconfirm \
                neovim \
                git \
                nodejs \
                npm \
                ripgrep \
                fd \
                fzf \
                luarocks \
                base-devel \
                python-pip
            ;;
            
        *)
            log_warning "Unsupported OS. Please install dependencies manually:"
            echo "  - Neovim >= 0.9.0"
            echo "  - Git"
            echo "  - Node.js & npm"
            echo "  - ripgrep"
            echo "  - fd"
            echo "  - fzf"
            echo "  - luarocks"
            read -p "Continue anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
}

# Check Neovim version
check_neovim_version() {
    if ! command_exists nvim; then
        log_error "Neovim not found. Please install Neovim >= 0.9.0"
        exit 1
    fi
    
    local nvim_version=$(nvim --version | head -n1 | sed 's/NVIM v//')
    local required_version="0.9.0"
    
    if [ "$(printf '%s\n' "$required_version" "$nvim_version" | sort -V | head -n1)" != "$required_version" ]; then
        log_error "Neovim version $nvim_version is too old. Please upgrade to >= $required_version"
        exit 1
    fi
    
    log_success "Neovim version $nvim_version meets requirements"
}

# Install language-specific tools
install_language_tools() {
    log_info "Installing language-specific tools..."
    
    # Go tools
    if command_exists go; then
        log_info "Installing Go tools..."
        go install golang.org/x/tools/gopls@latest || log_warning "Failed to install gopls"
        go install github.com/go-delve/delve/cmd/dlv@latest || log_warning "Failed to install delve"
    else
        log_warning "Go not found. Skipping Go tools installation"
    fi
    
    # Terraform tools
    if command_exists terraform; then
        log_info "Terraform found"
    else
        log_warning "Terraform not found. Install it for Terraform support"
    fi
    
    # Node packages
    if command_exists npm; then
        log_info "Installing global npm packages..."
        npm install -g neovim || log_warning "Failed to install neovim npm package"
    fi
    
    # Python packages
    if command_exists pip3; then
        log_info "Installing Python packages..."
        pip3 install --user pynvim || log_warning "Failed to install pynvim"
    fi
}

# Backup existing configuration
backup_config() {
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        log_info "Backing up existing Neovim configuration to $BACKUP_DIR"
        mv "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
        log_success "Backup completed"
    fi
}

# Clone configuration
clone_config() {
    log_info "Cloning Neovim configuration..."
    
    # Create config directory if it doesn't exist
    mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
    
    # Clone the repository
    if git clone "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR"; then
        log_success "Configuration cloned successfully"
    else
        log_error "Failed to clone configuration repository"
        exit 1
    fi
}

# Post-installation setup
post_install() {
    log_info "Running post-installation setup..."
    
    # Create directories for undo files
    mkdir -p "$HOME/.local/share/nvim/undo"
    
    # Install plugins
    log_info "Installing Neovim plugins (this may take a while)..."
    nvim --headless "+Lazy! sync" +qa
    
    # Install treesitter parsers
    log_info "Installing Treesitter parsers..."
    nvim --headless "+TSUpdateSync" +qa || log_warning "Some Treesitter parsers failed to install"
}

# Health check
health_check() {
    log_info "Running health check..."
    nvim --headless "+checkhealth" "+w! /tmp/nvim-health.log" +qa
    
    if grep -q "ERROR" /tmp/nvim-health.log; then
        log_warning "Some health checks failed. Check with :checkhealth in Neovim"
    else
        log_success "Health check passed"
    fi
    
    rm -f /tmp/nvim-health.log
}

# Main installation
main() {
    log_info "Starting Neovim configuration installation..."
    
    # Check for required commands
    local required_commands=("git" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            log_error "$cmd is required but not installed"
            exit 1
        fi
    done
    
    # Installation steps
    install_dependencies
    check_neovim_version
    install_language_tools
    backup_config
    clone_config
    post_install
    health_check
    
    # Success message
    echo ""
    log_success "🎉 Neovim configuration installed successfully!"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "1. Open Neovim: nvim"
    echo "2. Wait for plugins to install"
    echo "3. Run :checkhealth to verify setup"
    echo "4. Enjoy your new development environment!"
    echo ""
    echo -e "${BLUE}Key bindings:${NC}"
    echo "• Leader key: <Space>"
    echo "• Find files: <Space>ff"
    echo "• Toggle file explorer: <Space>e"
    echo "• View all keymaps: :help keymaps"
    echo ""
    
    # Ask to open Neovim
    read -p "Would you like to open Neovim now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nvim
    fi
}

# Run main function
main "$@"

