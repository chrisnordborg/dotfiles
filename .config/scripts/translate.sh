#!/usr/bin/env bash
# Translate a word or phrase using LibreTranslate
# Usage: ./translate.sh <launcher>

API="https://libretranslate.com"
launcher="$1"
PROMPT="Enter a word or sentence to translate:"

# ----------------------------
# GET INPUT THROUGH LAUNCHER
# ----------------------------
case "$launcher" in
    dmenu)
        menu_cmd="printf ' ' | dmenu -p \"$PROMPT\""
        ;;
    tofi)
        menu_cmd="tofi -c \"$HOME/.config/tofi/configA\" \
          --height 40 --width 350 \
          --require-match=false \
          --prompt \"$PROMPT\""
        ;;
    *)
        notify-send "You have to choose a launcher!"
        exit 1
        ;;
esac

text=$(eval "$menu_cmd") || exit 0
[ -z "$text" ] && exit 0

# ----------------------------
# DETECT SOURCE LANGUAGE
# ----------------------------
detected_lang=$(curl -s -X POST "$API/detect" \
  -H "Content-Type: application/json" \
  -d "$(jq -nc --arg q "$text" '{q: $q}')" \
  | jq -r '.[0].language')

# Fallback: assume English if detection fails or null
if [ -z "$detected_lang" ] || [ "$detected_lang" = "null" ]; then
  detected_lang="en"
  notify-send "Language detection uncertain" "Assuming English (fallback)"
fi

# ----------------------------
# TRANSLATE INTO MULTIPLE LANGUAGES
# ----------------------------
targets=("en" "sv" "de" "es" "fr" "it")
output="Detected language: $detected_lang\n\nTranslations:\n--------------\n"
english_translation=""

for lang in "${targets[@]}"; do
  # Skip translating into the same language
  if [ "$lang" = "$detected_lang" ]; then
    continue
  fi

  translation=$(curl -s -X POST "$API/translate" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg q "$text" --arg src "$detected_lang" --arg tgt "$lang" \
      '{q: $q, source: $src, target: $tgt}')" \
    | jq -r '.translatedText')

  [ "$lang" = "en" ] && english_translation="$translation"
  output+=$(printf "%-3s: %s\n" "$lang" "$translation")
done

# ----------------------------
# COPY ENGLISH TRANSLATION TO CLIPBOARD
# ----------------------------
if command -v wl-copy &>/dev/null; then
  echo -n "$english_translation" | wl-copy
elif command -v xclip &>/dev/null; then
  echo -n "$english_translation" | xclip -selection clipboard
else
  notify-send "Clipboard tool not found (install wl-clipboard or xclip)."
fi

# ----------------------------
# DISPLAY RESULT
# ----------------------------
case "$launcher" in
    dmenu)
        echo -e "$output" | dmenu -l 10 -p "Results:"
        ;;
    tofi)
        echo -e "$output" | tofi -c "$HOME/.config/tofi/configA" \
          --width 500 --height 300 \
          --prompt "Translations:"
        ;;
    *)
        echo -e "$output"
        ;;
esac

# ----------------------------
# NOTIFY COPY SUCCESS
# ----------------------------
[ -n "$english_translation" ] && notify-send "Copied English translation" "$english_translation"
