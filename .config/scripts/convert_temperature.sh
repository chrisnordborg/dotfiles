#!/bin/bash

# Ensure bc is installed
command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

SB="#a3be8c"
NF="#d8dee9"
FN="monospace-16"
PROMPT="Enter a temperature:"
launcher=$1

# ----------------------------
# LAUNCHER SELECTION
# ----------------------------
case $launcher in
    dmenu)
        menu_cmd="printf '' | dmenu -l 10 -c -fn \"$FN\" -sb \"$SB\" -nf \"$NF\" -p \"$PROMPT\" <&- || exit 0"
        ;;
    tofi)
        menu_cmd="tofi -c \"$HOME/.config/tofi/configA\" --height 40 --width 330 --require-match=false --prompt \"$PROMPT\""
        ;;
    *)
        notify-send "You have to choose a launcher!"
        exit 1
        ;;
esac

# ----------------------------
# GET USER INPUT
# ----------------------------
temp=$(eval "$menu_cmd") || exit 0

# If user cancelled
[ -z "$temp" ] && exit

# ----------------------------
# VALIDATE INPUT IS A NUMBER
# ----------------------------
if ! [[ "$temp" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    notify-send "Error: Not a valid number"
    exit 1
fi

# ----------------------------
# CALCULATIONS
# ----------------------------
c_from_f=$(bc <<< "scale=2; ($temp - 32) * 5/9")
c_from_k=$(bc <<< "scale=2; ($temp - 273.15)")
f_from_c=$(bc <<< "scale=2; ($temp * 9/5) + 32")
f_from_k=$(bc <<< "scale=2; (($temp - 273.15) * 9/5 + 32)")
k_from_c=$(bc <<< "scale=2; ($temp + 273.15)")
k_from_f=$(bc <<< "scale=2; (($temp - 32) * 5/9 + 273.15)")

# ----------------------------
# DISPLAY RESULTS
# ----------------------------
notify-send -t 5000 -h string:bgcolor:#916B4A "$(echo -e \
"$temp°C ---> $f_from_c°F  or $k_from_c°K\n\n\
$temp°F ---> $c_from_f°C  or  $k_from_f°K\n\n\
$temp°K ---> $c_from_k°C  or  $f_from_c°F")"
