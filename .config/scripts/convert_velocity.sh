#!/bin/sh

# Ensure bc is installed
command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

# Get user input
speeds=(km/h mph Knots)
speeds_list_pipe=$(IFS="|"; echo "${speeds[*]}")
PROMPT="Enter a velocity (${speeds_list_pipe}):"
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
velocity=$(eval "$menu_cmd") || exit 0
[ -z "$velocity" ] && exit

# Validate input is a number
[[ "$velocity" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }

kmh_to_mph="$(echo "scale=2; $velocity * 0.6213712" | bc)"
kmh_to_knots="$(echo "scale=2; $velocity * 0.5399565" | bc)"
mph_to_kmh="$(echo "scale=2; $velocity * 1.609344" | bc)"
mph_to_knots="$(echo "scale=2; $velocity * 0.8689758" | bc)"
knots_to_kmh="$(echo "scale=2; $velocity * 1.852001" | bc)"
knots_to_mph="$(echo "scale=2; $velocity * 1.15078" | bc)"

output="km/h
   $velocity --> $kmh_to_mph mph
   $velocity --> $kmh_to_knots knots
mph\n
   $velocity --> $mph_to_kmh km/h
   $velocity --> $mph_to_knots knots
Knots
   $velocity --> $knots_to_kmh km/h
   $velocity --> $knots_to_mph mph"

notify-send -t 8000 -u critical "$output"
