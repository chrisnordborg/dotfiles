#!/bin/sh
options=$(pactl -f json list sinks | jq -r '.[] | .description')

# Prompt user with Tofi
#selection=$(printf "%s\n" "$timestamp" "" cho "$options" | tofi -c ~/.config/tofi/configA --prompt "Set audio output: ")

# Case-insensitive pattern matching
shopt -s nocasematch

btscan="[Scan for bluetooth headset]"

selection=$(echo -e "$options\n$btscan" | tofi -c ~/.config/tofi/configA --prompt "Set audio output: ")

# Scan for bluetooth headsets
if [[ "$selection" == *"$btscan"* ]]; then
    bash $HOME/dotfiles/.config/scripts/toggle_bluetooth_headsets_OnOff.sh
    exit 
fi


# Get the sink name corresponding to the selected description
sink_name=$(pactl -f json list sinks | jq -r --arg desc "$selection" '.[] | select(.description == $desc) | .name')

# Set as default sink
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
