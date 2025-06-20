#!/bin/bash

command -v curl >/dev/null || { notify-send "Error: curl not found"; exit 1; }
command -v bc >/dev/null || { notify-send "Error: bc not found"; exit 1; }
command -v jq >/dev/null || { notify-send "Error: jq not found"; exit 1; }

menu="tofi -c $HOME/.config/tofi/configA --height 40 --width 350 --require-match=false"
amount=$(echo "" | $menu --prompt "Enter an amount in SEK: ")
[ -z "$amount" ] && exit

[[ "$amount" =~ ^-?[0-9]+([.][0-9]+)?$ ]] || { notify-send "Error: Not a valid number"; exit 1; }

# Currencies to convert into
target_currencies=(USD EUR NOK GBP)

output="Currency conversions from ${amount} SEK:\n"

for currency in "${target_currencies[@]}"; do
  rate=$(curl -s "https://api.frankfurter.app/latest?from=SEK&to=USD" | jq -r '.rates.USD')
  
  [ -z "$rate" ] && continue

  converted=$(echo "scale=2; $amount * $rate" | bc)
  output+="$amount SEK → $converted $currency (rate: $rate)\n"
done

notify-send -t 7000 -h string:bgcolor:#586e75 "$(echo -e "$output")"
