#!/bin/bash

SB="#a3be8c"
NF="#d8dee9"
FN="monospace-16"
launcher=$1

currencies=(SEK USD EUR GBP NOK)
currency_list_pipe=$(IFS="|"; echo "${currencies[*]}")
PROMPT="Enter amount with currency (e.g. 100 ${currency_list_pipe}):"

format_number() {
  local number="$1"
  rounded=$(echo "($number + 0.5)/1" | bc)
  echo "$rounded" | rev | sed 's/.../& /g' | rev | sed 's/^ //'
}

for cmd in curl jq bc; do
  command -v $cmd >/dev/null || { notify-send "Error: $cmd not found"; exit 1; }
done

case $launcher in
    dmenu)
        menu_cmd="echo '             ' | dmenu -l 1 -c -fn \"$FN\" -sb \"$SB\" -nf \"$NF\" -p \"$PROMPT\""
        ;;
    tofi)
        menu_cmd="tofi -c $HOME/.config/tofi/configA --height 40 --width 800 --require-match=false --prompt \"$PROMPT\""
        ;;
    *)
        notify-send "You have to choose a launcher!"
        exit 1
        ;;
esac

input=$(eval "$menu_cmd") || exit 0
[ -z "$input" ] && exit

input=${input^^}   # uppercase
input=$(echo "$input" | tr -d ' ')  # remove spaces

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

cache_file="/tmp/fx_rates.json"
cache_expiry=3600
now=$(date +%s)

if [[ ! -f $cache_file || $(($(date +%s) - $(stat -c %Y "$cache_file"))) -ge $cache_expiry ]]; then
  echo "{}" > "$cache_file"
  for base in "${currencies[@]}"; do
    targets=("${currencies[@]/$base}")
    target_list=$(IFS=,; echo "${targets[*]}")
    response=$(curl -s "https://api.frankfurter.app/latest?from=$base&to=$target_list")
    if [[ -n "$response" ]]; then
        jq ". + {\"$base\": $(echo "$response" | jq '.rates') }" "$cache_file" > "$cache_file.tmp" && mv "$cache_file.tmp" "$cache_file"
    fi
  done
fi

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

