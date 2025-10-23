#!/bin/bash

# ----------------------------
# CONFIGURATION PHASE
# ----------------------------
PROMPT="Choose converter:"
scriptFolder="$HOME/.config/scripts"
launcher=$1

# ----------------------------
# MENU ITEMS AS ARRAY
# ----------------------------
menu_items=(
    "1. Temperature (Celsius Fahrenheit Kelvin)"
    "2. Concentration (mmol mg/dL)"
    "3. Currency (SEK USD EUR GBP NOK)"
    "4. Distance (miles km)"
    "5. Velocity (km/h mph knots)"
)

# Map menu item to script name automatically
declare -A script_map=(
    ["${menu_items[0]}"]="convert_temperature.sh"
    ["${menu_items[1]}"]="convert_concentration.sh"
    ["${menu_items[2]}"]="convert_currency.sh"
    ["${menu_items[3]}"]="convert_distance.sh"
    ["${menu_items[4]}"]="convert_velocity.sh"
)

# Number of menu items
menu_length=${#menu_items[@]}

# ----------------------------
# LAUNCHER SELECTION PHASE
# ----------------------------
case $launcher in
    dmenu)
        choice=$(printf '%s\n' "${menu_items[@]}" | dmenu -l "$menu_length" -p "$PROMPT") || exit 0
        ;;
    tofi)
        choice=$(printf '%s\n' "${menu_items[@]}" | tofi -c "$HOME/.config/tofi/configA" --require-match=false --width 701 --prompt "$PROMPT") || exit 0
        ;;
    *)
        notify-send "You have to choose a launcher!"
        exit 1
        ;;
esac

# ----------------------------
# RESULT HANDLING (automatic)
# ----------------------------
# Launch script if it exists
if [[ -f "$scriptFolder/${script_map[$choice]}" ]]; then
    bash "$scriptFolder/${script_map[$choice]}" "$launcher"
else
    notify-send "Script not found: $script_name"
fi
