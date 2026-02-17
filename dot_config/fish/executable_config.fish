if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_greeting ""

starship init fish | source

# Created by `pipx` on 2025-08-23 03:32:57
set PATH $PATH /home/brandon/.local/bin

set -U fish_user_paths "$HOME/.cargo/bin" $fish_user_paths

# Cursor theme environment variables
set -x XCURSOR_THEME "Breeze_Snow"
set -x XCURSOR_SIZE "24"

# Set Editor
set -gx EDITOR nvim

# PipeWire/PulseAudio environment
set -x PULSE_SERVER "unix:$XDG_RUNTIME_DIR/pulse/native"
set -x PIPEWIRE_RUNTIME_DIR "$XDG_RUNTIME_DIR"

alias vim="nvim"
alias xi="sudo xbps-install"
alias xq="sudo xbps-query"
alias k="kubectl"
