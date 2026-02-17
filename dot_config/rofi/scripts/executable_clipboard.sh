#!/bin/bash
#
# Rofi clipboard manager script using greenclip
#

# Ensure greenclip daemon is running
/home/brandon/.local/bin/ensure-greenclip.sh

# Launch greenclip with rofi
rofi -modi "clipboard:/home/brandon/.local/bin/greenclip print" -show clipboard -run-command '{cmd}'