#!/bin/bash
set -e

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "fzf is not installed. Install it with: sudo xbps-install -S fzf"
    exit 1
fi

# Prompt for password upfront and keep sudo session active
echo "🔐 This script requires sudo privileges for package removal."
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
  --preview 'xbps-query -f {1} 2>/dev/null | head -20 || echo "No files listed for this package"'
  --preview-label='alt-p: toggle files, alt-j/k: scroll, tab: multi-select, F11: maximize'
  --preview-label-pos='bottom'
  --preview-window 'down:65%:wrap'
  --bind 'alt-p:toggle-preview'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-k:preview-up,alt-j:preview-down'
  --color 'pointer:red,marker:red'
  --prompt='Select packages to remove: '
  --header='Use TAB to select multiple packages, ENTER to remove'
)

echo "Loading installed packages..."
pkg_names=$(xbps-query -l | awk '{print $2}' | cut -d'-' -f1 | sort -u | fzf "${fzf_args[@]}")

if [[ -n "$pkg_names" ]]; then
  echo "Selected packages for removal:"
  echo "$pkg_names" | sed 's/^/  - /'
  echo
  echo "⚠️  WARNING: This will remove the selected packages and their dependencies!"
  echo
  
  read -p "Proceed with removal? [y/N] " -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Convert newline-separated selections to space-separated for xbps-remove
    echo "Removing packages..."
    echo "$pkg_names" | tr '\n' ' ' | xargs sudo xbps-remove -R
    
    echo "🗑️  Removal completed!"
    
    # Update locate database if available
    if command -v updatedb &> /dev/null; then
      echo "Updating locate database..."
      sudo updatedb
    fi
  else
    echo "Removal cancelled."
  fi
else
  echo "No packages selected."
fi

# Clean up background process
kill $sudo_keepalive_pid 2>/dev/null