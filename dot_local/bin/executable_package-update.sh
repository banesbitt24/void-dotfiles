#!/bin/bash
set -e

# Prompt for password upfront and keep sudo session active
echo "🔐 This script requires sudo privileges for package updates."
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

echo "🔄 Checking for package updates..."
echo

# Sync repository data first
echo "📦 Synchronizing repository data..."
sudo xbps-install -S

# Check for updates
updates=$(xbps-install -un 2>/dev/null | wc -l)

if [ "$updates" -eq 0 ]; then
    echo "✅ System is up to date! No packages need updating."
    exit 0
fi

echo "📊 Found $updates package(s) that can be updated:"
echo
xbps-install -un | sed 's/^/  • /'
echo

read -p "Proceed with updates? [Y/n] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    echo "⬆️  Updating packages..."
    sudo xbps-install -u
    
    echo
    echo "✅ System update completed!"
    
    # Update locate database if available
    if command -v updatedb &> /dev/null; then
      echo "📝 Updating locate database..."
      sudo updatedb
    fi
    
    # Check if kernel was updated and suggest reboot
    if xbps-install -un 2>/dev/null | grep -q "linux[0-9]"; then
        echo
        echo "⚠️  Kernel update detected. Consider rebooting your system."
    fi
else
    echo "Update cancelled."
fi

# Clean up background process
kill $sudo_keepalive_pid 2>/dev/null