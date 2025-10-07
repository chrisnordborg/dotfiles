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


# Detect mute state using amixer
if amixer get Master | grep -q '\[off\]'; then
    mute_option="Unmute"
else
    mute_option="Mute"
fi


# Prompt user
launcher=$1
case $launcher in 
	dmenu)
		selection=$(echo -e "$mute_option\n$options\n$scanbt\n$restartbt\n" | dmenu -p "Set audio output:") || exit 0
		;;
	tofi)
		selection=$(echo -e "$mute_option\n$options\n$scanbt\n$restartbt" | tofi -c ~/.config/tofi/configA --prompt "Set audio output: ")
		;;
	*)
		notify-send -u critical "You have to select a launcher!"
		exit
		;;
esac

clean_selection=$(printf "%s" "$selection" | tr -d '\n\r')
case $clean_selection in
	"Mute"|"Unmute")
		amixer set Master toggle
		exit 1
		;;
	$restartbt)
		notify-send -u critical "Bluetooth" "Restarting service..."
    		sudo systemctl restart bluetooth
    		sleep 2
    		exit
		;;
	$scanbt)
    		output=$(bash "$toggle_bt" | grep -E '^Connected:|^Disconnected:')
    		#[ -n "$output" ] && notify-send -u critical "Audio: $output"
		exit 1
		;;
esac

# Set default audio sink
sink_name=$(pactl -f json list sinks | jq -r --arg desc "$clean_selection" '.[] | select(.description == $desc) | .name')

if [ -n "$sink_name" ]; then
    pactl set-default-sink "$sink_name"

    # Move all current audio streams to new sink
    input_ids=$(pactl -f json list sink-inputs | jq -r '.[].index')
    for input_id in $input_ids; do
        pactl move-sink-input "$input_id" "$sink_name"
    done

    notify-send -u critical "Audio switched to: $clean_selection"
else
    notify-send -u critical "Audio switch failed"
fi

