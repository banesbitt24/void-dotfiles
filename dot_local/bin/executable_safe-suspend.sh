#!/bin/bash

# Safe suspend script that removes problematic WiFi driver before suspend/hibernate
# and can reload it after resume
# Usage: safe-suspend.sh [suspend|hibernate|resume]

ACTION=${1:-suspend}
LOG_FILE="/tmp/power-management.log"

log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to remove mt7925e WiFi driver
remove_wifi_driver() {
    log "Checking for mt7925e driver..."
    
    if lsmod | grep -q mt7925e; then
        log "mt7925e driver found, removing..."
        
        # Bring down the WiFi interface and remove the driver module with single pkexec
        log "Bringing down WiFi interface and removing mt7925e module..."
        pkexec sh -c 'ip link set wlp192s0 down 2>/dev/null; sleep 1; modprobe -r mt7925e'
        
        if [ $? -eq 0 ]; then
            log "Successfully removed mt7925e driver"
            return 0
        else
            log "Failed to remove mt7925e driver"
            return 1
        fi
    else
        log "mt7925e driver not loaded, nothing to remove"
        return 0
    fi
}

# Function to reload mt7925e WiFi driver
reload_wifi_driver() {
    log "Checking if mt7925e driver needs to be reloaded..."
    
    if ! lsmod | grep -q mt7925e; then
        log "mt7925e driver not loaded, reloading..."
        
        # Load the driver module and bring up the WiFi interface
        log "Loading mt7925e module and bringing up WiFi interface..."
        pkexec sh -c 'modprobe mt7925e; sleep 2; ip link set wlp192s0 up'
        
        if [ $? -eq 0 ]; then
            log "Successfully reloaded mt7925e driver"
            # Give the interface time to initialize
            sleep 3
            log "WiFi driver reload completed"
            return 0
        else
            log "Failed to reload mt7925e driver"
            return 1
        fi
    else
        log "mt7925e driver already loaded"
        # Make sure interface is up
        pkexec sh -c 'ip link set wlp192s0 up'
        return 0
    fi
}

# Function to clean up hanging processes
cleanup_processes() {
    log "Cleaning up any hanging loginctl processes..."
    pkill -f "loginctl.*suspend" 2>/dev/null
    pkill -f "loginctl.*hibernate" 2>/dev/null
    sleep 1
}

# Function to perform suspend
do_suspend() {
    log "Starting suspend process..."
    cleanup_processes
    remove_wifi_driver
    
    log "Executing suspend..."
    timeout 15 loginctl suspend
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        log "Suspend timed out"
        cleanup_processes
        return 1
    elif [ $exit_code -eq 0 ]; then
        log "Suspend completed"
        return 0
    else
        log "Suspend failed with exit code $exit_code"
        return $exit_code
    fi
}

# Function to perform hibernate
do_hibernate() {
    log "Starting hibernate process..."
    cleanup_processes
    remove_wifi_driver
    
    log "Executing hibernate..."
    timeout 15 loginctl hibernate
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        log "Hibernate timed out, falling back to suspend..."
        cleanup_processes
        do_suspend
        return $?
    elif [ $exit_code -eq 0 ]; then
        log "Hibernate completed"
        return 0
    else
        log "Hibernate failed with exit code $exit_code, falling back to suspend..."
        do_suspend
        return $?
    fi
}

# Function to handle resume actions
do_resume() {
    log "Starting resume process..."
    reload_wifi_driver
    
    if [ $? -eq 0 ]; then
        log "Resume completed successfully"
        return 0
    else
        log "Resume completed with warnings"
        return 1
    fi
}

# Main execution
case "$ACTION" in
    "suspend")
        do_suspend
        ;;
    "hibernate")
        do_hibernate
        ;;
    "resume")
        do_resume
        ;;
    *)
        echo "Usage: $0 [suspend|hibernate|resume]"
        exit 1
        ;;
esac