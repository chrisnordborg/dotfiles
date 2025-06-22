#!/bin/sh

options=$(pactl -f json list sinks | jq -r '.[] | .description')

# Case-insensitive matching enabled
shopt -s nocasematch

btscan="[Scan for bluetooth headset]"

selection=$(echo -e "$options\n$btscan" | tofi -c ~/.config/tofi/configA --prompt "Set audio output: ")
clean_selection=$(printf "%s" "$selection" | tr -d '\n\r')

# If user chose to scan for Bluetooth headset
if [ "$clean_selection" = "$btscan" ]; then
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
