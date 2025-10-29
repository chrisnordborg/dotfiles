#!/bin/bash

# Paths
toggle_bt="$HOME/.config/scripts/toggle_bluetooth_headsets_OnOff.sh"

# Audio output options from PulseAudio/pipewire (array form)
mapfile -t sinks < <(pactl -f json list sinks | jq -r '.[] | .description')

# Menu extras
scanbt="[Scan for Bluetooth headset]"
restartbt="[Restart Bluetooth]"

# Enable case-insensitive matching
shopt -s nocasematch

# Detect mute state safely (fallback if Master doesn’t exist)
if amixer get Master &>/dev/null; then
    if amixer get Master | grep -q '\[off\]'; then
        mute_option="Unmute"
    else
        mute_option="Mute"
    fi
else
    mute_control=$(amixer scontrols | grep -m1 -Eo "'[^']+'" | tr -d "'")
    if [ -n "$mute_control" ] && amixer get "$mute_control" | grep -q '\[off\]'; then
        mute_option="Unmute"
    else
        mute_option="Mute"
    fi
fi

# ----------------------------
# Construct menu array
# ----------------------------
menu_items=(
    "$mute_option"
    "${sinks[@]}"
    "$scanbt"
    "$restartbt"
)

# Calculate menu length dynamically
menu_length=${#menu_items[@]}

# ----------------------------
# Prompt user
# ----------------------------
launcher=$1
case $launcher in 
    dmenu)
        selection=$(printf "%s\n" "${menu_items[@]}" | dmenu -l "$menu_length" -p "Set audio output:") || exit 0
        ;;
    tofi)
        selection=$(printf "%s\n" "${menu_items[@]}" | tofi -c ~/.config/tofi/configA --prompt "Set audio output: ")
        ;;
    *)
        notify-send -u critical "You have to select a launcher!"
        exit 1
        ;;
esac

# ----------------------------
# Handle selection
# ----------------------------
clean_selection=$(echo "$selection" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')

case "$clean_selection" in
    "Mute"|"Unmute")
        amixer set Master toggle
        exit 0
        ;;
    "$restartbt")
        notify-send -u critical "Bluetooth" "Restarting service..."
        sudo systemctl restart bluetooth
        sleep 2
        exit 0
        ;;
    "$scanbt")
        output=$(bash "$toggle_bt" | grep -E '^Connected:|^Disconnected:')
        notify-send -u normal "Bluetooth headset" "$output"
        exit 0
        ;;
esac

# ----------------------------
# Switch audio sink
# ----------------------------
sink_name=$(pactl -f json list sinks | jq -r --arg desc "$clean_selection" '.[] | select(.description == $desc) | .name')

if [ -n "$sink_name" ]; then
    pactl set-default-sink "$sink_name"

    # Move all current audio streams to new sink
    while read -r input_id; do
        pactl move-sink-input "$input_id" "$sink_name"
    done < <(pactl -f json list sink-inputs | jq -r '.[].index')

    notify-send -u critical "Audio switched to: $clean_selection"
else
    notify-send -u critical "Audio switch failed"
fi
