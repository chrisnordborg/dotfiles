#!/bin/bash

format_number() {
  local number="$1"
  # Round to nearest integer by adding 0.5 and truncating
  rounded=$(echo "($number + 0.5)/1" | bc)
  echo "$rounded" | rev | sed 's/.../& /g' | rev | sed 's/^ //'
}

# Dependencies check
for cmd in curl jq bc; do
  command -v $cmd >/dev/null || { notify-send "Error: $cmd not found"; exit 1; }
done

# List of supported currencies (uppercase only)
currencies=(SEK USD EUR GBP NOK)

# Detect and parse user input
menu="tofi -c $HOME/.config/tofi/configA --height 40 --width 800 --require-match=false"
currency_list_comma=$(IFS=, ; echo "${currencies[*]}" | sed 's/,/|/g')
input=$(echo "" | $menu --prompt "Enter amount with currency (e.g. 100 ${currency_list_comma}): ")
[ -z "$input" ] && exit

# Normalize input and extract number + currency
input=${input^^} # uppercase
amount=$(echo "$input" | grep -oE '[0-9]+([.][0-9]+)?')
currency=$(echo "$input" | grep -oE '[A-Z]{3}' | head -n1)

if [[ -z "$amount" || -z "$currency" ]]; then
  notify-send "Error: Enter like '100 USD' or '200 eur'"
  exit 1
fi

if [[ ! " ${currencies[@]} " =~ " $currency " ]]; then
  notify-send "Unsupported currency: $currency"
  exit 1
fi

# Cache setup
cache_file="/tmp/fx_rates.json"
cache_expiry=3600  # in seconds (1 hour)
now=$(date +%s)

# Refresh cache if needed
if [[ ! -f $cache_file || $(($(date +%s) - $(stat -c %Y "$cache_file"))) -ge $cache_expiry ]]; then
  echo "{}" > "$cache_file"  # reset
  for base in "${currencies[@]}"; do
    response=$(curl -s "https://api.frankfurter.app/latest?from=$base&to=$(IFS=,; echo "${currencies[*]/$base}")")
    jq ". + {\"$base\": $(echo "$response" | jq '.rates') }" "$cache_file" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
  done
fi

# Build output
output="$amount $currency converts to:\n"

for target in "${currencies[@]}"; do
  [[ "$currency" == "$target" ]] && continue
  rate=$(jq -r --arg base "$currency" --arg tgt "$target" '.[$base][$tgt]' "$cache_file")
  [[ "$rate" == "null" || -z "$rate" ]] && continue
  raw_converted=$(echo "$amount * $rate" | bc -l)
  converted=$(format_number "$raw_converted")
  rounded_rate=$(printf "%.4f" "$rate")
  output+="  $converted $target \t(rate: $rounded_rate)\n"
done

notify-send -t 10000 -h string:bgcolor:#586e75 "$(echo -e "$output")"
