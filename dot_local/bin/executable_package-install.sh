#!/bin/bash
set -e

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "fzf is not installed. Install it with: sudo xbps-install -S fzf"
    exit 1
fi

# Prompt for password upfront and keep sudo session active
echo "🔐 This script requires sudo privileges for package installation."
sudo -v || { echo "❌ Failed to authenticate. Exiting."; exit 1; }

# Keep sudo session alive in background
while true; do
    sleep 300
    sudo -n true
    if [ $? -ne 0 ]; then
        break
    fi
done 2>/dev/null &
sudo_keepalive_pid=$!

fzf_args=(
  --multi
  --preview 'xbps-query -Rs {1} 2>/dev/null || echo "Package information not available"'
  --preview-label='alt-p: toggle description, alt-j/k: scroll, tab: multi-select, F11: maximize'
  --preview-label-pos='bottom'
  --preview-window 'down:65%:wrap'
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
  --color 'pointer:green,marker:green'
  --prompt='Select packages to install: '
  --header='Use TAB to select multiple packages, ENTER to install'
)

echo "Loading available packages..."
pkg_names=$(xbps-query -Rs '' | awk '{print $2}' | cut -d'-' -f1 | sort -u | fzf "${fzf_args[@]}")

if [[ -n "$pkg_names" ]]; then
  echo "Selected packages:"
  echo "$pkg_names" | sed 's/^/  - /'
  echo
  
  read -p "Proceed with installation? [Y/n] " -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    # Convert newline-separated selections to space-separated for xbps-install
    echo "Installing packages..."
    echo "$pkg_names" | tr '\n' ' ' | xargs sudo xbps-install -S
    
    echo "✅ Installation completed!"
    
    # Update locate database if available
    if command -v updatedb &> /dev/null; then
      echo "Updating locate database..."
      sudo updatedb
    fi
  else
    echo "Installation cancelled."
  fi
else
  echo "No packages selected."
fi

# Clean up background process
kill $sudo_keepalive_pid 2>/dev/null
