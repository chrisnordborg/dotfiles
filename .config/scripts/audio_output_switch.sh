#!/bin/sh

# Create a list of sinks with pretty names
#options=$(pactl -f json list sinks | jq -r '.[] | .description')

# Let the user select a description using Tofi
#selection=$(echo "$options" | tofi -c ~/.config/tofi/configA --prompt-text="Set audio output: ")

# Extract the corresponding sink name
#sink_name=$(pactl -f json list sinks | jq -r --arg sink_pretty_name "$selection" '.[] | select(.description == $sink_pretty_name) | .name')

# Set the selected sink as default
#if [ -n "$sink_name" ]; then
#    pactl set-default-sink "$sink_name" && notify-send "Audio switched to: $selection"
#else
#    notify-send "Audio switch failed"
#fi


# Get all sink descriptions
options=$(pactl -f json list sinks | jq -r '.[] | .description')

# Prompt user with Tofi
selection=$(echo "$options" | tofi -c ~/.config/tofi/configA --prompt-text="Set audio output: ")

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
