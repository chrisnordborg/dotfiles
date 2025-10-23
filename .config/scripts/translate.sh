#!/usr/bin/env bash
# Translate a word or phrase using LibreTranslate (API key needed and costs money, therefore I don't use this script.)

launcher="$1"
PROMPT="Enter a word or phrase to translate:"

# ----------------------------
# Choose launcher for input
# ----------------------------
case $launcher in
  dmenu)
    text=$(printf '' | dmenu -p "$PROMPT") ;;
  tofi)
    text=$(tofi -c "$HOME/.config/tofi/configA" \
                --require-match=false \
                --width 400 \
                --prompt "$PROMPT") ;;
  *)
    notify-send "You have to choose a launcher!"
    exit 1 ;;
esac

[ -z "$text" ] && exit 0

# ----------------------------
# Pick working LibreTranslate API (check /languages instead of HEAD)
# ----------------------------
API_LIST=(
  "https://translate.argosopentech.com"
  "https://translate.astian.org"
  "https://translate.stibarc.com"
  "https://libretranslate.de"
)

for candidate in "${API_LIST[@]}"; do
  if curl -s --max-time 3 "$candidate/languages" | grep -q '\[.*\]'; then
    API="$candidate"
    break
  fi
done

[ -z "$API" ] && {
  notify-send "No LibreTranslate servers available"
  exit 1
}

# ----------------------------
# Detect language (handle both array and object responses)
# ----------------------------
response=$(curl -s -X POST "$API/detect" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg q "$text" '{q: $q}')")

# Some servers return an array, others a single object — normalize both
detected_lang=$(echo "$response" | jq -r '
  if type=="array" then .[0].language
  elif type=="object" then .language
  else "en" end
')

[ -z "$detected_lang" ] && detected_lang="en"

# ----------------------------
# Translate into targets
# ----------------------------
targets=(en sv de es fr it)
output="Detected: $detected_lang\n\n"
english_copy=""

for lang in "${targets[@]}"; do
  [ "$lang" = "$detected_lang" ] && continue

  resp=$(curl -s -X POST "$API/translate" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg q "$text" --arg src "$detected_lang" --arg tgt "$lang" \
      '{q: $q, source: $src, target: $tgt, format: "text"}')")

  translation=$(echo "$resp" | jq -r '.translatedText // "[no result]"')
  output+="$lang : $translation\n"

  # Store English translation to copy later
  if [ "$lang" = "en" ]; then
    english_copy="$translation"
  fi
done

# ----------------------------
# Copy English translation to clipboard
# ----------------------------
if [ -n "$english_copy" ]; then
  echo -n "$english_copy" | wl-copy 2>/dev/null || echo -n "$english_copy" | xclip -selection clipboard
fi

# ----------------------------
# Show result
# ----------------------------
notify-send -t 10000 "Translations" "$(echo -e "$output")"
echo -e "$output"
