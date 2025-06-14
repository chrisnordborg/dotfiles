#!/bin/sh

command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

c_to_f() {
    celsius="$(echo "" | $menuB --prompt "Enter temperature in Celsius: " <&-)"
    [ -z "$celsius" ] && exit
    [[ "$celsius" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }
    fahrenheit=$(bc <<< "scale=2; ($celsius * 9/5) + 32")
    notify-send  "$celsius°C is equal to $fahrenheit°F"
    #notify-send -h string:bgcolor:#bf616a "$celsius°C is equal to $fahrenheit°F"
}

f_to_c() {
    fahrenheit="$(echo "" | $menuB --prompt "Enter temperature in Fahrenheit: " <&-)"
    [ -z "$fahrenheit" ] && exit
    [[ "$fahrenheit" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }
    celsius=$(bc <<< "scale=2; ($fahrenheit - 32) * 5/9")
    notify-send "$fahrenheit°F is equal to $celsius°C"
    #notify-send -h string:bgcolor:#81a1c1 "$fahrenheit°F is equal to $celsius°C"
}

menu="tofi -c $HOME/.config/tofi/configA --height 125 --width 400 --require-match=false"
menuB="tofi -c $HOME/.config/tofi/configA --height 60 --width 450 --require-match=false"
choose=$(printf "%s\nCelcius to Fahrenheit\nFahrenheit to Celcius" | $menu --prompt "Choose: " )

[ -z "$choose" ] && exit
case "$choose" in
    *Fahrenheit) c_to_f ;;
    *Celcius) f_to_c ;;
    *) exit ;;
esac

