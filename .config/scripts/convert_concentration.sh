#!/bin/bash

PROMPT="Enter a concentration:"
launcher=$1
# Conversion functions
mg_to_mmol() {
  echo "scale=2; ($1 * $2) / 10" | bc
}

mmol_to_mg() {
  echo "scale=2; ($1 / $2) * 10" | bc
}

# Ensure bc is installed
command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }

# Get user input
case $launcher in
    dmenu)
        menu_cmd="printf '        ' | dmenu -l 0 -p \"$PROMPT\""
        ;;
    tofi)
	menu_cmd="tofi -c $HOME/.config/tofi/configA --height 40 --width 350 --require-match=false --prompt \"$PROMPT\”"
        ;;
    *)
        notify-send "You have to choose a launcher!"
        exit 1
        ;;
esac

conc=$(eval "$menu_cmd") || exit 0
[ -z "$conc" ] && exit

# Validate input is a number
[[ "$conc" =~ ^-?[0-9]+([.][0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }

# Molar masses (g/mol)
declare -A molar_masses=(
  [Cholesterol]=386.654
  [Glucose]=180.156
  [Urea]=60.06
)

# Accumulate output
#output="Conversions for: ${temp} mg/dL or mmol/L\n"
output= ""

for substance in "${!molar_masses[@]}"; do
  molar_mass="${molar_masses[$substance]}"
  
  mg_to_mmol_result=$(mg_to_mmol "$conc" "$molar_mass")
  mmol_to_mg_result=$(mmol_to_mg "$conc" "$molar_mass")

  output+="$substance:\n"
  output+="  $conc mmol/L → $mmol_to_mg_result mg/dL\n"
  output+="  $conc mg/dL → $mg_to_mmol_result mmol/L\n\n"
done

# Display result
notify-send -t 6000 -u critical "$(echo -e "$output")"
