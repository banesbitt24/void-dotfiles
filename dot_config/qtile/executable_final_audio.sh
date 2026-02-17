#!/bin/bash

export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"
export PULSE_RUNTIME_PATH="${XDG_RUNTIME_DIR}/pulse"

# Only start pipewire - it will auto-start everything else via system config
pipewire &

# Wait for auto-started services to initialize
sleep 5

# Set your working device
wpctl set-default 119 2>/dev/null
