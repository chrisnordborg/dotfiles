#!/bin/bash

# ----------------------------
# CONFIGURATION PHASE
# ----------------------------
temp="1. Temperature (Celsius Fahrenheit Kelvin)"
conc="2. Concentration (mmol mg/dL)"
currency="3. Currency (SEK USD EUR GBP NOK)"
distance="4. Distance (miles km)"
SB="#a3be8c"
NF="#d8dee9"
FN="monospace-16"
PROMPT="Choose converter:"
scriptFolder="$HOME/.config/scripts"
launcher=$1

# ----------------------------
# PREPARE MENU OPTIONS
# ----------------------------
menu_items="$temp
$conc
$currency
$distance"

# ----------------------------
# LAUNCHER SELECTION PHASE
# ----------------------------
case $launcher in
    dmenu)
        menu_cmd="printf '%s\n' \"$menu_items\" | dmenu -l 10 -c -fn \"$FN\" -sb \"$SB\" -nf \"$NF\" -p \"$PROMPT\""
        ;;
    tofi)
        menu_cmd="printf '%s\n' \"$menu_items\" | tofi -c \"$HOME/.config/tofi/configA\" --require-match=false --width 701 --prompt \"$PROMPT\""
        ;;
    *)
        notify-send "You have to choose a launcher!"
        exit 1
        ;;
esac

# ----------------------------
# EXECUTION PHASE
# ----------------------------
choice=$(eval "$menu_cmd") || exit 0

# ----------------------------
# RESULT HANDLING
# ----------------------------
case "$choice" in
    "$temp")
        bash "$scriptFolder/convert_temperature.sh" "$launcher"
        ;;
    "$conc")
        bash "$scriptFolder/convert_concentration.sh" "$launcher"
        ;;
    "$currency")
        bash "$scriptFolder/convert_currency.sh" "$launcher"
        ;;
    "$distance")
        bash "$scriptFolder/convert_distance.sh" "$launcher"
        ;;
    *)
        exit 0
        ;;
esac
