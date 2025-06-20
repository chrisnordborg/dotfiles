#!/bin/sh

mg_to_mmol (conc)  {
}

command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

menu="tofi -c $HOME/.config/tofi/configA --height 80 --width 400 --require-match=false"
temp=$(echo "" | $menu --prompt "Enter a concentration (mmol/L or mg/dL): " )
# Molar masses (g/mol)
cholesterol=386.654
glucose=180.156


[ -z "$temp" ] && exit
[[ "$temp" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }
#cholesterol
cholesterol_mg_to_mmol=$(bc <<< "scale=2; ($temp * $cholesterol / 10)")
cholesterol_mmol_to_mg=$(bc <<< "scale=2; ($temp / $cholesterol * 10)")

glucose_mg_to_mmol

#glucose

notify-send -t 5000 -h string:bgcolor:#916B4A \
	"$(echo -e \
"Cholesterol:\n\
$temp mmol/L is equal to:   $cholesterol_mg_to_mmol mg/dL\n\
$temp mg/dL is equal to:   $cholesterol_mmol_to_mg mmol/L")"
