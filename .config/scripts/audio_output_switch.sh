#!/bin/bash

# Paths
toggle_bt="$HOME/.config/scripts/toggle_bluetooth_headsets_OnOff.sh"

# Audio output options from PulseAudio/pipewire
options=$(pactl -f json list sinks | jq -r '.[] | .description')

# Menu extras
scanbt="[Scan for Bluetooth headset]"
restartbt="[Restart Bluetooth]"

# Enable case-insensitive matching
shopt -s nocasematch

# Prompt user
launcher=$1
SB="#a3be8c"
NF="#d8dee9"
FN="monospace-16"
case $launcher in 
	dmenu)
		selection=$(echo -e "$options\n$scanbt\n$restartbt" | dmenu -l 8 -c -fn $FN -sb $SB -nf $NF -p "Set audio output:") || exit 0
		;;
	tofi)
		selection=$(echo -e "$options\n$scanbt\n$restartbt" | tofi -c ~/.config/tofi/configA --prompt "Set audio output: ")
		;;
	*)
		notify-send "You have to select a launcher!"
		exit
		;;
esac



clean_selection=$(printf "%s" "$selection" | tr -d '\n\r')

# Handle Bluetooth restart
if [ "$clean_selection" = "$restartbt" ]; then
    notify-send "Bluetooth" "Restarting service..."
    sudo systemctl restart bluetooth
    sleep 2
    exit
fi

# Handle Bluetooth headset scan/connect
if [ "$clean_selection" = "$scanbt" ]; then
    output=$(bash "$toggle_bt" | grep -E '^Connected:|^Disconnected:')
    #[ -n "$output" ] && notify-send "Audio: $output"
    exit
fi

# Set default audio sink
sink_name=$(pactl -f json list sinks | jq -r --arg desc "$clean_selection" '.[] | select(.description == $desc) | .name')

if [ -n "$sink_name" ]; then
    pactl set-default-sink "$sink_name"

    # Move all current audio streams to new sink
    input_ids=$(pactl -f json list sink-inputs | jq -r '.[].index')
    for input_id in $input_ids; do
        pactl move-sink-input "$input_id" "$sink_name"
    done

    notify-send "Audio switched to: $clean_selection"
else
    notify-send "Audio switch failed"
fi

