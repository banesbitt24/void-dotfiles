#!/bin/bash

# Log to file with timestamps
exec > /tmp/qtile_autostart.log 2>&1
echo "$(date): Starting Qtile autostart script..."

# Set PATH to include local bin
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Set PipeWire environment variables
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"
export PULSE_RUNTIME_PATH="${XDG_RUNTIME_DIR}/pulse"

# Wait for X11 to be fully ready
sleep 2

echo "$(date): Starting services..."
# Start other services
picom &
/usr/libexec/polkit-gnome-authentication-agent-1 &
gnome-keyring-daemon --start --components=secrets,ssh,pkcs11 &
xfce4-power-manager &
nitrogen --restore &
nextcloud --background &
redshift &

# Start greenclip with a slight delay to ensure X11 is ready
sleep 1
echo "$(date): Starting greenclip daemon..."
greenclip daemon &
xautolock -time 5 -locker "/home/brandon/.local/bin/smart-lock.sh" -detectsleep &

# Configure display power management
# Screen saver timeout: 10 minutes, DPMS standby: 15 minutes, off: 20 minutes
xset s 600 600
xset dpms 900 0 1200

# Start only pipewire - system config handles the rest
sleep 2
pipewire &

# Wait for auto-services and set default device
sleep 5
wpctl set-default 119 2>/dev/null
