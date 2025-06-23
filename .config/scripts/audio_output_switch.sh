#!/bin/sh

options=$(pactl -f json list sinks | jq -r '.[] | .description')

# Case-insensitive matching enabled
shopt -s nocasematch

scanbt="[Scan for bluetooth headset]"
togglebt="$HOME/.config/scripts/toggle_bluetooth_headsets_OnOff.sh"

selection=$(echo -e "$options\n$scanbt" | tofi -c ~/.config/tofi/configA --prompt "Set audio output: ")
clean_selection=$(printf "%s" "$selection" | tr -d '\n\r')

if [ "$1" = "--reset" ]; then
    echo "Resetting Bluetooth..."
    sudo systemctl restart bluetooth
    sleep 2
fi

# If user chose to scan for Bluetooth headset
if [ "$clean_selection" = "$scanbt" ]; then
    # Run Bluetooth toggle script, capture lines that start with "Connected:" or "Disconnected:"
    output=$(bash ~/.config/scripts/toggle_bluetooth_headsets_OnOff.sh | grep -E '^Connected:|^Disconnected:')

    # If output is non-empty, show notification
    [ -n "$output" ] && notify-send "Audio: $output"
    exit
fi

# Get the sink name corresponding to the selected description
sink_name=$(pactl -f json list sinks | jq -r --arg desc "$selection" '.[] | select(.description == $desc) | .name')

# Set as default sink if found
if [ -n "$sink_name" ]; then
    pactl set-default-sink "$sink_name"

    # Move all running sink inputs to the new sink
    input_ids=$(pactl -f json list sink-inputs | jq -r '.[].index')
    for input_id in $input_ids; do
        pactl move-sink-input "$input_id" "$sink_name"
    done

    notify-send "Audio switched to: $selection"
else
    notify-send "Audio switch failed"
fi
