#!/bin/bash

# Smart lock script that prevents locking during media playback
# Checks for fullscreen applications and audio playback before locking

# Check if any window is fullscreen
is_fullscreen() {
    # Get active window
    local active_window screen_width window_width
    active_window=$(xdotool getactivewindow 2>/dev/null)
    if [ -n "$active_window" ]; then
        # Get screen and window dimensions
        screen_width=$(xdpyinfo | grep dimensions | cut -d' ' -f7 | cut -d'x' -f1)
        window_width=$(xwininfo -id "$active_window" 2>/dev/null | grep "Width:" | awk '{print $2}')
        # Check if window width matches screen width (only if both values exist)
        [ -n "$window_width" ] && [ -n "$screen_width" ] && [ "$window_width" = "$screen_width" ]
    else
        # No active window, definitely not fullscreen
        false
    fi
}

# Check if audio is playing
is_audio_playing() {
    # Check for PipeWire streams first (preferred on this system)
    if command -v wpctl >/dev/null 2>&1; then
        # Get only the Audio Streams section, stop before Video and Settings
        local audio_streams_content
        audio_streams_content=$(wpctl status 2>/dev/null | sed -n '/Audio/,/Video/p' | sed -n '/Streams:/,/^Video\|^$/p' | head -n -1)
        
        # Check if there are any stream entries after "└─ Streams:" that aren't just empty lines or Video section
        local stream_count
        stream_count=$(echo "$audio_streams_content" | grep -E "^\s*[0-9]+\." | wc -l)
        
        if [ "$stream_count" -gt 0 ]; then
            return 0
        fi
    fi
    
    # Fallback to PulseAudio method
    local audio_streams
    audio_streams=$(pactl list short sink-inputs 2>/dev/null)
    [ -n "$audio_streams" ] && echo "$audio_streams" | grep -q "RUNNING"
}

# Check for specific media applications
is_media_running() {
    # Check for dedicated media players
    if pgrep -f "(vlc|mpv|mplayer|totem|parole|rhythmbox|clementine|audacious|spotify)" >/dev/null 2>&1; then
        return 0
    fi
    
    # Check for browser-based streaming applications
    # Look for specific streaming site processes/windows
    if pgrep -f "(chromium|brave|firefox)" >/dev/null 2>&1; then
        # Check browser command lines for streaming sites
        if pgrep -f "(netflix\.com|hulu\.com|youtube\.com|twitch\.tv|disney|paramount|amazon.*video|apple.*tv)" >/dev/null 2>&1; then
            return 0
        fi
        
        # Alternative: Check window titles for streaming indicators
        if command -v xdotool >/dev/null 2>&1; then
            # Get all window titles and check for streaming sites
            if xdotool search --name "Netflix" 2>/dev/null | head -1 >/dev/null 2>&1; then
                return 0
            fi
            if xdotool search --name "YouTube" 2>/dev/null | head -1 >/dev/null 2>&1; then
                return 0
            fi
            if xdotool search --name "Hulu" 2>/dev/null | head -1 >/dev/null 2>&1; then
                return 0
            fi
            if xdotool search --name "Twitch" 2>/dev/null | head -1 >/dev/null 2>&1; then
                return 0
            fi
            if xdotool search --name "Disney" 2>/dev/null | head -1 >/dev/null 2>&1; then
                return 0
            fi
        fi
    fi
    
    return 1
}

# Main logic
fullscreen_result=""
audio_result=""
media_result=""

if is_fullscreen; then
    fullscreen_result="fullscreen"
fi

if is_audio_playing; then
    audio_result="audio"
fi

if is_media_running; then
    # Try to identify what type of media was detected
    if pgrep -f "(vlc|mpv|mplayer|totem|parole|rhythmbox|clementine|audacious|spotify)" >/dev/null 2>&1; then
        media_result="media-player"
    elif pgrep -f "(netflix\.com|hulu\.com|youtube\.com|twitch\.tv|disney|paramount|amazon.*video|apple.*tv)" >/dev/null 2>&1; then
        media_result="streaming-url"
    else
        media_result="streaming-window"
    fi
fi

if [ -n "$fullscreen_result" ] || [ -n "$audio_result" ] || [ -n "$media_result" ]; then
    detected_reasons="$fullscreen_result $audio_result $media_result"
    echo "$(date): Media detected ($detected_reasons), skipping lock" >> /tmp/smart-lock.log
    exit 0  # Don't lock, exit silently
else
    echo "$(date): No media detected, proceeding with lock" >> /tmp/smart-lock.log
    betterlockscreen -l
fi