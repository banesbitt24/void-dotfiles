#!/bin/bash

echo "=== Boot audio debug $(date) ===" > /tmp/boot_audio_debug.log

echo "Processes at Qtile startup:" >> /tmp/boot_audio_debug.log
ps aux | grep -E "(pipewire|wireplumber)" | grep -v grep >> /tmp/boot_audio_debug.log

echo "Socket status:" >> /tmp/boot_audio_debug.log
ls -la "$XDG_RUNTIME_DIR/pulse/" >> /tmp/boot_audio_debug.log 2>&1

echo "What owns the socket:" >> /tmp/boot_audio_debug.log
lsof "$XDG_RUNTIME_DIR/pulse/native" >> /tmp/boot_audio_debug.log 2>&1
