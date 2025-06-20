#!/bin/sh

temp="1. Temperature (Celcius Fahrenheit Kelvin)"
conc="2. Concentration (mmol mg/dL)"
currency="3. Currency (SEK USD EUR GBP NOK)"
distance="4. Distance (miles km)"

menu="tofi -c $HOME/.config/tofi/configA --require-match=false --width 700"
scriptFolder="$HOME/.config/scripts"

choice=$(
  printf "%s\n" \
    "$temp" \
    "$conc" \
    "$currency" \
    "$distance" \
  | $menu --prompt "Choose converter: ")

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

