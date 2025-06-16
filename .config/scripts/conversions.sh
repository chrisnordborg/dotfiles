#!/bin/sh

temp="1. Temperature (Celcius Fahrenheit Kelvin)"
conc="[Not Ready]2. Concentration (mmol mg/dL)"
currency="[Not Ready]3. Currency Money (Dollar SEK)"
distance="4[Not Ready]. Distance (miles KM)"

menu="tofi -c $HOME/.config/tofi/configA --require-match=false --width 700"
scriptFolder="$HOME/.config/scripts"

choice=$(
  printf "%s\n" \
    "$temp" \
    "$conc" \
    "$currency" \
    "$distance" \
  | $menu --prompt "Choose converter: ")

#choice=$( "Temperature (Celcius Fahrenheit)" | $menu --prompt "Choose converter: " ' <<< ' 2>/dev/null)
case "$choice" in
    "$temp") 
        bash $scriptFolder/convert_temperature.sh
	;;
    "$conc") 
        bash $scriptFolder/convert_concentration.sh
	;;
    "$currency") 
        bash $scriptFolder/convert_currency.sh
	;;
    "$distance") 
        bash $scriptFolder/convert_distance.sh
	;;
    *) exit ;;
esac

