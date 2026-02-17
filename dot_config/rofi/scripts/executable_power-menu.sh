#!/bin/bash

# Rofi Power Menu Script
# Uses the same theme as clipboard and application launcher

# Power management options with icons
options="  Lock\n  Logout\n  Sleep\n  Hibernate\n  Reboot\n  Shutdown"

# Show rofi menu and capture selection
chosen=$(echo -e "$options" | rofi -theme /home/brandon/.config/rofi/themes/nord-waybar.rasi -dmenu -p "Power Menu" -lines 6)

# Execute the selected action
case "$chosen" in
    "  Lock")
        # Use betterlockscreen to lock the session
        betterlockscreen -l
        ;;
    "  Logout")
        # Logout from Qtile
        qtile cmd-obj -o cmd -f shutdown
        ;;
    "  Sleep")
        # Suspend the system using safe suspend script
        /home/brandon/.local/bin/safe-suspend.sh suspend
        ;;
    "  Hibernate")
        # Hibernate the system using safe suspend script
        /home/brandon/.local/bin/safe-suspend.sh hibernate
        ;;
    "  Reboot")
        # Reboot the system using loginctl (elogind)
        loginctl reboot
        ;;
    "  Shutdown")
        # Shutdown the system using loginctl (elogind)
        loginctl poweroff
        ;;
esac
