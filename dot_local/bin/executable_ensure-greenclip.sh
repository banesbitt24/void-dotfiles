#!/bin/bash

# Script to ensure greenclip daemon is running
# This can be called from rofi clipboard script to ensure the daemon is active

if ! pgrep -f "greenclip daemon" > /dev/null; then
    echo "Greenclip daemon not running, starting it..."
    greenclip daemon &
    sleep 2
fi