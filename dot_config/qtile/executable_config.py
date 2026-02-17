# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess
import time
import libqtile.resources
from libqtile import bar, layout, qtile, hook
from qtile_extras import widget
from libqtile import widget as base_widget
from qtile_extras.widget.decorations import RectDecoration
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

gap_size = 5

# Disable Chromium Google API key warnings
os.environ['GOOGLE_API_KEY'] = 'no'
os.environ['GOOGLE_DEFAULT_CLIENT_ID'] = 'no'
os.environ['GOOGLE_DEFAULT_CLIENT_SECRET'] = 'no'

def resize_floating_window(width: int = 0, height: int = 0):
    @lazy.window.function
    def _inner(window):
        window.cmd_set_size_floating(window.width + width, window.height + height)
    return _inner

def get_redshift_temp():
    """Get current redshift color temperature"""
    try:
        output = subprocess.check_output(["redshift", "-p"], stderr=subprocess.DEVNULL).decode()
        temp = output.split("K")[0].split(": ")[1]
        return f"󰌶 {temp}K"
    except:
        return "󰌶 N/A"

import subprocess
import re

def get_bluetooth_status():
    """Get Bluetooth status - show device name and battery percentage when connected"""
    try:
        # Get connected devices
        output = subprocess.check_output(["bluetoothctl", "devices", "Connected"], stderr=subprocess.DEVNULL).decode().strip()
        connected_devices = [line for line in output.split('\n') if line.strip()]
        
        if not connected_devices:
            return ""
        
        device_info = []
        
        for device_line in connected_devices:
            # Extract MAC address from the device line
            # Format: "Device XX:XX:XX:XX:XX:XX Device Name"
            parts = device_line.split(' ', 2)
            if len(parts) >= 3:
                mac_address = parts[1]
                device_name = parts[2]
                
                # Get battery info for this device
                try:
                    battery_output = subprocess.check_output(
                        ["bluetoothctl", "info", mac_address], 
                        stderr=subprocess.DEVNULL
                    ).decode()
                    
                    # Look for battery percentage in the output
                    battery_match = re.search(r'Battery Percentage: \(0x[0-9a-f]+\) (\d+)', battery_output)
                    if battery_match:
                        battery_percent = battery_match.group(1)
                        device_info.append(f"{device_name} {battery_percent}%")
                    else:
                        # If no battery info available, just show device name
                        device_info.append(device_name)
                        
                except subprocess.CalledProcessError:
                    # If we can't get info for this device, just show the name
                    device_info.append(device_name)
        
        return f" {', '.join(device_info)}" if device_info else ""
        
    except subprocess.CalledProcessError:
        return ""

mod = "mod1"
terminal = guess_terminal()

@hook.subscribe.startup_once
def autostart():
    subprocess.Popen(['/home/brandon/.config/qtile/autostart.sh'])

@hook.subscribe.startup_complete
def delayed_widget_start():
    # Wait 10 seconds after startup completes for network to be ready
    time.sleep(10)
    # Force weather widget refresh
    for screen in qtile.screens:
        for widget in screen.top.widgets:
            if hasattr(widget, 'update') and 'OpenWeather' in str(type(widget)):
                widget.update()
            elif hasattr(widget, 'force_update') and 'CheckUpdates' in str(type(widget)):
                widget.force_update()

@hook.subscribe.startup
def restore_wallpaper():
    subprocess.Popen(['nitrogen', '--restore'])

decoration_group = {
    "decorations": [
        RectDecoration(colour="#4c566a", radius=4, filled=True, padding_y=4, group=True)
    ],
    "padding": 10,
}

