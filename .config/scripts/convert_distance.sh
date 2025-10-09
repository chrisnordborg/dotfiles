#!/bin/sh

# Ensure bc is installed
command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

# Get user input
distances=(km miles feet)
distances_list_pipe=$(IFS="|"; echo "${distances[*]}")
PROMPT="Enter a distance:"
launcher=$1

case $launcher in
    dmenu)
        menu_cmd="printf '            ' | dmenu  -l 0 -p \"$PROMPT\""
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

miles_to_km="$(echo "scale=2; ($dist * 1.609344 + 0.005)/1" | bc)"



km_to_miles="$(echo "scale=2; $dist * 0.6213712" | bc)"
km_to_feet="$(echo "scale=2; $dist * 3280.84" | bc)"
miles_to_km="$(echo "scale=2; $dist *1.609344" | bc)"
miles_to_feet="$(echo "scale=2; $dist * 5280" | bc)"
feet_to_km="$(echo "scale=2; $dist * 0.0003048" | bc)"
feet_to_miles="$(echo "scale=2; $dist * 0.0001893939" | bc)"

output="km
   $dist --> $km_to_miles miles
   $dist --> $km_to_feet feet
miles
   $dist --> $miles_to_km km
   $dist --> $miles_to_feet feet
feet
   $dist --> $feet_to_km km
   $dist --> $feet_to_miles miles"

notify-send -t 8000 -u critical "$output"
