#!/bin/sh

command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

menu="tofi -c $HOME/.config/tofi/configA --height 80 --width 400 --require-match=false"
temp=$(echo "" | $menu --prompt "Enter a temperature: " --require-match=false)

[ -z "$temp" ] && exit
[[ "$temp" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }
c_from_f=$(bc <<< "scale=2; ($temp- 32) * 5/9")
c_from_k=$(bc <<< "scale=2; ($temp- 273.15)")
f_from_c=$(bc <<< "scale=2; ($temp* 9/5) + 32")
f_from_k=$(bc <<< "scale=2; (($temp-273.15) * 9/5 + 32)")
k_from_c=$(bc <<< "scale=2; ($temp+ 273.15)")
k_from_f=$(bc <<< "scale=2; (($temp-32) * 5/9 + 273.15)")

notify-send -t 5000 -h string:bgcolor:#916B4A "$(echo -e "$temp°C is equal to:\n$f_from_c°F\n$k_from_c°K\n\n$temp°F is equal to:\n$c_from_f°C\n$k_from_f°K\n\n$temp°K is equal to:\n$c_from_k°C\n$f_from_c°F\n\n")"
