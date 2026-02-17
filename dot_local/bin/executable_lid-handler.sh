#!/bin/bash

# Power-aware lid switch handler
# Suspends on AC power, hibernates on battery power
# Usage: lid-handler.sh <open|close>

LOG_FILE="/tmp/power-management.log"

log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to check if on AC power
is_on_ac_power() {
    # Check multiple possible AC adapter paths
    for ac_path in /sys/class/power_supply/A{C,DP}*; do
        if [ -r "$ac_path/online" ]; then
            local online=$(cat "$ac_path/online" 2>/dev/null)
            if [ "$online" = "1" ]; then
                return 0  # On AC power
            fi
        fi
    done
    
    # Also check ADP1 (common ACPI name)
    if [ -r /sys/class/power_supply/ADP1/online ]; then
        local online=$(cat /sys/class/power_supply/ADP1/online 2>/dev/null)
        if [ "$online" = "1" ]; then
            return 0  # On AC power
        fi
    fi
    
    return 1  # On battery power
}

# Handle lid switch events
case "$1" in
    close)
        log "Lid handler: Lid closed, checking power source..."
        
        if is_on_ac_power; then
            log "Lid handler: On AC power, suspending..."
            /home/brandon/.local/bin/safe-suspend.sh suspend
        else
            log "Lid handler: On battery power, hibernating..."
            /home/brandon/.local/bin/safe-suspend.sh hibernate
        fi
        ;;
    open)
        log "Lid handler: Lid opened"
        # Call resume function to reload WiFi driver if needed
        /home/brandon/.local/bin/safe-suspend.sh resume
        ;;
    *)
        log "Lid handler: Unknown lid action: $1"
        ;;
esac