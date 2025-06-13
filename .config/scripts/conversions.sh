#!/bin/sh

menu="tofi -c $HOME/.config/tofi/configA"

choice=$( echo -e "Temperature (Celcius Fahrenheit)\nConecntration (mmol mg/dL)" | $menu --prompt "Choose converter: ") 
#choice=$( "Temperature (Celcius Fahrenheit)" | $menu --prompt "Choose converter: " ' <<< ' 2>/dev/null)

