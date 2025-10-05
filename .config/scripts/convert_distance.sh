#!/bin/sh

# Ensure bc is installed
command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

# Get user input
SB="#a3be8c"
NF="#d8dee9"
FN="monospace-16"
PROMPT="Enter a distance:"
launcher=$1

case $launcher in
    dmenu)
        menu_cmd="printf '%s\n' \"$menu_items\" | dmenu -l 10 -c -fn \"$FN\" -sb \"$SB\" -nf \"$NF\" -p \"$PROMPT\""
        ;;
    tofi)
	menu_cmd="tofi -c $HOME/.config/tofi/configA --height 40 --width 330 --require-match=false \"$PROMPT\""
        ;;
    *)
        notify-send "You have to choose a launcher!"
        exit 1
        ;;
esac
dist=$(eval "$menu_cmd") || exit 0
[ -z "$dist" ] && exit

# Validate input is a number
[[ "$dist" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }

km_to_miles="$(echo "scale=2; $dist / 1.609344" | bc)"
miles_to_km="$(echo "scale=2; ($dist * 1.609344 + 0.005)/1" | bc)"

message="$dist km ---> $km_to_miles miles
$dist miles ---> $miles_to_km km"

notify-send -t 4000 -h string:bgcolor:#916B4A "$message"
