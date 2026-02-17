#!/bin/bash

# Void Linux Package Manager Rofi Menu
# Simple direct execution version

# Menu options with icons
options="📦 Install Packages
🗑️ Remove Packages
⬆️ Update System
📊 List Installed
🔍 Search Packages
🔧 Clean Cache"

# Launch rofi with nord theme
choice=$(echo "$options" | rofi -dmenu -p "Package Manager" -theme /home/brandon/.config/rofi/themes/nord-waybar.rasi -i)

case "$choice" in
    "📦 Install Packages")
        ghostty -e /home/brandon/.local/bin/package-install.sh
        ;;
    "🗑️ Remove Packages")
        ghostty -e /home/brandon/.local/bin/package-remove.sh
        ;;
    "⬆️ Update System")
        ghostty -e /home/brandon/.local/bin/package-update.sh
        ;;
    "📊 List Installed")
        # Show installed packages in rofi
        installed=$(xbps-query -l | awk '{print $2}' | cut -d'-' -f1 | sort -u)
        echo "$installed" | rofi -dmenu -p "Installed Packages" -theme /home/brandon/.config/rofi/themes/nord-waybar.rasi -no-custom
        ;;
    "🔍 Search Packages")
        # Interactive search
        query=$(echo "" | rofi -dmenu -p "Search packages" -theme /home/brandon/.config/rofi/themes/nord-waybar.rasi)
        if [[ -n "$query" ]]; then
            results=$(xbps-query -Rs "$query" | head -20 | awk '{print $2}' | cut -d'-' -f1)
            if [[ -n "$results" ]]; then
                echo "$results" | rofi -dmenu -p "Search Results: $query" -theme /home/brandon/.config/rofi/themes/nord-waybar.rasi -no-custom
            else
                echo "No packages found matching '$query'" | rofi -dmenu -p "No Results" -theme /home/brandon/.config/rofi/themes/nord-waybar.rasi -no-custom
            fi
        fi
        ;;
    "🔧 Clean Cache")
        ghostty -e bash -c "echo '🔐 Cleaning package cache requires sudo privileges...'; sudo xbps-remove -O && echo '✅ Cache cleaned successfully!' || echo '❌ Failed to clean cache.'; read -p 'Press Enter to continue...'"
        ;;
    *)
        exit 0
        ;;
esac