window_name_decoration = {
    "decorations": [
        RectDecoration(colour="#4c566a", radius=4, filled=True, padding_y=4, padding_x=8, group=False)
    ],
    "padding": 15,
}

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "r", lazy.spawn("rofi -show drun"), desc="Launch terminal"),
    Key([mod], "x", lazy.spawn("rofi -show calc"), desc="Launch Calculator"),
    Key([mod], "b", lazy.spawn("brave-browser-stable"), desc="Launch Brave"),
    Key([mod], "v", lazy.spawn("/home/brandon/.config/rofi/scripts/clipboard.sh"), desc="Launch Clipboard History"),
    Key([mod], "p", lazy.spawn("/home/brandon/.config/rofi/scripts/power-menu.sh"), desc="Launch Power Menu"),
    Key([mod, "shift"], "p", lazy.spawn("/home/brandon/.local/bin/package-manager.sh"), desc="Launch Package Manager"),
    Key([mod, "control"], "l", lazy.spawn("betterlockscreen -l"), desc="Lock screen"),
    # Screenshots
    Key([mod], "Print", lazy.spawn("/home/brandon/.local/bin/rofi-screenshot"), desc="Screenshot menu"),
    Key([], "Print", lazy.spawn("scrot '%Y-%m-%d_%H-%M-%S_screenshot.png' -e 'mv $f ~/Nextcloud/Pictures/Screenshots/ && notify-send \"Screenshot saved\" \"$f\"'"), desc="Fullscreen screenshot"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key(
        [mod],
        "t",
        lazy.window.toggle_floating(),
        desc="Toggle floating on the focused window",
    ),
    # Floating window resize controls
    Key([mod, "shift", "control"], "h", resize_floating_window(width=-50), desc="Shrink floating window horizontally"),
    Key([mod, "shift", "control"], "l", resize_floating_window(width=50), desc="Grow floating window horizontally"),
    Key([mod, "shift", "control"], "j", resize_floating_window(height=50), desc="Grow floating window vertically"),
    Key([mod, "shift", "control"], "k", resize_floating_window(height=-50), desc="Shrink floating window vertically"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # Volume controls
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pamixer -i 5"), desc="Raise Volume by 5%"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pamixer -d 5"), desc="Lower Volume by 5%"),
    Key([], "XF86AudioMute", lazy.spawn("pamixer -t"), desc="Mute/Unmute Volume"),
    # Media controls
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause"), desc="Play/Pause player"),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next"), desc="Skip to next"),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous"), desc="Skip to previous"),
    
    # Scratchpad toggles
    Key([mod], "grave", lazy.group["scratchpad"].dropdown_toggle("terminal"), desc="Toggle Terminal Scratchpad"),
    Key([mod], "z", lazy.group["scratchpad"].dropdown_toggle("protonpass"), desc="Toggle Proton Pass"),
    Key([mod], "m", lazy.group["scratchpad"].dropdown_toggle("protonmail"), desc="Toggle Proton Mail"),  
    Key([mod], "c", lazy.group["scratchpad"].dropdown_toggle("protoncalendar"), desc="Toggle Proton Calendar"),
    Key([mod], "s", lazy.group["scratchpad"].dropdown_toggle("spotify"), desc="Toggle Spotify"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


group_names = ["1", "2", "3", "4", "5", "6"]

# Uncomment only one of the following lines
#group_labels = ["", "", "👁", "", "", "", "✀", "꩜", "", "⎙"]
#group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
group_labels = ["WWW", "DEV", "SYS", "MEDIA", "NOTES", "VIRT"]

groups = [Group(name=group_names[i], label=group_labels[i]) for i in range(len(group_names))]

# Add scratchpads for Proton apps
groups.append(
    ScratchPad(
        "scratchpad",
        [
            DropDown(
                "terminal",
                terminal,
                width=0.8,
                height=0.6,
                x=0.1,
                y=0.2,
                opacity=0.9,
                on_focus_lost_hide=True,
            ),
            DropDown(
                "protonpass",
                "/usr/lib/chromium/chromium --profile-directory=Default --app-id=hkhckfoofhljcngmlnlojcbplgkcpcab",
                width=0.6,
                height=0.7,
                x=0.2,
                y=0.15,
                opacity=0.95,
                on_focus_lost_hide=True,
                match=Match(wm_class="crx_hkhckfoofhljcngmlnlojcbplgkcpcab"),
            ),
            DropDown(
                "protonmail", 
                "/usr/lib/chromium/chromium --profile-directory=Default --app-id=jnpecgipniidlgicjocehkhajgdnjekh",
                width=0.8,
                height=0.8,
                x=0.1,
                y=0.1,
                opacity=0.95,
                on_focus_lost_hide=True,
                match=Match(wm_class="crx_jnpecgipniidlgicjocehkhajgdnjekh"),
            ),
            DropDown(
                "protoncalendar",
                "/usr/lib/chromium/chromium --profile-directory=Default --app-id=ojibjkjikcpjonjjngfkegflhmffeemk",
                width=0.7,
                height=0.75,
                x=0.15,
                y=0.125,
                opacity=0.95,
                on_focus_lost_hide=True,
                match=Match(wm_class="crx_ojibjkjikcpjonjjngfkegflhmffeemk"),
            ),
            DropDown(
                "spotify",
                "/usr/lib/chromium/chromium --profile-directory=Default --app-id=pjibgclleladliembfgfagdaldikeohf",
                width=0.7,
                height=0.75,
                x=0.15,
                y=0.125,
                opacity=0.95,
                on_focus_lost_hide=True,
                match=Match(wm_class="crx_pjibgclleladliembfgfagdaldikeohf"),
            ),
        ],
    )
)

for i in groups:
    if i.name != "scratchpad":  # Skip scratchpad group for regular key bindings
        keys.extend(
            [
                # mod + group number = switch to group
                Key(
                    [mod],
                    i.name,
                    lazy.group[i.name].toscreen(),
                    desc=f"Switch to group {i.name}",
                ),
                # mod + shift + group number = switch to & move focused window to group
                Key(
                    [mod, "shift"],
                    i.name,
                    lazy.window.togroup(i.name, switch_group=True),
                    desc=f"Switch to & move focused window to group {i.name}",
                ),
                # Or, use below if you prefer not to switch to that group.
                # # mod + shift + group number = move focused window to group
                # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
                #     desc="move focused window to group {}".format(i.name)),
            ]
        )

layouts = [
    layout.MonadTall(
        margin=gap_size,
        border_focus='#5e81ac',
        border_normal='#4c566a',
        border_width=4
    ),
    layout.Columns(
        margin=gap_size, 
        border_focus="5e81ac",
        border_normal="4c566a",
        border_width=4
    ),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=14,
    padding=3,
)
extension_defaults = widget_defaults.copy()

top_bar = bar.Bar(
    [
        widget.Spacer(length=10),
        widget.GroupBox(**decoration_group,
                        highlight_method='text',
                        active="ffffff",
                        inactive="d8dee9",
                        this_current_screen_border='81a1c1',
                        highlight_color="81a1c1"),
        widget.Spacer(),
        widget.Clock(**decoration_group,format="  %A, %B %d - %I:%M %p"),
        widget.Spacer(length=10),
        widget.OpenWeather(**decoration_group,app_key='944394199faa7d01fabba028287f9990',cityid='5425043',
                           format='󰖐  {temp}°F {weather_details}', metric=False,
                           mouse_callbacks = {
                               'Button1': lazy.spawn('brave-browser-stable https://forecast.weather.gov/MapClick.php?lat=39.542893&lon=-104.924168')
                           }),
        widget.Spacer(),
        widget.GenPollText(**decoration_group, func=get_bluetooth_status, update_interval=5,
                         mouse_callbacks = {
                             'Button1': lazy.spawn("blueman-manager")
                         }),
        widget.Spacer(length=10),
        widget.PulseVolume(**decoration_group,fmt="  Vol: {}",
                           mouse_callbacks = {
                               'Button1': lazy.spawn('pavucontrol')
                           }),
        widget.Spacer(length=10),
        widget.Wlan(**decoration_group,interface="wlp192s0", format="  {essid} {percent:2.0%}",
                    mouse_callbacks = {
                        'Button1': lazy.spawn("ghostty -e 'nmtui'")
                    }),
        widget.Spacer(length=10)
    ],
    background="#2e3440",
    size=32,
    border_radius=4,
    border_width=0,
    margin=[gap_size, gap_size, gap_size, gap_size],
    # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
    # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
)

bottom_bar = bar.Bar(
    [
        widget.Spacer(length=10),
        widget.CheckUpdates(**decoration_group,
                           distro="Void",
                           display_format="  Updates: {updates}",
                           no_update_string="  Updates: 0", 
                           update_interval=600,
                           mouse_callbacks = {
                            'Button1': lazy.spawn("/home/brandon/.local/bin/package-manager.sh")
                            }),
        widget.Spacer(length=10),
        widget.CPU(**decoration_group,format="  CPU: {freq_current}GHz {load_percent}%",
                   mouse_callbacks = {
                       'Button1': lazy.spawn("ghostty -e 'btop'")
                   }),
        widget.Spacer(length=10),
        widget.Memory(**decoration_group,measure_mem="G",format="  MEM:{MemUsed: .0f}{mm} /{MemTotal: .0f}{mm}",
                   mouse_callbacks = {
                       'Button1': lazy.spawn("ghostty -e 'btop'")
                   }),
        widget.Spacer(length=10),
        widget.DF(**decoration_group,partition="/",measure="G",format="  SSD: {uf:.1f} GB free",visible_on_warn=False,
                   mouse_callbacks = {
                       'Button1': lazy.spawn("ghostty -e 'btop'")
                   }),
        widget.Spacer(),
        widget.WindowName(**window_name_decoration, width=bar.CALCULATED, max_chars=30, scroll=True,
                          format="  {name}", empty_group_string="",scroll_delay=1, scroll_step=1, scroll_interval=0.1),
        widget.Spacer(),
        widget.Mpris2(**decoration_group, 
                      scroll=True,
                      scroll_chars=20,
                      scroll_interval=0.1,
                      scroll_wait_intervals=10,
                      scroll_step=1,
                      width=300),
        widget.Spacer(length=10),
        widget.Battery(**decoration_group),
        widget.Spacer(length=10),
    ],
    background="#2e3440",
    size=32,
    border_radius=4,
    border_width=0,
    margin=[gap_size, gap_size, gap_size, gap_size],
    # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
    # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
)

logo = os.path.join(os.path.dirname(libqtile.resources.__file__), "logo.png")


screens = [
    Screen(
        top=top_bar,
        bottom=bottom_bar,
        left=bar.Gap(gap_size),
        right=bar.Gap(gap_size),
        background="#2e3440",
        # wallpaper=logo,
        # wallpaper_mode="center",
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_focus='#5e81ac',
    border_normal='#4c566a',
    border_width=4,
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        # Proton app scratchpads
        Match(wm_class="crx_hkhckfoofhljcngmlnlojcbplgkcpcab"),  # Proton Pass
        Match(wm_class="crx_jnpecgipniidlgicjocehkhajgdnjekh"),  # Proton Mail
        Match(wm_class="crx_ojibjkjikcpjonjjngfkegflhmffeemk"),  # Proton Calendar
        Match(wm_class="crx_pjibgclleladliembfgfagdaldikeohf"),  # Spotify 
        Match(wm_class="blueman-manager"),
        Match(wm_class="pavucontrol")
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = "Breeze_Snow"
wl_xcursor_size = 24

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
